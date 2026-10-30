#!/usr/bin/env python3
"""校验构建出来的 .itb：设备对不对、EN8811H 复位时序对不对、内核版本是多少。

用法:
    python3 scripts/verify-firmware.py bin/targets/airoha/an7581/*.itb

为什么要在 CI 里做这一步:
    固件编出来不等于能用。本设备上有两个"编过但其实是坏的"经典状态,
    都只在 DTB / 内核的一部分字节里体现, 不会让编译失败:
      1) EN8811H 复位时序。写 1s/100ms 时 PHY 被摁在复位线上太久,
         MAC 侧 PCS 训练拿不到 rxlock -> lan1(2.5G) 冷启动"假 Up"
         (ethtool 全绿但收不到包), 必须 ip link set lan1 down/up 才通。
         修好的值: assert=10000 / deassert=20000。
      2) 设备名不对 (编成别的 profile)。
"""

import gzip
import re
import struct
import sys

FDT_BEGIN_NODE, FDT_END_NODE, FDT_PROP, FDT_NOP, FDT_END = 1, 2, 3, 4, 9

EXPECT_MODEL = "Nokia XG-040G-MD"
EXPECT_ASSERT_US = 10_000
EXPECT_DEASSERT_US = 20_000


def parse_fdt(blob):
    """返回 {节点路径: {属性名: bytes}}"""
    magic, totalsize, off_struct, off_strings = struct.unpack(">4I", blob[:16])
    if magic != 0xD00DFEED:
        raise ValueError("不是 FDT (magic=%08x)" % magic)
    strings = blob[off_strings:]
    pos, path, out = off_struct, [], {}

    def name_at(off):
        end = strings.index(b"\0", off)
        return strings[off:end].decode("utf-8", "replace")

    while True:
        (tok,) = struct.unpack(">I", blob[pos:pos + 4])
        pos += 4
        if tok == FDT_BEGIN_NODE:
            end = blob.index(b"\0", pos)
            nm = blob[pos:end].decode("utf-8", "replace")
            pos = (end + 4) & ~3
            path.append(nm)
            out.setdefault("/".join(path), {})
        elif tok == FDT_END_NODE:
            path.pop()
        elif tok == FDT_PROP:
            plen, noff = struct.unpack(">II", blob[pos:pos + 8])
            pos += 8
            out.setdefault("/".join(path), {})[name_at(noff)] = blob[pos:pos + plen]
            pos = (pos + plen + 3) & ~3
        elif tok == FDT_NOP:
            pass
        elif tok == FDT_END:
            break
        else:
            raise ValueError("未知 token %d @0x%x" % (tok, pos))

    # 根节点名是空串, 拼出来会是 "/images/kernel-1" 这种带前导斜杠的形式, 统一去掉
    return {(k.lstrip("/") or "/"): v for k, v in out.items()}


def be32(raw):
    return struct.unpack(">I", raw)[0] if len(raw) == 4 else None


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = sys.argv[1]
    data = open(path, "rb").read()
    tree = parse_fdt(data)
    print("文件: %s (%d 字节)" % (path, len(data)))

    images = {k: v for k, v in tree.items()
              if k.startswith("images/") and len(k.split("/")) == 2}
    if not images:
        print("FATAL: 这个 ITB 里没有 images 节点")
        return 1

    for name, props in images.items():
        print("  %-14s type=%-10s comp=%-5s size=%d" % (
            name.split("/", 1)[1],
            props.get("type", b"").rstrip(b"\0").decode(),
            props.get("compression", b"").rstrip(b"\0").decode(),
            be32(props.get("data-size", b"")) or 0))

    # 设备树: 第一个 type=flat_dt 的 image
    fdt_img = next((v for v in images.values()
                    if v.get("type", b"").rstrip(b"\0") == b"flat_dt"), None)
    kernel_img = next((v for v in images.values()
                       if v.get("type", b"").rstrip(b"\0") == b"kernel"), None)

    rc = 0

    if kernel_img is None:
        print("WARN: 没有 kernel image")
    else:
        off = be32(kernel_img["data-position"])
        size = be32(kernel_img["data-size"])
        blob = data[off:off + size]
        if blob[:2] == b"\x1f\x8b":
            blob = gzip.decompress(blob)
        m = re.search(rb"Linux version [^\x00]{10,120}", blob)
        print("内核: %s" % (m.group(0).decode("utf-8", "replace") if m else "(未找到版本串)"))

    if fdt_img is None:
        print("FATAL: 没有 flat_dt image, 无法校验设备与时序")
        return 1

    off = be32(fdt_img["data-position"])
    size = be32(fdt_img["data-size"])
    dtree = parse_fdt(data[off:off + size])

    model_raw = dtree.get("/", {}).get("model", b"")
    model = model_raw.rstrip(b"\0").decode("utf-8", "replace")
    print("设备: %s" % model)
    if EXPECT_MODEL not in model:
        print("FATAL: 型号里没有 %r —— 编成别的设备了?" % EXPECT_MODEL)
        rc = 1

    found = {}
    for node, props in dtree.items():
        for key, want in (("reset-assert-us", "assert"),
                          ("reset-deassert-us", "deassert")):
            if key in props:
                val = be32(props[key])
                found.setdefault(want, []).append((node, val))

    for want, expect in (("assert", EXPECT_ASSERT_US),
                         ("deassert", EXPECT_DEASSERT_US)):
        if not found.get(want):
            print("WARN: DTB 里没有 reset-%s-us, 跳过该项" % want)
            continue
        for node, val in found[want]:
            ok = "OK " if val == expect else "BAD"
            print("%s reset-%s-us = %d (期望 %d)  @ %s" % (ok, want, val, expect, node))
            if val != expect:
                rc = 1

    print("=== 校验%s ===" % ("通过" if rc == 0 else "失败"))
    return rc


if __name__ == "__main__":
    sys.exit(main())
