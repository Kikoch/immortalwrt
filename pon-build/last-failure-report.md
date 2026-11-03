# Build failure report — run 19

head_sha: b06134f8aad381b6020b86c50fc86bcad7daf343
time: 2026-11-03T09:25:55Z

## syncconfig 是否中止 (NEW 提示导致 Error 1)?
no (仅 (NEW) 提示, 未中止)

### syncconfig (NEW) 提示行
```
76677:Compile also drivers which will not load (COMPILE_TEST) [N/y/?] (NEW) 
76678:Compile the kernel with warnings as errors (WERROR) [N/y/?] (NEW) 
76679:Local version - append to kernel release (LOCALVERSION) [] (NEW) 
76680:Automatically append version information to the version string (LOCALVERSION_AUTO) [Y/n/?] (NEW) 
76681:Build ID Salt (BUILD_SALT) [] (NEW) 
76682:Default init path (DEFAULT_INIT) [] (NEW) 
76683:Default hostname (DEFAULT_HOSTNAME) [(none)] (NEW) 
76686:General notification queue (WATCH_QUEUE) [N/y/?] (NEW) 
76687:Enable process_vm_readv/writev syscalls (CROSS_MEMORY_ATTACH) [Y/n/?] (NEW) 
76692:Expose irq internals in debugfs (GENERIC_IRQ_DEBUGFS) [N/y/?] (NEW) 
76697:  1. Periodic timer ticks (constant rate, no dynticks) (HZ_PERIODIC) (NEW)
76699:  3. Full dynticks system (tickless) (NO_HZ_FULL) (NEW)
76701:Old Idle dynticks config (NO_HZ) [N/y/?] (NEW) 
76703:Enable auxiliary POSIX clocks (POSIX_AUX_CLOCKS) [N/y/?] (NEW) 
76709:  Permanently enable BPF JIT and remove BPF interpreter (BPF_JIT_ALWAYS_ON) [N/y/?] (NEW) 
76710:Disable unprivileged BPF by default (BPF_UNPRIV_DEFAULT_OFF) [Y/n/?] (NEW) 
76714:Preload BPF file system with kernel specific program and map iterators (BPF_PRELOAD) [N/y/?] (NEW) 
76716:  1. No Forced Preemption (Server) (PREEMPT_NONE) (NEW)
76717:  2. Voluntary Kernel Preemption (Desktop) (PREEMPT_VOLUNTARY) (NEW)
76719:  4. Scheduler controlled preemption model (PREEMPT_LAZY) (NEW)
76721:Preemption behaviour defined on boot (PREEMPT_DYNAMIC) [N/y/?] (NEW) 
76722:Core Scheduling for SMT (SCHED_CORE) [N/y/?] (NEW) 
76727:> 1. Simple tick based cputime accounting (TICK_CPU_ACCOUNTING) (NEW)
76728:  2. Full dynticks CPU time accounting (VIRT_CPU_ACCOUNTING_GEN) (NEW)
76734:  Enable per-task delay accounting (TASK_DELAY_ACCT) [N/y/?] (NEW) 
76737:Pressure stall information tracking (PSI) [N/y/?] (NEW) 
76738:CPU isolation (CPU_ISOLATION) [Y/n/?] (NEW) 
76742:Make expert-level adjustments to RCU configuration (RCU_EXPERT) [N/y/?] (NEW) 
76745:Enable kernel headers through /sys/kernel/kheaders.tar.xz (IKHEADERS) [N/m/y/?] (NEW) 
76746:Kernel log buffer size (16 => 64KB, 17 => 128KB) (LOG_BUF_SHIFT) [17] (NEW) 
76747:CPU kernel log buffer size contribution (13 => 8 KB, 17 => 128KB) (LOG_CPU_MAX_BUF_SHIFT) [12] (NEW) 
76748:Printk indexing debugfs interface (PRINTK_INDEX) [N/y/?] (NEW) 
76752:Enable utilization clamping for RT/FAIR tasks (UCLAMP_TASK) [N/y/?] (NEW) 
76754:  Automatically enable NUMA aware memory/task placement (NUMA_BALANCING_DEFAULT_ENABLED) [Y/n/?] (NEW) 
76758:Control Group support (CGROUPS) [Y/?] (NEW) y
76759:  Favor dynamic modification latency reduction by default (CGROUP_FAVOR_DYNMODS) [N/y/?] (NEW) 
76761:    Legacy cgroup v1 memory controller (MEMCG_V1) [N/y/?] (NEW) 
76766:  CPU controller (CGROUP_SCHED) [Y/?] (NEW) y
76767:    Group scheduling for SCHED_OTHER (FAIR_GROUP_SCHED) [Y/?] (NEW) y
76768:      CPU bandwidth provisioning for FAIR_GROUP_SCHED (CFS_BANDWIDTH) [N/y/?] (NEW) 
```

