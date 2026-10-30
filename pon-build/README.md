# pon-build —— Nokia XG-040G-MD (UBI) 的 PON 构建层

目标设备 `nokia,xg-040g-md-ubi`（Airoha AN7581）。PON 能力**已经移植进本仓库源码树**
（`target/linux/airoha/` + `package/airoha-pon/`），不再依赖外部 feed。

和"直接编 PonWrt"的区别：内核补丁集仍以 immortalwrt 上游为主干，只把 PON 需要的那几个
补丁按上游风格补进去；驱动与用户态包以源码形式收在 `package/airoha-pon/`，随仓库固定版本。

## 移植了什么（对照 pbs05/ponwrt）

| 位置 | 内容 |
|---|---|
| `patches-6.18/202-28`、`202-29` | pinctrl 拆出 `pon_tx_disable_gpio` 组（AN7581 / AN7583） |
| `patches-6.18/608` | PCS 增加 PON 线速模式（GPON 2.488G / XG-PON 9.953G / 10G-EPON） |
| `patches-6.18/922` | airoha_eth 增加 PON 数据与控制通路：GDM2 PON netdev、GEM/T-CONT/LLID 分类、OMCI/OAM 控制通道 |
| `patches-6.18/310-09`、`310-10`、`605` | 换成 pbs05 的 PCS 驱动 v15 版本（608 按该版本生成，旧版打不上） |
| `dts/an7581.dtsi` | `xpon_mac` 节点（GPON/XGPON/EPON/PON-PHY 四段寄存器 + 双中断 + pcs-handle） |
| `dts/an758x-nokia_xg-040g-common.dtsi` | `&xpon_mac` 接线（pon_pins、EN7572、pon-serial、data-path=&gdm2）、`&gdm2` 标 PON 数据通路 |
| `dts/an758x-nokia_xg-040g-ubi-parts.dtsi` | bosa 卷暴露 512B 标定 nvmem（`calibration@2`）、ri 卷暴露 PON SN（`pon-serial@1a`） |
| `dts/an7581-nokia_xg-040g-md-common.dtsi` | `pon_pins` pinctrl、i2c0 上的 `en7572@50`（含 TX-disable GPIO38）、WAN/LOS/在线三颗灯挂 `pon0-*` 触发器、`pon-calibration` alias |
| `base-files/etc/board.d/03_pon_data` | 告诉 luci-app-pon：bosa/ri 各是 256KB UBI 卷，SN/MAC 在 ri 的哪个偏移 |
| `an7581/base-files/etc/board.d/02_network` | wan 绑定 `pon0`（原来是纯 LAN，没有 WAN 口） |
| `image/an7581.mk` | 设备默认带 `kmod-airoha-en7572 kmod-airoha-xpon airoha-ponctl airoha-pond` |
| `an7581/target.mk` | 默认带 `kmod-nf-conntrack-bridge`（PON 上行桥接卸载需要） |
| `package/airoha-pon/` | 驱动与用户态源码：pon-frontends（EN7572/GN28L95/UX3363）、xpon MAC、ponctl、pond、pon-debug、luci-app-pon、luci-app-iptv |

`922` 里有一处 hunk 去掉了：pbs05 在 `airoha_dev_stop()` 给 `phylink_disconnect_phy()` 加
NULL 保护，而上游这个函数里根本没有那次调用（上游只在 open 的 error path 里 disconnect），
所以该 hunk 无对象、直接删掉，对 PON 没有影响。

**MAC 分配（跟 PonWrt 一致，会和上游原行为不同）**：`pon0` 取 RI `0x3e` 的基址（索引 0），
`gdm1`（label-mac-device）改成索引 1，即 LAN 侧 MAC 整体上移一位；`lan1`（gdm4）仍是索引 0，
所以 `pon0` 与 `lan1` MAC 相同 —— 两者在 LAN/WAN 两个不同广播域，实际不冲突。如果线路侧
DHCP 对 MAC 有绑定要求，把 `&gdm4` 的索引改成 2 再编。

## 目录

