# Kernel patches

## 0001-bpf-5.10.236-to-5.10.269.patch

Extracted from Linux stable `v5.10.236..v5.10.269`, limited to the BPF
subsystem:

- `kernel/bpf/*`
- `include/linux/bpf*.h`
- `include/uapi/linux/bpf.h`
- `include/trace/events/bpf*.h`
- `net/core/filter.c`
- `net/core/sock_map.c`
- `net/core/skmsg.c`
- `net/core/sysctl_net_core.c`
- `kernel/trace/bpf_trace.c`

This is the same direction used by Xiaomi-MT6896-OSS: their `lineage-24.0`
kernel is 5.10.269 with the `android12-5.10` BPF fixes, while the qqcandy
OnePlusOSS branch is a 5.10.236 vendor drop.

The patch applies cleanly to:

```bash
git clone -b oneplus/mt6895_v_15.0.0_ace_race \
    https://github.com/OnePlusOSS/android_kernel_5.10_oneplus_mt6895.git
cd android_kernel_5.10_oneplus_mt6895
git apply --check /path/to/0001-bpf-5.10.236-to-5.10.269.patch
```

Apply it with:

```bash
git apply /path/to/0001-bpf-5.10.236-to-5.10.269.patch
```

Do not mix a source-built `Image.gz` with the 5.10.209 prebuilt modules. Build
the matching modules from the same source tree, or keep the complete prebuilt
5.10.209 set.