## 缺失内核模块 .ko (去重, 已剔除 $mod 字面量噪声)
count: 2
```
$mod
/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/linux-6.18.55/drivers/scsi/scsi_mod.ko
```

## 5 个重点模块根因定位 (kmod 是否选中 / 符号解析值 / .ko 是否真编出来)

```
scsi_mod.ko                kmod=CONFIG_PACKAGE_kmod-scsi-core=y    sym=<无>                                      built=NO
usbcore.ko                 kmod=CONFIG_PACKAGE_kmod-usb-core=y     sym=<无>                                      built=build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/packages/.pkgdir/kmod-usb-core/lib/modules/6.18.55/usbcore.ko
usb-common.ko              kmod=CONFIG_PACKAGE_kmod-usb-common=y   sym=<无>                                      built=build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/packages/.pkgdir/kmod-usb-common/lib/modules/6.18.55/usb-common.ko
ledtrig-usbport.ko         kmod=CONFIG_PACKAGE_kmod-usb-ledtrig-usbport=y sym=<无>                                      built=build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/packages/.pkgdir/kmod-usb-ledtrig-usbport/lib/modules/6.18.55/ledtrig-usbport.ko
userspace-consumer.ko      kmod=CONFIG_PACKAGE_kmod-regulator-userspace-consumer=y sym=<无>                                      built=build_dir/target-aarch64_cortex-a53_musl/linux-airoha_an7581/packages/.pkgdir/kmod-regulator-userspace-consumer/lib/modules/6.18.55/userspace-consumer.ko
```

解读: built=NO 且 sym==m  => 内核确实编了模块, 但 kmod FILES 路径写错 (6.18 模块搬家)。
      built=NO 且 sym==y 或 未设置 => 符号被内置/裁掉, 没编成可加载模块。
      built=有路径 => 模块已编出, 问题在别处。

