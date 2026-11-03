# Build failure report — run 20

head_sha: cced758304b44acdca20e904eb645c0eab6efb9b
time: 2026-11-03T12:21:18Z

## syncconfig 是否中止 (NEW 提示导致 Error 1)?
no (仅 (NEW) 提示, 未中止)

### syncconfig (NEW) 提示行
```
76673:Compile also drivers which will not load (COMPILE_TEST) [N/y/?] (NEW) 
76674:Compile the kernel with warnings as errors (WERROR) [N/y/?] (NEW) 
76675:Local version - append to kernel release (LOCALVERSION) [] (NEW) 
76676:Automatically append version information to the version string (LOCALVERSION_AUTO) [Y/n/?] (NEW) 
76677:Build ID Salt (BUILD_SALT) [] (NEW) 
76678:Default init path (DEFAULT_INIT) [] (NEW) 
76679:Default hostname (DEFAULT_HOSTNAME) [(none)] (NEW) 
76682:General notification queue (WATCH_QUEUE) [N/y/?] (NEW) 
76683:Enable process_vm_readv/writev syscalls (CROSS_MEMORY_ATTACH) [Y/n/?] (NEW) 
76688:Expose irq internals in debugfs (GENERIC_IRQ_DEBUGFS) [N/y/?] (NEW) 
76693:  1. Periodic timer ticks (constant rate, no dynticks) (HZ_PERIODIC) (NEW)
76695:  3. Full dynticks system (tickless) (NO_HZ_FULL) (NEW)
76697:Old Idle dynticks config (NO_HZ) [N/y/?] (NEW) 
76699:Enable auxiliary POSIX clocks (POSIX_AUX_CLOCKS) [N/y/?] (NEW) 
76705:  Permanently enable BPF JIT and remove BPF interpreter (BPF_JIT_ALWAYS_ON) [N/y/?] (NEW) 
76706:Disable unprivileged BPF by default (BPF_UNPRIV_DEFAULT_OFF) [Y/n/?] (NEW) 
76710:Preload BPF file system with kernel specific program and map iterators (BPF_PRELOAD) [N/y/?] (NEW) 
76712:  1. No Forced Preemption (Server) (PREEMPT_NONE) (NEW)
76713:  2. Voluntary Kernel Preemption (Desktop) (PREEMPT_VOLUNTARY) (NEW)
76715:  4. Scheduler controlled preemption model (PREEMPT_LAZY) (NEW)
76717:Preemption behaviour defined on boot (PREEMPT_DYNAMIC) [N/y/?] (NEW) 
76718:Core Scheduling for SMT (SCHED_CORE) [N/y/?] (NEW) 
76723:> 1. Simple tick based cputime accounting (TICK_CPU_ACCOUNTING) (NEW)
76724:  2. Full dynticks CPU time accounting (VIRT_CPU_ACCOUNTING_GEN) (NEW)
76730:  Enable per-task delay accounting (TASK_DELAY_ACCT) [N/y/?] (NEW) 
76733:Pressure stall information tracking (PSI) [N/y/?] (NEW) 
76734:CPU isolation (CPU_ISOLATION) [Y/n/?] (NEW) 
76738:Make expert-level adjustments to RCU configuration (RCU_EXPERT) [N/y/?] (NEW) 
76741:Enable kernel headers through /sys/kernel/kheaders.tar.xz (IKHEADERS) [N/m/y/?] (NEW) 
76742:Kernel log buffer size (16 => 64KB, 17 => 128KB) (LOG_BUF_SHIFT) [17] (NEW) 
76743:CPU kernel log buffer size contribution (13 => 8 KB, 17 => 128KB) (LOG_CPU_MAX_BUF_SHIFT) [12] (NEW) 
76744:Printk indexing debugfs interface (PRINTK_INDEX) [N/y/?] (NEW) 
76748:Enable utilization clamping for RT/FAIR tasks (UCLAMP_TASK) [N/y/?] (NEW) 
76750:  Automatically enable NUMA aware memory/task placement (NUMA_BALANCING_DEFAULT_ENABLED) [Y/n/?] (NEW) 
76754:Control Group support (CGROUPS) [Y/?] (NEW) y
76755:  Favor dynamic modification latency reduction by default (CGROUP_FAVOR_DYNMODS) [N/y/?] (NEW) 
76757:    Legacy cgroup v1 memory controller (MEMCG_V1) [N/y/?] (NEW) 
76762:  CPU controller (CGROUP_SCHED) [Y/?] (NEW) y
76763:    Group scheduling for SCHED_OTHER (FAIR_GROUP_SCHED) [Y/?] (NEW) y
76764:      CPU bandwidth provisioning for FAIR_GROUP_SCHED (CFS_BANDWIDTH) [N/y/?] (NEW) 
```

