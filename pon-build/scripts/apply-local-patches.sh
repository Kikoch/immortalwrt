#!/usr/bin/env bash
# 把本仓库 patches/airoha/ 下的补丁拷进源码树的 target/linux/airoha/patches-6.18/
#
# 为什么本地补丁一律用"编号最大"的补丁, 而不是改上游补丁的既有行:
#   同一个表达式常被多个补丁引用。以 airoha_ppe.c 的 QoS 通道那行为例,
#   上游 158 引入它, PonWrt 独有的 925 又把整段改写成 PON if/else 并在 else 分支
#   原样再引入一次。改 158 会被 925 整个覆盖。所以本目录只放排在上游补丁之后的东西,
#   上游补丁一个字都不动。
#
# 开关:
#   PON_925=yes   -> 应用 925 (PON PPE 卸载元数据, 上游 immortalwrt 没有)
#
# 2026-10-08: 这里曾经放过一个 999 (DSA 目标口的 QoS 通道恒取 0), 已删除、不再保留。
#   它要修的前提「ch2/ch3 有 ~500 Mbps 上限」当天被实测否证 —— 客户端插 lan2
#   实测 900 Mbps (占线速 96%), ch2 跑满千兆。开了反而把四个口全挤到 ch0,
#   废掉 158 的 per-port HTB offload 初衷, 还丢掉按通道的观测能力。

set -euo pipefail

SRC_DIR="${SRC_DIR:-.}"
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
PON_925="${PON_925:-no}"

PATCH_DIR="$SRC_DIR/target/linux/airoha/patches-6.18"
if [ ! -d "$PATCH_DIR" ]; then
	echo "FATAL: 找不到 $PATCH_DIR, 补丁无法应用" >&2
	exit 1
fi

# 卫生: 补丁目录会被整个复制进内核树, 别留垃圾
rm -f "$PATCH_DIR"/*.bak "$PATCH_DIR"/*.orig "$PATCH_DIR"/*.rej 2>/dev/null || true

if [ "$PON_925" = "yes" ]; then
	src="$REPO_DIR/patches/airoha/925-net-airoha-add-PON-PPE-offload-metadata.patch"
	[ -f "$src" ] || { echo "FATAL: 缺少 $src" >&2; exit 1; }
	cp "$src" "$PATCH_DIR/"
	echo "=== 925 已注入: PON 上行的 GEM/T-CONT 会写进 FOE, 可安全硬件卸载 ==="
	echo "    注意: 它同时把「DSA 口按端口号分通道」(lan2->ch2, lan3->ch3) 一起带进来;"
	echo "          2026-10-08 实测 ch2 跑满千兆 —— 这是调度属性, 不是速率上限。"
else
	echo "=== [跳过] 925 未注入: PON 上行拿不到 GEM/T-CONT, 无法安全卸载 (上游默认状态) ==="
fi

echo "=== patches-6.18 里来自本仓库的补丁 ==="
ls -1 "$PATCH_DIR" | grep -E '^925' || echo "(无)"
