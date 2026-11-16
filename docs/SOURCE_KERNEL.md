# Source kernel notes

The default tree uses the **prebuilt 5.10.209** kernel from the PGZ110
15.0.0.501 dump. This is the safest first-boot option because the kernel,
DTB, DTBO and all 535 modules come from the same vendor build.

## Public OSS source

OnePlus publishes the qqcandy kernel and MTK modules:

- `https://github.com/OnePlusOSS/android_kernel_5.10_oneplus_mt6895`
  branch `oneplus/mt6895_v_15.0.0_ace_race`
- `https://github.com/OnePlusOSS/android_vendor_mediatek_kernel_modules_mt6895`
  branch `oneplus/mt6895_v_15.0.0_ace_race`

The public branch is newer than the dump (5.10.236 vs 5.10.209) and is
actively synchronized (last commit at the time of writing: PGZ110
15.0.0.1600).

## Known source-tree gap

`arch/arm64/boot/dts/mediatek/k6895v1_64.dts` includes:

```c
#include <k6895v1_64/cust.dtsi>
```

The public OSS tree does **not** ship `k6895v1_64/cust.dtsi`. It also does not
ship the full qqcandy board DTS set; only `cust_mt6895_qqcandy_thermal.dtsi`
and the SN100 NFC fragment are present. Therefore:

- A source-built `Image.gz` is possible.
- The board DTB/DTBO still needs either the prebuilt qqcandy DTB/DTBO or a
  ported `cust.dtsi` from a vendor source drop.
- Do not mix a 5.10.236 kernel with 5.10.209 vendor modules. `vermagic`
  mismatches will make modules fail to load.

## BPF compatibility

Xiaomi-MT6896-OSS uses a 5.10.269 kernel with the `android12-5.10` stable
backports. The qqcandy OnePlusOSS branch is a 5.10.236 vendor drop. The BPF
difference between those two stable points is small:

- 14 files
- 354 insertions / 213 deletions
- 40 KB patch

It is stored at:

```
device/oplus/qqcandy/kernel-patches/0001-bpf-5.10.236-to-5.10.269.patch
```

It applies cleanly to the qqcandy OnePlusOSS kernel:

```bash
git clone -b oneplus/mt6895_v_15.0.0_ace_race \
    https://github.com/OnePlusOSS/android_kernel_5.10_oneplus_mt6895.git
cd android_kernel_5.10_oneplus_mt6895
git apply --check /path/to/0001-bpf-5.10.236-to-5.10.269.patch
```

This avoids replacing the whole vendor kernel with the Xiaomi tree. The
remaining source-kernel work is building the matching modules and keeping the
qqcandy DTB/DTBO until `k6895v1_64/cust.dtsi` is ported.

## Suggested source-kernel workflow

1. Keep the current prebuilt `Image.gz`, `dtb/mt6895.dtb`, `dtbo.img` and
   modules as the known-good baseline.
2. Clone the OnePlusOSS qqcandy kernel and apply
   `kernel-patches/0001-bpf-5.10.236-to-5.10.269.patch`.
3. Build the OSS kernel separately with its `build/build.sh` and
   `mgk_64_k510_defconfig` (or the matching GKI + `mgk_64_k510` merge).
4. Build **all** in-tree and vendor modules from the same commit and with the
   same compiler.
5. Keep the prebuilt qqcandy DTB/DTBO until `cust.dtsi` is ported.
6. Only then replace `device/oplus/mt6895-kernel`.

A source-kernel switch is intentionally not wired into `BoardConfig.mk` yet:
the public tree is incomplete for the board DTS, and switching only the
`Image.gz` without matching modules is a known boot failure.