## 缺失内核模块 .ko (去重, 已剔除 $mod 字面量噪声)
count: 1
```
$mod
```

## 5 个重点模块根因定位 (kmod 是否选中 / 符号解析值 / .ko 是否真编出来)

```
scsi_mod.ko                kmod=CONFIG_PACKAGE_kmod-scsi-core=y    sym=CONFIG_SCSI=m                              built=build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/modules/6.18.55/scsi_mod.ko
usbcore.ko                 kmod=CONFIG_PACKAGE_kmod-usb-core=y     sym=CONFIG_USB=m                               built=build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/modules/6.18.55/usbcore.ko
usb-common.ko              kmod=CONFIG_PACKAGE_kmod-usb-common=y   sym=CONFIG_USB_COMMON=m                        built=build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/modules/6.18.55/usb-common.ko
ledtrig-usbport.ko         kmod=CONFIG_PACKAGE_kmod-usb-ledtrig-usbport=y sym=CONFIG_USB_LEDS_TRIGGER_USBPORT=m          built=build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/modules/6.18.55/ledtrig-usbport.ko
userspace-consumer.ko      kmod=CONFIG_PACKAGE_kmod-regulator-userspace-consumer=y sym=CONFIG_REGULATOR_USERSPACE_CONSUMER=m      built=build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/modules/6.18.55/userspace-consumer.ko
```

解读: built=NO 且 sym==m  => 内核确实编了模块, 但 kmod FILES 路径写错 (6.18 模块搬家)。
      built=NO 且 sym==y 或 未设置 => 符号被内置/裁掉, 没编成可加载模块。
      built=有路径 => 模块已编出, 问题在别处。

