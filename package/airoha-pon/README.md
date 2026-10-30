# package/airoha-pon —— Airoha xPON 驱动与用户态（内置）

这些包原本在 pbs05 的两个独立 feed 里，为了让本仓库**自包含**（不挂外部 feed 也能编出
带 `pon0` 的固件）已直接并入源码树。

| 目录 | 上游 |
|---|---|
| `airoha-xpon/` | https://github.com/pbs05/openwrt-pon-drivers @ `e5194d2` (r68) |
| `airoha-pon-frontends/` | 同上 (r12)，含 EN7572 的 MD32 固件 `A60993.elf.{pm,dm}` |
| `airoha-ponctl/` | https://github.com/pbs05/openwrt-pon-userspace @ `cce9d75` |
| `airoha-pon-daemons/` | 同上（提供 `airoha-pond`） |
| `airoha-pon-debug/` | 同上 |
| `luci-app-pon/` | 同上（PON 状态 + 板级身份编辑） |
| `luci-app-iptv/` | 同上 |

## 与内核补丁的绑定关系

`kmod-airoha-xpon` 通过 `<linux/airoha-eth.h>` 使用 airoha_eth 的 PON 数据通路 API，
那个头文件由 `target/linux/airoha/patches-6.18/922-net-airoha-add-AN7581-PON-data-and-control-paths.patch`
引入。`kmod-airoha-en7572` / `kmod-airoha-pon-frontend` 依赖 608 提供的
`<linux/pcs/pcs-airoha.h>`。

**升级这些包时必须同时核对 922 / 608 的 API**，否则编译会报未定义符号或结构体字段不匹配。

## 同步上游

```bash
# 驱动
git clone https://github.com/pbs05/openwrt-pon-drivers /tmp/pd
cp -a /tmp/pd/airoha-xpon/src/. package/airoha-pon/airoha-xpon/src/
cp -a /tmp/pd/airoha-pon-frontends/. package/airoha-pon/airoha-pon-frontends/
# 用户态同理（注意别覆盖本目录下已有的改动）
```

改完记得同步 `PKG_RELEASE`，并在 `pon-build/README.md` 的表格里更新版本号。

⚠️ 这些包能改 MAC 和 PON 序列号。只在自家线路上替换自己的 ONT，别用在别人的线路上。