## build.log 末 150 行
```
[1m[92m   Compiling[0m tracing-chrome v0.7.2
[1m[92m   Compiling[0m toml_edit v0.25.10+spec-1.1.0
[1m[92m   Compiling[0m sha1 v0.11.0
[1m[92m   Compiling[0m hmac v0.13.0
[1m[92m   Compiling[0m rustfix v0.9.6 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/src/tools/cargo/crates/rustfix)
[1m[92m   Compiling[0m http v1.4.0
[1m[92m   Compiling[0m serde_ignored v0.1.14
[1m[92m   Compiling[0m cargo-platform v0.3.3 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/src/tools/cargo/crates/cargo-platform)
[1m[92m   Compiling[0m opener v0.8.4
[1m[92m   Compiling[0m async-trait v0.1.89
[1m[92m   Compiling[0m http-auth v0.1.10
[1m[92m   Compiling[0m rustc-hash v2.1.2
[1m[92m   Compiling[0m futures-timer v3.0.3
[1m[92m   Compiling[0m pathdiff v0.2.3
[1m[92m   Compiling[0m heck v0.5.0
[1m[92m   Compiling[0m rustc-stable-hash v0.1.2
[1m[92m   Compiling[0m home v0.5.12
[1m[92m   Compiling[0m glob v0.3.3
[1m[92m   Compiling[0m unicase v2.9.0
[1m[92m   Compiling[0m gix-transport v0.55.1
[1m[92m   Compiling[0m crates-io v0.40.19 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/src/tools/cargo/crates/crates-io)
[1m[92m   Compiling[0m gix-protocol v0.59.0
[1m[92m   Compiling[0m gix v0.81.0
[1m[92m   Compiling[0m git2 v0.20.4
[1m[92m   Compiling[0m git2-curl v0.21.0
[1m[92m    Finished[0m `release` profile [optimized] target(s) in 6m 30s
::endgroup::
Dist cargo-1.96.0-x86_64-unknown-linux-gnu
	finished in 0.687 seconds
Dist llvm-tools-1.96.0-x86_64-unknown-linux-gnu
	finished in 7.765 seconds
Dist rust-src-1.96.0
	finished in 0.830 seconds
Build completed successfully in 1:59:32
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/.built
( cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/build/dist ; for targz in *.tar.gz; do /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/libdeflate-gzip -dc "$targz" | tar -xf - ; done ; find . -mindepth 2 -maxdepth 2 -type f -name install.sh -execdir bash '{}' --prefix=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host --disable-ldconfig \; ; )
install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'rust-std-x86_64-unknown-linux-gnu'

    rust std installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'rust-src'

    rust src installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'build-manifest'

    build manifest installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'rust-std-aarch64-unknown-linux-musl'

    rust std installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'llvm-tools-preview'

    llvm tools installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'rustc'

    rustc installed.

install: creating uninstall script at /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/host/lib/rustlib/uninstall.sh
install: installing component 'cargo'

    cargo installed.

find /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/lib -name '*.la' | xargs -r rm -f;
mkdir -p /home/runner/work/immortalwrt/immortalwrt/staging_dir/hostpkg/stamp
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/host/rustc-1.96.0-src/.built
touch /home/runner/work/immortalwrt/immortalwrt/staging_dir/hostpkg/stamp/.rust_installed 
make[3]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/feeds/packages/lang/rust'
time: package/feeds/packages/rust/host-compile#21399.33#1603.55#7233.96
make[3]: Entering directory '/home/runner/work/immortalwrt/immortalwrt/package/airoha-pon/airoha-ponctl'
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.prepared_91852ef0c44acf38ba30a5d11c1ae3da_6664517399ebbbc92a37c5bb081b5c53_check
mkdir -p /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0
cp -fpR ./src/Cargo.toml ./src/Cargo.lock /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/
cp -fpR ./src/src /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.prepared_91852ef0c44acf38ba30a5d11c1ae3da_6664517399ebbbc92a37c5bb081b5c53
rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.configured_*
rm -f /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/stamp/.airoha-ponctl_installed
(cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/./; if [ -x ./configure ]; then find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ -name config.guess | xargs -r chmod u+w; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ -name config.guess | xargs -r -n1 cp --remove-destination /home/runner/work/immortalwrt/immortalwrt/scripts/config.guess; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ -name config.sub | xargs -r chmod u+w; find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ -name config.sub | xargs -r -n1 cp --remove-destination /home/runner/work/immortalwrt/immortalwrt/scripts/config.sub; AR="aarch64-openwrt-linux-musl-gcc-ar" AS="ccache aarch64-openwrt-linux-musl-gcc -c -Os -pipe -mcpu=cortex-a53 -fno-caller-saves -fno-plt -fhonour-copts -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0=airoha-ponctl-0.2.0 -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -Wl,-z,max-page-size=4096 -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -Wl,-z,pack-relative-relocs" LD="aarch64-openwrt-linux-musl-ld.bfd" NM="aarch64-openwrt-linux-musl-gcc-nm" CC="ccache aarch64-openwrt-linux-musl-gcc" GCC="ccache aarch64-openwrt-linux-musl-gcc" CXX="ccache aarch64-openwrt-linux-musl-g++" RANLIB="aarch64-openwrt-linux-musl-gcc-ranlib" STRIP=aarch64-openwrt-linux-musl-strip OBJCOPY=aarch64-openwrt-linux-musl-objcopy OBJDUMP=aarch64-openwrt-linux-musl-objdump SIZE=aarch64-openwrt-linux-musl-size CFLAGS="-Os -pipe -mcpu=cortex-a53 -fno-caller-saves -fno-plt -fhonour-copts -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0=airoha-ponctl-0.2.0 -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -Wl,-z,max-page-size=4096 -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -Wl,-z,pack-relative-relocs " CXXFLAGS="-Os -pipe -mcpu=cortex-a53 -fno-caller-saves -fno-plt -fhonour-copts -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0=airoha-ponctl-0.2.0 -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -Wl,-z,max-page-size=4096 -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -Wl,-z,pack-relative-relocs " CPPFLAGS="-I/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/usr/include -I/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/include -I/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/include/fortify " LDFLAGS="-L/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/usr/lib -L/home/runner/work/immortalwrt/immortalwrt/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.4.0_musl/lib -fuse-ld=bfd -zmax-page-size=4096 -znow -zrelro -zpack-relative-relocs "   ./configure --target=aarch64-openwrt-linux --host=aarch64-openwrt-linux --build=x86_64-pc-linux-gnu --disable-dependency-tracking --program-prefix="" --program-suffix="" --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --libexecdir=/usr/lib --sysconfdir=/etc --datadir=/usr/share --localstatedir=/var --mandir=/usr/man --infodir=/usr/info --disable-nls  ; fi; )
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.configured_68b329da9893e34099c7d8ad5cb9c940
rm -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.built
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.built_check
CARGO_BUILD_TARGET=aarch64-unknown-linux-musl CARGO_HOME=/home/runner/work/immortalwrt/immortalwrt/dl/cargo CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1 CARGO_PROFILE_RELEASE_DEBUG=false CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS=false CARGO_PROFILE_RELEASE_LTO=true CARGO_PROFILE_RELEASE_OPT_LEVEL=z CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS=true CARGO_PROFILE_RELEASE_PANIC=unwind CARGO_PROFILE_RELEASE_RPATH=false CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-openwrt-linux-musl-gcc RUSTFLAGS="-Ctarget-feature=-crt-static -lssp_nonshared  -Clink-arg=-fuse-ld=bfd" TARGET_CC=aarch64-openwrt-linux-musl-gcc TARGET_CFLAGS="-Os -pipe -mcpu=cortex-a53 -fno-caller-saves -fno-plt -fhonour-copts -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0=airoha-ponctl-0.2.0 -fmacro-prefix-map=/home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl=staging_dir/target-aarch64_cortex-a53_musl -Wl,-z,max-page-size=4096 -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro -Wl,-z,pack-relative-relocs -mno-outline-atomics" CC=/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/gcc MAKEFLAGS="--jobserver-auth=3,4 " cargo install -v --profile release  --root /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-install --path "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/."  --locked 
  Installing airoha-ponctl v0.2.0 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0)
   Compiling airoha-ponctl v0.2.0 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0)
     Running `rustc --crate-name ponctl --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --crate-type bin --emit=dep-info,link -C opt-level=z -C lto -C codegen-units=1 -C overflow-checks=on --check-cfg 'cfg(docsrs,test)' --check-cfg 'cfg(feature, values())' -C metadata=4542ccb197a5bb7b -C extra-filename=-47192ca873e17a76 --out-dir /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/target/aarch64-unknown-linux-musl/release/deps --target aarch64-unknown-linux-musl -C linker=aarch64-openwrt-linux-musl-gcc -C strip=symbols -L dependency=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/target/aarch64-unknown-linux-musl/release/deps -L dependency=/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/target/release/deps -Ctarget-feature=-crt-static -lssp_nonshared -Clink-arg=-fuse-ld=bfd`
    Finished `release` profile [optimized] target(s) in 4.29s
  Installing /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-install/bin/ponctl
   Installed package `airoha-ponctl v0.2.0 (/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0)` (executable `ponctl`)
warning: be sure to add `/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-install/bin` to your PATH to be able to run the installed binaries
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.built
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl
mkdir -p /home/runner/work/immortalwrt/immortalwrt/bin/targets/airoha/an7581/packages /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/pkginfo
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/usr/sbin
install -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-install/bin/ponctl /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/usr/sbin/
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/etc/config
install -m0600 ./files/pon.config /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/etc/config/pon
chmod 0600 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/etc/config/pon
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/etc/init.d
install -m0755 ./files/pon.init /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/etc/init.d/pon
find /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl -name '.svn' -o -name '.#*' -o -name '*~'| xargs -r rm -rf
export CROSS="aarch64-openwrt-linux-musl-"  NO_RENAME=1 ; NM="aarch64-openwrt-linux-musl-nm" STRIP="/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/sstrip -z" STRIP_KMOD="/home/runner/work/immortalwrt/immortalwrt/scripts/strip-kmod.sh" PATCHELF="/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/patchelf" /home/runner/work/immortalwrt/immortalwrt/scripts/rstrip.sh /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl
rstrip.sh: /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/usr/sbin/ponctl: executable
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/bin/packages/aarch64_cortex-a53/base
mkdir -p /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/
mkdir -p /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/
(cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl; echo "$V_Package_airoha_ponctl_conffiles" > conffiles; )
( echo "#!/bin/sh"; echo "[ \"\${IPKG_NO_SCRIPT}\" = \"1\" ] && exit 0"; echo "[ -s "\${IPKG_INSTROOT}/lib/functions.sh" ] || exit 0"; echo ". \${IPKG_INSTROOT}/lib/functions.sh"; echo 'export root="${IPKG_INSTROOT}"'; echo 'export pkgname="airoha-ponctl"'; echo "add_group_and_user"; echo "default_postinst"; [ ! -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/postinst-pkg ] || sed '/^\s*#!/d' "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/postinst-pkg"; ) > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-install;
( echo "#!/bin/sh"; echo 'export PKG_UPGRADE=1'; [ ! -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-install ] || sed '/^\s*#!/d' "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-install"; ) > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-upgrade;
( echo "#!/bin/sh"; echo "[ -s "\${IPKG_INSTROOT}/lib/functions.sh" ] || exit 0"; echo ". \${IPKG_INSTROOT}/lib/functions.sh"; echo 'export root="${IPKG_INSTROOT}"'; echo 'export pkgname="airoha-ponctl"'; echo "default_prerm"; [ ! -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/prerm-pkg ] || sed '/^\s*#!/d' "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/prerm-pkg"; ) > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/pre-deinstall;
[ ! -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/postrm ] || sed -zi 's/^\s*#!/#!/' "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/postrm";
if [ -n "" ]; then echo  > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.rusers; fi;
if [ -n "" ]; then echo  > /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.alternatives; fi;
(cd /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl && find . -type f,l -printf "/%P\n" | sort > /home/runner/work/immortalwrt/immortalwrt/tmp/airoha-ponctl.list && mv /home/runner/work/immortalwrt/immortalwrt/tmp/airoha-ponctl.list /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.list)
# Move conffiles to IDIR and build conffiles_static with csums
if [ -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/conffiles ]; then mv -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/conffiles /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.conffiles; for file in $(cat /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.conffiles); do [ -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/$file ] || continue; csum=$(/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mkhash sha256 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/$file); echo $file $csum >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.conffiles_static; done; fi
# Some package (base-files) manually append stuff to conffiles
# Append stuff from it and delete the CONTROL directory since everything else should be migrated
if [ -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL/conffiles ]; then echo $(IDIR_airoha-ponctl)/CONTROL/conffiles >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.conffiles; for file in $(cat /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL/conffiles); do [ -f /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/$file ] || continue; csum=$(/home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/mkhash sha256 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/$file); echo $file $csum >> /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/lib/apk/packages/airoha-ponctl.conffiles_static; done; rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL/conffiles; fi
if [ -z "$(ls -A /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL 2>/dev/null)" ]; then rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL; else echo "CONTROL directory /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl/CONTROL is not empty! This is not right and should be checked!" >&2; exit 1; fi
SOURCE_DATE_EPOCH=0 /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/fakeroot /home/runner/work/immortalwrt/immortalwrt/staging_dir/host/bin/apk mkpkg --info "name:airoha-ponctl" --info "version:0.2.0-r1" --info "tags:openwrt:section=net"  --info "description:Configures PON mode, identity, status and data paths." --info "arch:aarch64_cortex-a53" --info "license:GPL-2.0-only" --info "origin:feeds/base/airoha-pon/airoha-ponctl" --info "url:https://github.com/pbs05/openwrt-pon-userspace/tree/main/airoha-ponctl" --info "maintainer:" --info "provides:airoha-ponctl-any"  --script "post-install:/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-install" --script "post-upgrade:/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/post-upgrade" --script "pre-deinstall:/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/apk-aarch64_cortex-a53/airoha-ponctl/pre-deinstall" --info "depends:libc kmod-airoha-xpon" --files "/home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-aarch64_cortex-a53/airoha-ponctl" --sign /home/runner/work/immortalwrt/immortalwrt/private-key.pem --output "/home/runner/work/immortalwrt/immortalwrt/bin/packages/aarch64_cortex-a53/base/airoha-ponctl-0.2.0-r1.apk"
rm -rf /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl.installed /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl
mkdir -p /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/usr/sbin
install -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/ipkg-install/bin/ponctl /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/usr/sbin/
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/etc/config
install -m0600 ./files/pon.config /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/etc/config/pon
chmod 0600 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/etc/config/pon
install -d -m0755 /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/etc/init.d
install -m0755 ./files/pon.init /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/etc/init.d/pon
touch /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl.installed
mkdir -p /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/root-airoha/stamp
SHELL= flock /home/runner/work/immortalwrt/immortalwrt/tmp/.root-copy.flock -c 'cp -fpR /home/runner/work/immortalwrt/immortalwrt/build_dir/target-aarch64_cortex-a53_musl/airoha-ponctl-0.2.0/.pkgdir/airoha-ponctl/. /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/root-airoha/'
touch /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/root-airoha/stamp/.airoha-ponctl_installed
echo "airoha-ponctl" >> /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/pkginfo/airoha-ponctl.default.install
make[3]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt/package/airoha-pon/airoha-ponctl'
time: package/airoha-pon/airoha-ponctl/compile#4.25#0.33#4.66
make[2]: Target 'package/compile' not remade because of errors.
make[2]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt'
make[1]: *** [package/Makefile:251: /home/runner/work/immortalwrt/immortalwrt/staging_dir/target-aarch64_cortex-a53_musl/stamp/.package_compile] Error 2
make[1]: Target 'world' not remade because of errors.
make[1]: Leaving directory '/home/runner/work/immortalwrt/immortalwrt'
make: *** [/home/runner/work/immortalwrt/immortalwrt/include/toplevel.mk:268: world] Error 2
```