## build.log 末 150 行
```
Enabling dnsmasq
Enabling done
Enabling dropbear
Enabling firewall
Enabling fstab
Enabling gpio_switch
Enabling iptv
Enabling led
Enabling log
Enabling network
Enabling odhcpd
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/share/openclash/uci.sh: line 2: /lib/functions.sh: No such file or directory
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/share/openclash/uci.sh: line 2: /lib/functions.sh: No such file or directory
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/share/openclash/openclash_curl.sh: line 2: /usr/share/openclash/log.sh: No such file or directory
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/share/openclash/openclash_curl.sh: line 3: /usr/share/openclash/openclash_etag.sh: No such file or directory
Enabling openclash
Enabling packet_steering
Enabling pon
Enabling rpcd
Enabling sysctl
Enabling sysfixtime
Enabling sysntpd
Enabling system
Enabling ubihealthd
Enabling ucitrack
Enabling uhttpd
Enabling umount
Enabling urandom_seed
Enabling urngd
Enabling zram
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/boot /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/tmp/* /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/lib/apk/db/*.post-install* /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/lib/opkg/info/*.postinst* /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/usr/lib/opkg/lists/* /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/var/lock/*.lock
find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/ -mindepth 1 -execdir touch -hcd "@1793700053" "{}" +
touch -hcd "@1793700053" /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/rootfs-cache-airoha
mkdir -p /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/rootfs-cache-airoha
cp -a /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/rootfs-cache-airoha/root
cp -a /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root.orig-airoha /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/rootfs-cache-airoha/root.orig
echo 2a0162a30dc89deaa71feaff4cac541687fdef495704d0d53761d0e7289d165d > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/rootfs-cache-airoha/key
make[2]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt'
make[2]: Entering directory '/home/runner/work/immortalwrt/immortalwrt'
make[3]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/target/linux'
make[4]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/target/linux/airoha'
rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/init
{ stamp=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.kbuild_image; key="$(printf '%s' 'make -C /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55 KCFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl -fno-caller-saves " KAFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl" HOSTCFLAGS="-O2 -I/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/include -Wall -Wmissing-prototypes -Wstrict-prototypes" CROSS_COMPILE="aarch64-openwrt-linux-musl-" ARCH="arm64" KBUILD_HAVE_NLS=no KBUILD_BUILD_USER="" KBUILD_BUILD_HOST="" KBUILD_BUILD_TIMESTAMP="Tue Nov  3 10:00:53 2026" KBUILD_BUILD_VERSION="0" KBUILD_HOSTLDFLAGS="-L/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/lib" CONFIG_SHELL="bash" V='\'''\''  cmd_syscalls=  CC="ccache aarch64-openwrt-linux-musl-gcc" KERNELRELEASE=6.18.55  Image dtbs' | /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mkhash md5)"; [ "$(cat $stamp 2>/dev/null)" = "$key" ] && [ -z "$(find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55 /home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/bin  \( -path '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.*' ! -path '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config' \) -prune -o ! -type d -newer $stamp -print -quit)" ] || { rm -f $stamp;  make -C /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55 KCFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl -fno-caller-saves " KAFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl" HOSTCFLAGS="-O2 -I/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/include -Wall -Wmissing-prototypes -Wstrict-prototypes" CROSS_COMPILE="aarch64-openwrt-linux-musl-" ARCH="arm64" KBUILD_HAVE_NLS=no KBUILD_BUILD_USER="" KBUILD_BUILD_HOST="" KBUILD_BUILD_TIMESTAMP="Tue Nov  3 10:00:53 2026" KBUILD_BUILD_VERSION="0" KBUILD_HOSTLDFLAGS="-L/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/lib" CONFIG_SHELL="bash" V=''  cmd_syscalls=  CC="ccache aarch64-openwrt-linux-musl-gcc" KERNELRELEASE=6.18.55  Image dtbs && echo "$key" > $stamp; }; }
make[5]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55'
  MODPOST vmlinux.symvers
make[5]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55'
cmp -s /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux.debug || { aarch64-openwrt-linux-musl-objcopy -O binary -R .reginfo -R .notes -R .note -R .comment -R .mdebug -R .note.gnu.build-id -S /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux; aarch64-openwrt-linux-musl-objcopy -R .reginfo -R .notes -R .note -R .comment -R .mdebug -R .note.gnu.build-id -S /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux.elf; cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux.debug;  cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/arch/arm64/boot//Image /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/Image;  }
SHELL= flock /home/runner/work/immortalwrt/immortalwrt/tmp/.gen-initramfs.flock -c '{   		{ rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config.prev; mv /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config.old; 	{ grep -v -e INITRAMFS -e CONFIG_RD_ -e CONFIG_BLK_DEV_INITRD /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config.old > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config; echo '\''CONFIG_BLK_DEV_INITRD=y'\'' >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config; echo '\''file /init /home/runner/work/immortalwrt/immortalwrt/target/linux/generic/other-files/init 0755 0 0'\'' > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55.init-cpio-list; echo '\''CONFIG_INITRAMFS_SOURCE="/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55.init-cpio-list /home/runner/work/immortalwrt/immortalwrt/target/linux/generic/image/initramfs-base-files.txt"'\'' >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config; }; echo "# CONFIG_INITRAMFS_PRESERVE_MTIME is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config; echo "CONFIG_INITRAMFS_ROOT_UID=1001" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config; echo "CONFIG_INITRAMFS_ROOT_GID=1001" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;  echo "# CONFIG_INITRAMFS_FORCE is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;  echo "CONFIG_INITRAMFS_COMPRESSION_NONE=y" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;   echo "# CONFIG_INITRAMFS_COMPRESSION_GZIP is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_LZMA is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_LZO is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_XZ is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_LZ4 is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_INITRAMFS_COMPRESSION_ZSTD is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;   	  echo "# CONFIG_RD_GZIP is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_BZIP2 is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_LZMA is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_LZO is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_XZ is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_LZ4 is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;     echo "# CONFIG_RD_ZSTD is not set" >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config;   }; rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/usr/initramfs_data.cpio*;  make -C /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55 KCFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl -fno-caller-saves " KAFLAGS="-fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl=target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl=staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl" HOSTCFLAGS="-O2 -I/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/include -Wall -Wmissing-prototypes -Wstrict-prototypes" CROSS_COMPILE="aarch64-openwrt-linux-musl-" ARCH="arm64" KBUILD_HAVE_NLS=no KBUILD_BUILD_USER="" KBUILD_BUILD_HOST="" KBUILD_BUILD_TIMESTAMP="Tue Nov  3 10:00:53 2026" KBUILD_BUILD_VERSION="0" KBUILD_HOSTLDFLAGS="-L/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/lib" CONFIG_SHELL="bash" V='\'''\''  cmd_syscalls=  CC="ccache aarch64-openwrt-linux-musl-gcc" KERNELRELEASE=6.18.55   Image dtbs; 	cmp -s /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux-initramfs.debug || { aarch64-openwrt-linux-musl-objcopy -O binary -R .reginfo -R .notes -R .note -R .comment -R .mdebug -R .note.gnu.build-id -S /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux-initramfs; aarch64-openwrt-linux-musl-objcopy -R .reginfo -R .notes -R .note -R .comment -R .mdebug -R .note.gnu.build-id -S /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux-initramfs.elf; cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/vmlinux /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/vmlinux-initramfs.debug;  cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/arch/arm64/boot//Image /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/Image-initramfs;  };  }';
make[5]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/target/linux/airoha'
make[5]: warning: jobserver unavailable: using -j1.  Add '+' to parent make rule.
  SYNC    include/config/auto.conf.cmd
  GEN     usr/initramfs_data.cpio
sort: write failed: 'standard output': Broken pipe
sort: write error
  COPY    usr/initramfs_inc_data
  AS      usr/initramfs_data.o
  AR      usr/built-in.a
  AR      built-in.a
  AR      vmlinux.a
  LD      vmlinux.o
  MODPOST vmlinux.symvers
  KSYMS   .tmp_vmlinux0.kallsyms.S
  AS      .tmp_vmlinux0.kallsyms.o
  LD      .tmp_vmlinux1
  NM      .tmp_vmlinux1.syms
  KSYMS   .tmp_vmlinux1.kallsyms.S
  AS      .tmp_vmlinux1.kallsyms.o
  LD      .tmp_vmlinux2
  NM      .tmp_vmlinux2.syms
  KSYMS   .tmp_vmlinux2.kallsyms.S
  AS      .tmp_vmlinux2.kallsyms.o
  LD      vmlinux.unstripped
  NM      System.map
  SORTTAB vmlinux.unstripped
  OBJCOPY vmlinux
  GEN     modules.builtin.modinfo
  GEN     modules.builtin
  OBJCOPY arch/arm64/boot/Image
make[5]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55'
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.image
{ state="$( ( cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha && find . -printf '%P %y %m %U %G %s %l\n' | LC_ALL=C sort && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 -r cat; ) | /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mkhash sha256; find /home/runner/work/immortalwrt/immortalwrt/bin/targets/airoha/an7581 -maxdepth 1 -type f ! -name sha256sums ! -name profiles.json ! -name '*.buildinfo' -printf '%f %s\n' 2>/dev/null | LC_ALL=C sort; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/json_info_files -maxdepth 1 -type f -printf '%f %s\n' 2>/dev/null | LC_ALL=C sort )"; [ "$state" = "$(cat /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/.image_install 2>/dev/null)" ] && [ -z "$(find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581 -maxdepth 1 ! -type d -newer /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/.image_install -print -quit 2>/dev/null; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55 /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/image /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin /home/runner/work/immortalwrt/immortalwrt/target/linux/airoha /home/runner/work/immortalwrt/immortalwrt/include /home/runner/work/immortalwrt/immortalwrt/scripts /home/runner/work/immortalwrt/immortalwrt/.config \( -path '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.*' ! -path '/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/.config' \) -prune -o ! -type d -newer /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/.image_install -print -quit 2>/dev/null)" ] || { rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/.image_install; make -C image compile install TARGET_BUILD= && { ( cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha && find . -printf '%P %y %m %U %G %s %l\n' | LC_ALL=C sort && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 -r cat; ) | /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mkhash sha256; find /home/runner/work/immortalwrt/immortalwrt/bin/targets/airoha/an7581 -maxdepth 1 -type f ! -name sha256sums ! -name profiles.json ! -name '*.buildinfo' -printf '%f %s\n' 2>/dev/null | LC_ALL=C sort; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/json_info_files -maxdepth 1 -type f -printf '%f %s\n' 2>/dev/null | LC_ALL=C sort; } > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/.image_install; }; }
make[5]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/target/linux/airoha/image'
make[5]: Nothing to be done for 'compile'.
aarch64-openwrt-linux-musl-cpp -nostdinc -x assembler-with-cpp  -I/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/arch/arm64/boot/dts -I/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/arch/arm64/boot/dts/include -I/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/include/ -I/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/scripts/dtc/include-prefixes -undef -D__DTS__  -o /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/image-an7581-nokia_xg-040g-md-ubi.dtb.tmp ../dts/an7581-nokia_xg-040g-md-ubi.dts
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/target-dir-6fea00b3
cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root.orig-airoha /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/target-dir-6fea00b3
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/scripts/dtc/dtc -O dtb -i../dts/ -Wno-interrupt_provider -Wno-unique_unit_address -Wno-unit_address_vs_reg -Wno-avoid_unnecessary_addr_size -Wno-alias_paths -Wno-graph_child_address -Wno-simple_bus_reg   -@ -o /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/image-an7581-nokia_xg-040g-md-ubi.dtb /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/image-an7581-nokia_xg-040g-md-ubi.dtb.tmp
../dts/an7581.dtsi:353.12-355.5: Warning (sound_dai_property): /sound/platform: Missing property '#sound-dai-cells' in node /soc/afe@1fbe2200 or bad phandle (referred from sound-dai[0])
rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/image-an7581-nokia_xg-040g-md-ubi.dtb.tmp
mkdir -p /home/runner/work/immortalwrt/immortalwrt/bin/targets/airoha/an7581 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/tmp
IPKG_INSTROOT=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/target-dir-6fea00b3 /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/fakeroot /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/apk --root /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/target-dir-6fea00b3 --keys-dir /home/runner/work/immortalwrt/immortalwrt --no-logfile --preserve-env --no-scripts --repositories-file /dev/null --repository file:///home/runner/work/immortalwrt/immortalwrt/staging_dir/packages/airoha/packages.adb add kmod-gpio-button-hotplug kmod-leds-gpio kmod-phy-airoha-en8811h kmod-regulator-userspace-consumer kmod-usb-ledtrig-usbport kmod-usb3 automount kmod-airoha-en7572 kmod-airoha-xpon airoha-ponctl airoha-pond fitblk
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/json_info_files
/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mksquashfs4 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/root.squashfs -nopad -noappend -root-owned -comp xz -Xpreset 9 -Xe -Xlc 0 -Xlp 2 -Xpb 2  -b 256k -p '/dev d 755 0 0' -p '/dev/console c 600 0 0 5 1' -no-xattrs -block-readers 4 -small-readers 4
rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/nokia_xg-040g-md-ubi-uImage.itb
cp /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/Image /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/nokia_xg-040g-md-ubi-uImage.itb
/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/gzip -f -9n -c /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/nokia_xg-040g-md-ubi-uImage.itb  > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/nokia_xg-040g-md-ubi-uImage.itb.new
Pseudo file "dev" exists in source filesystem "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/root-airoha/dev".
Ignoring, exclude it (-e/-ef) to override.
Parallel mksquashfs: Using 4 processors
Creating 4.0 filesystem on /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/root.squashfs, block size 262144.
[|                                                             ]    0/1738   0%WARNING: opening file:///home/runner/work/immortalwrt/immortalwrt/staging_dir/packages/airoha/packages.adb: UNTRUSTED signature
ERROR: unable to select packages:
  automount (no such package):
    required by: world[automount]
  fitblk (no such package):
    required by: world[fitblk]
make[5]: *** [/home/runner/work/immortalwrt/immortalwrt/include/image.mk:385: target-dir-6fea00b3] Error 2
[=============================================================/] 1829/1829 100%

Exportable Squashfs 4.0 filesystem, xz compressed, data block size 262144
	compressed data, compressed metadata, compressed fragments,
	no xattrs, compressed ids
	duplicates are removed
Filesystem size 18383.32 Kbytes (17.95 Mbytes)
	31.80% of uncompressed filesystem size (57810.37 Kbytes)
Inode table size 15898 bytes (15.53 Kbytes)
	22.44% of uncompressed inode table size (70860 bytes)
Directory table size 22560 bytes (22.03 Kbytes)
	48.27% of uncompressed directory table size (46736 bytes)
Number of duplicate files found 28
Number of inodes 2124
Number of files 1614
Number of fragments 82
Number of symbolic links 296
Number of device nodes 1
Number of fifo nodes 0
Number of socket nodes 0
Number of directories 213
Number of hard-links 0
Number of ids (unique uids + gids) 1
Number of uids 1
	root (0)
Number of gids 1
	root (0)
make[5]: Target 'install' not remade because of errors.
make[5]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/target/linux/airoha/image'
make[4]: *** [Makefile:15: install] Error 2
make[4]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/target/linux/airoha'
make[3]: *** [Makefile:12: install] Error 2
make[3]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/target/linux'
time: target/linux/install#25.57#10.89#22.82
    ERROR: target/linux failed to build.
make[2]: *** [target/Makefile:30: target/linux/install] Error 1
make[2]: Target 'target/install' not remade because of errors.
make[2]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt'
make[1]: *** [target/Makefile:26: /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/stamp/.target_install] Error 2
make[1]: Target 'world' not remade because of errors.
make[1]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt'
make: *** [/home/runner/work/immortalwrt/immortalwrt/include/toplevel.mk:268: world] Error 2
```
