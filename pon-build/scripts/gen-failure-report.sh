#!/usr/bin/env bash
# 生成可匿名读取的云编译失败诊断报告 (绕过 CI 日志 403 API 限制)。
# 依赖 env: GITHUB_RUN_NUMBER, GITHUB_SHA
# 输出: pon-build/last-failure-report.md
# 设计目标: 一次失败就能看出"每个重点模块是符号没编成(=y/未设置)还是 FILES 路径写错(6.18 搬家)"。
set +e

OUT=pon-build/last-failure-report.md
build_log=${build_log:-build.log}

miss=$(grep -oE "ERROR: module '[^']+' is missing" "$build_log" 2>/dev/null \
        | sed -E "s/ERROR: module '([^']+)' is missing/\1/" | sort -u)
syncf=$(grep -nE "\(NEW\)|syncconfig\] Error|scripts/kconfig/Makefile.*syncconfig" "$build_log" 2>/dev/null | head -40)

{
  echo "# Build failure report — run ${GITHUB_RUN_NUMBER:-?}"
  echo
  echo "head_sha: ${GITHUB_SHA:-?}"
  echo "time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "## syncconfig 是否中止 (NEW 提示导致 Error 1)?"
  if echo "$syncf" | grep -q "syncconfig\] Error"; then
    echo "**YES — syncconfig 中止, 内核模块可能没编出来**"
  else
    echo "no (仅 (NEW) 提示, 未中止)"
  fi
  echo
  echo "### syncconfig (NEW) 提示行"
  echo '```'; echo "$syncf"; echo '```'
  echo
  echo "## 缺失内核模块 .ko (去重, 已剔除 \$mod 字面量噪声)"
  clean_miss=$(echo "$miss" | grep -v "'\$mod'" || true)
  if [ -n "$clean_miss" ]; then
    echo "count: $(echo "$clean_miss" | wc -l)"
    echo '```'; echo "$clean_miss"; echo '```'
  else
    echo "(无 — 不是 .ko 缺失问题, 看 build.log 末段)"
  fi
  echo
  echo "## 5 个重点模块根因定位 (kmod 是否选中 / 符号解析值 / .ko 是否真编出来)"
  echo
  echo '```'
  for pair in \
    "scsi_mod.ko|kmod-scsi-core|CONFIG_SCSI_MOD" \
    "usbcore.ko|kmod-usb-core|CONFIG_USB" \
    "usb-common.ko|kmod-usb-common|CONFIG_USB_COMMON" \
    "ledtrig-usbport.ko|kmod-usb-ledtrig-usbport|CONFIG_USB_LEDS_TRIGGER_USBPORT" \
    "userspace-consumer.ko|kmod-regulator-userspace-consumer|CONFIG_REGULATOR_USERSPACE_CONSUMER"; do
    ko="${pair%%|*}"; rest="${pair#*|*}"; kmod="${rest%%|*}"; sym="${rest#*|*}"
    ksel=$(grep -E "^CONFIG_PACKAGE_${kmod}=" .config 2>/dev/null | head -1)
    sval=$(grep -E "^${sym}=" .config 2>/dev/null | head -1)
    [ -z "$sval" ] && sval=$(grep -E "^# ${sym} is not set" .config 2>/dev/null | head -1)
    built=$(find build_dir -name "$ko" 2>/dev/null | head -1)
    printf '%-26s kmod=%-34s sym=%-42s built=%s\n' "$ko" "${ksel:-<未选中>}" "${sval:-<无>}" "${built:-NO}"
  done
  echo '```'
  echo
  echo "解读: built=NO 且 sym==m  => 内核确实编了模块, 但 kmod FILES 路径写错 (6.18 模块搬家)。"
  echo "      built=NO 且 sym==y 或 未设置 => 符号被内置/裁掉, 没编成可加载模块。"
  echo "      built=有路径 => 模块已编出, 问题在别处。"
  echo
  echo "## build.log 末 150 行"
  echo '```'; tail -n 150 "$build_log" 2>/dev/null; echo '```'
} > "$OUT"

echo "wrote $OUT"
