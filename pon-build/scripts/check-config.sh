#!/usr/bin/env bash
# make defconfig 之后的硬校验。全部在几十秒内出结果, 不用白编两三个小时。
#
# 为什么必须查: make defconfig 对不存在的 CONFIG_PACKAGE_xxx 符号就是默默删行 ——
#   编译照 green, 固件里就是没有。这里一次性挡住。

set -uo pipefail

SRC_DIR="${SRC_DIR:-.}"
DEVICE="${DEVICE:-nokia_xg-040g-md-ubi}"
CONFIG="$SRC_DIR/.config"
[ -f "$CONFIG" ] || { echo "FATAL: 找不到 $CONFIG" >&2; exit 1; }

fail=0
note() { echo "  $*"; }
bad()  { echo "FATAL: $*"; fail=1; }

echo "=== 设备选择 ==="
if grep -q '^CONFIG_TARGET_MULTI_PROFILE=y' "$CONFIG"; then
	bad "CONFIG_TARGET_MULTI_PROFILE 仍为 y, 会把该 target 下全部设备都编一遍"
fi
grep -E '^CONFIG_TARGET.*DEVICE.*=y' "$CONFIG" | sed 's/^/  /' || bad "没有任何设备被选中"
# 上游把 TARGET_DEVICE_* 改成了 menuconfig, defconfig 后未必保留
# CONFIG_TARGET_DEVICE_... 这个符号; 只要 CONFIG_TARGET_<subtarget>_DEVICE_...
# 还在就说明 profile 选对了 (per-device rootfs 未启用时 DEVICE_PACKAGES 仍由
# select DEFAULT_$pkg 进固件, 见 scripts/target-metadata.pl:324)。
if ! grep -qE "^CONFIG_TARGET_(DEVICE_)?airoha_an7581_DEVICE_${DEVICE}=y" "$CONFIG"; then
	bad "目标设备 ${DEVICE} 没有被选中 (CONFIG_TARGET_*_DEVICE_${DEVICE} 都不在 .config)"
fi

echo "=== PON 关键包 (缺一个就起不来 pon0) ==="
for pkg in kmod-airoha-xpon kmod-airoha-pon-frontend kmod-airoha-en7572 \
           airoha-ponctl airoha-pond luci-app-pon airoha-en8811h-firmware fitblk; do
	if grep -q "^CONFIG_PACKAGE_${pkg}=y" "$CONFIG"; then
		note "OK   ${pkg}"
	else
		bad "${pkg} 不是 =y (源码树里没这个包? 确认 package/airoha-pon 被扫描到、feeds install -a 跑过)"
	fi
done

echo "=== 附加包 (对齐 Openwrt-Actions 的 xg-040g-md 配置) ==="
# 这几个是最容易被 defconfig 静默删掉的: 包不存在时编译照样 green, 刷完才发现没有。
for pkg in luci-app-openclash luci-app-ddns ddns-scripts-dnspod \
           luci-proto-wireguard zram-swap luci-app-iptv ruby-yaml; do
	if grep -q "^CONFIG_PACKAGE_${pkg}=y" "$CONFIG"; then
		note "OK   ${pkg}"
	else
		bad "${pkg} 不是 =y —— 检查 luci feed pin 与对应包是否存在"
	fi
done

echo "=== 2.5G PHY ==="
for pkg in kmod-phy-airoha-en8811h airoha-en8811h-firmware; do
	grep -q "^CONFIG_PACKAGE_${pkg}=y" "$CONFIG" && note "OK   ${pkg}" \
		|| bad "${pkg} 不是 =y —— lan1(2.5G) 会起不来"
done

echo "=== 调试信息 / ccache ==="
if grep -qE '^CONFIG_KERNEL_DEBUG_INFO(_REDUCED)?=y' "$CONFIG"; then
	bad "CONFIG_KERNEL_DEBUG_INFO 仍是 y, 内核与全部 kmod 会带 DWARF 调试信息"
fi
grep -q '^CONFIG_CCACHE=y' "$CONFIG" || note "WARN: CCACHE 未开, 缓存与加速都白搭"

echo "=== 源码层断言: airoha_ppe.c 的 QoS 通道 ==="
PPE="$SRC_DIR/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.*/drivers/net/ethernet/airoha/airoha_ppe.c"
PPE_REAL=$(ls $PPE 2>/dev/null | head -n1)
if [ -n "$PPE_REAL" ]; then
	grep -n "dsa_port >= 0 ? dsa_port : port->id" "$PPE_REAL" | sed 's/^/  /' \
		&& note "(上面是上游行为: DSA 口按端口号分通道; 2026-10-08 实测它不是速率上限)" \
		|| note "未找到 dsa_port 通道映射 (上游可能改过, 或走了 PON 分支)"
else
	note "内核源码尚未展开 (make target/linux/prepare 之后才有), 跳过源码断言"
fi

echo
if [ "$fail" -ne 0 ]; then
	echo "=== 配置校验失败, 别往下编了 ==="
	exit 1
fi
echo "=== 配置校验通过 ==="
