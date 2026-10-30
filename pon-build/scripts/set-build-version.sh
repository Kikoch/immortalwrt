#!/usr/bin/env bash
# 把"哪一天 / 哪个提交 / 哪台设备"写进 .config, 让固件自己能报身份。
#
# 用法:
#   BUILD_DATE=20261008 REPO_COMMIT=abcd1234 UPSTREAM_COMMIT=ef567890 \
#     bash scripts/set-build-version.sh .config
#
# 文件名规则 (include/image.mk):
#   IMG_PREFIX = DIST + [VERSION_NUMBER] + [VERSION_CODE] + [EXTRA_IMAGE_NAME] + BOARD-SUBTARGET

set -euo pipefail

config_file="${1:-.config}"
[ -f "$config_file" ] || { echo "config not found: $config_file" >&2; exit 1; }

build_tz="${BUILD_TZ:-Asia/Shanghai}"
commit_len="${COMMIT_LEN:-8}"
build_date="${BUILD_DATE:-$(TZ="$build_tz" date +'%Y%m%d')}"
repo_commit="${REPO_COMMIT:-$(git -C "${SRC_DIR:-.}" rev-parse --short="$commit_len" HEAD 2>/dev/null || echo unknown)}"
upstream_commit="${UPSTREAM_COMMIT:-$repo_commit}"
device_model="${DEVICE_MODEL:-$(sed -n -e 's/^CONFIG_TARGET_PROFILE="DEVICE_[a-z0-9_]*_\([A-Za-z0-9_-]*\)"$/\1/p' "$config_file" | head -n1)}"
device_model="$(printf '%s' "${device_model}" | tr '[:lower:]' '[:upper:]' | sed -e 's/-UBI$//')"

version_dist="${VERSION_DIST:-ImmortalWrt PON${device_model:+ $device_model}}"
version_number="${VERSION_NUMBER:-${build_date}-${repo_commit}}"
version_code="${VERSION_CODE:-${build_date}-${repo_commit}-${upstream_commit}}"

sed -i -e '/^CONFIG_VERSIONOPT=/d' -e '/^CONFIG_VERSION_DIST=/d' \
       -e '/^CONFIG_VERSION_NUMBER=/d' -e '/^CONFIG_VERSION_CODE=/d' \
       -e '/^CONFIG_VERSION_FILENAMES=/d' "$config_file"
{
	echo "CONFIG_VERSIONOPT=y"
	echo "CONFIG_VERSION_DIST=\"${version_dist}\""
	echo "CONFIG_VERSION_NUMBER=\"${version_number}\""
	echo "CONFIG_VERSION_CODE=\"${version_code}\""
	echo "CONFIG_VERSION_FILENAMES=y"
} >> "$config_file"

echo "VERSION_DIST=${version_dist}"
echo "VERSION_NUMBER=${version_number}"
echo "VERSION_CODE=${version_code}"