```text
pon-build/
├── feeds.conf                  固定版本的 feed 清单（PON 已内置，不再挂 pbs05 feed）
│                               ⚠️ 上游 .gitignore 忽略根目录 feeds.conf,
│                                  所以构建时 cp pon-build/feeds.conf feeds.conf
├── configs/xg040g.config       配置种子：目标 + PON + 硬件 + LuCI 基座
├── configs/xg040g-extra.config 可选附加包（openclash / samba / 打印 …）
├── patches/airoha/925-*.patch  PON PPE 卸载元数据（可选，默认关）
└── scripts/
    ├── set-build-version.sh    把日期/commit/设备写进版本串
    ├── apply-local-patches.sh  按开关注入 925
    ├── check-config.sh         defconfig 之后的硬校验
    └── verify-firmware.py      编完解 ITB，校验设备名与 EN8811H 复位时序
```

工作流：`.github/workflows/build-pon-xg040g.yml`（手动触发）。
Actions → `Build XG-040G-MD (PON)` → Run workflow。

## 本地构建

```bash
# 在本仓库（immortalwrt fork）根目录执行
cp pon-build/feeds.conf feeds.conf
./scripts/feeds update -a && ./scripts/feeds install -a

SRC_DIR=$PWD REPO_DIR=$PWD/pon-build bash pon-build/scripts/apply-local-patches.sh

cp pon-build/configs/xg040g.config .config
# 可选：cat pon-build/configs/xg040g-extra.config >> .config
SRC_DIR=$PWD DEVICE_MODEL=XG-040G-MD bash pon-build/scripts/set-build-version.sh .config
make defconfig
SRC_DIR=$PWD bash pon-build/scripts/check-config.sh

make download -j$(nproc)
make -j$(nproc) world

python3 pon-build/scripts/verify-firmware.py bin/targets/airoha/an7581/*.itb
```

产物：`bin/targets/airoha/an7581/immortalwrt-*-airoha-an7581-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb`

## 内置的 PON 包

源码来自 <https://github.com/pbs05/openwrt-pon-drivers> 与 <https://github.com/pbs05/openwrt-pon-userspace>,
已并入 `package/airoha-pon/`：

| 包 | 版本 | 作用 |
|---|---|---|
| `kmod-airoha-xpon` | r68 | PON MAC 驱动（XG-PON / 10G-EPON 已测），依赖 922 提供的 `airoha-eth.h` API |
| `kmod-airoha-pon-frontend` | r12 | 光前端核心 |
| `kmod-airoha-en7572` | r12 | EN7572 前端 + MD32 固件（XG-040G-MD 用这个） |
| `kmod-airoha-paged-bosa` | r12 | GN28L95 / UX3363 前端（本机不用，别选） |
| `airoha-ponctl` | 0.2.0 | 线路配置与状态 |
| `airoha-pond` | 0.3.0 | OMCI / OAM 协议代理 |
| `airoha-pon-debug` | 0.1.0 | 抓包与诊断（PPPoE 过滤 + 状态时间线，20MB RAM 预算） |
| `luci-app-pon` | 0.1.0 | PON 界面 + **板级身份编辑（改 MAC / PON 序列号）** |
| `luci-app-iptv` | 0.1.0 | IPTV 桥接配置 |

⚠️ 改 SN 是敏感能力。替代自家 ONT 注册时正常，别用在别人的线路上。

⚠️ 如果旧的 `feeds.conf` 里还挂着 `pbs05/openwrt-pon-drivers`、`pbs05/openwrt-pon-userspace`，
同一个包名会出现两份定义、直接报重复 package —— 用本目录的 feeds.conf，别叠加。

## 925 是什么，要不要打

`925-net-airoha-add-PON-PPE-offload-metadata.patch`（作者 pbs05）解决的问题：

> PON 流量走 `ndo_start_xmit` 时，会在 QDMA 描述符里带上选定的 **GEM Port-ID** 和 **T-CONT/LLID**。而 PPE 硬件转发**绕过** `ndo_start_xmit`，它的 FOE（流表项）里没有这两样元数据，offload 的上行流到达 GDM2 时就没有有效的 PON bearer 选择。

做法：在 TC flow 安装时解析配置好的 VLAN/P-bit 映射，把 GEM 与 T-CONT/LLID 写进 FOE；需要动态 P-bit 决策的流留在软件里（nf_flow_table 不暴露那个 PCP）。OMCI 重配或链路回到 O5 时映射会变，所以用 TC 回调串行化替换，只删受影响的 FOE。

**副作用（也是它被记住的原因）**：它把 QoS 通道选择那段重写成 PON if/else，并在 `else` 分支里**原样保留**上游 158 引入的那行：

```c
if (dev->flags & AIROHA_PRIV_F_PON) {
        channel = FIELD_GET(AIROHA_PON_QDMA_TCONT_MASK, pon_tag);
} else {
        channel = dsa_port >= 0 ? dsa_port : port->id;   /* ← 又在 else 里回来了 */
        channel %= AIROHA_NUM_QOS_CHANNELS;
}
```

→ **不打 925**：PON 上行无法安全硬件卸载（走软件路径，能通但费 CPU）。
→ **打了 925**：能卸载，但 `dsa_port % 4` 也被带进来（lan2→ch2、lan3→ch3）。

2026-10-08 实测：**ch2 能跑满千兆**（客户端插 lan2，900 Mbps，占线速 96%），所以 `dsa_port % 4` 是调度属性、**不是速率上限**。**默认不打**（`PON_925=no`），除非确认需要 PON 上行硬件卸载 —— 那时在 workflow 里设 `pon_925=yes` 即可。

**这里不再保留 999 补丁**（曾经的「DSA 目标口 QoS 通道恒取 0」）：它要修的前提「ch2/ch3 有 ~500 Mbps 上限」已被上面的实测否证；开了反而把四个口全挤到 ch0，废掉 158 的 per-port HTB offload 初衷，还丢掉按通道的观测能力。

## 三个必须避开的坑

**1. EN8811H 复位时序。** `an7581-nokia_xg-040g-md-common.dtsi` 里 lan1 的 2.5G PHY：

```dts
reset-assert-us   = <10000>;   /* 修好的值 */
reset-deassert-us = <20000>;
```

写成 1s/100ms 时 PHY 被摁在复位线上太久，MAC 侧 PCS 训练拿不到 rxlock → 冷启动后 lan1 "假 Up"（`ethtool` 全绿但收不到包），必须 `ip link set lan1 down && up` 救一次。上游自 2026-10-06 起已是 10ms/20ms，**别改回去**。`scripts/verify-firmware.py` 在 CI 里直接判这个值，不对就让流水线红。

**2. `make defconfig` 会静默删掉不存在的符号。** 配置里写了 `CONFIG_PACKAGE_xxx=y` 但源码树里没这个包时，编译照样成功、固件里就是没有。所以 `scripts/check-config.sh` 在 defconfig 之后对 PON 关键包做了硬断言 —— 别删。

**3. 换 PCS 补丁要成套。** `310-09/310-10/605` 必须是 pbs05 的 v15 版本；退回上游旧版会让 `608` 打不上（hunk 对不上），PON 线速模式就没了。

## feeds 为什么要固定

`feeds.conf` 里每个 feed 都 pin 到了具体提交：上游滚动后依赖会超前于已 pin 的源码，表现不是报错，而是**旧配置里的符号被静默丢弃**（编译 green、固件少功能）。固定到同期提交才能复现。

特别提醒：`luci` 必须 pin 在 `ed0441b1`（2026-10-02 "Merge Official Source"）**或之后**。immortalwrt/luci 的 master 线在 2026-09 整段时间把约 64 个第三方 LuCI 应用拆了出去，那条线上 pin 的任何提交都没有 `luci-app-openclash`（applications 只有 103 项，merge 回来后是 167 项）。

## 参考

- <https://github.com/immortalwrt/immortalwrt> — 本仓库的上游
- <https://github.com/pbs05/ponwrt> — PON 已完全合在树里的参考实现（本移植的来源）
- <https://github.com/pbs05/openwrt-pon-drivers> / <https://github.com/pbs05/openwrt-pon-userspace> — 驱动与用户态的原始仓库
