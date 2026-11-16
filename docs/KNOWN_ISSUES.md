# Known issues / first-boot checklist

This tree has passed static checks only. It has not yet been compiled or
booted. Expect the first boot to need iteration.

## Known gaps

1. **K10 21143 camera configuration**
   The available dump is from a 22801 Ace Racing device. It contains the
   21143 camera tuning libraries and many 21143 configs, but
   `odm/etc/camera/CameraHWConfiguration.config` is the 22801 file
   (`Project = 22801`). A real OPPO K10 21143 `odm` dump may contain a
   different file. Verify camera on K10 first.

2. **K10 camera kernel driver**
   The kernel modules are the PGZ110 22801 set. If the K10 21143 camera uses
   a different AF/EEPROM driver module, it may need to be extracted from a K10
   `vendor_boot`/`vendor_dlkm` and added to
   `device/oplus/mt6895-kernel/modules/`.

3. **SELinux**
   There is no qqcandy-specific `device/oplus/qqcandy/sepolicy` yet. First boot
   will likely show OPLUS/MTK denials. Collect `dmesg` + `logcat`, add the
   required `genfs_contexts`/`file_contexts`/`te` rules, then rebuild.

4. **Vendor completeness**
   The upstream OPPO MT6895 vendor tree was curated for 10R/Ace. This tree
   replaced 97 same-path configs with qqcandy versions, replaced the 19
   firmware images, and added 3467 qqcandy config/firmware files. Some
   remaining 10R libraries may still be wrong. First-boot logs decide what to
   replace next.

5. **Source kernel**
   Public OSS `k6895v1_64/cust.dtsi` is missing; see
   [SOURCE_KERNEL.md](SOURCE_KERNEL.md). Default is prebuilt 5.10.209.

6. **Dynamic partitions**
   Stock `super` is 9,126,805,504 bytes. The expanded 12,348,030,976 value is
   optional (`QQCANDY_EXPANDED_SUPER=true`) and must only be used on a device
   whose super was actually expanded.

7. **First flash**
   The stock super contains OPLUS-only logical partitions. Use the generated
   `super_empty.img` / `fastboot wipe-super` if logical partition creation
   fails.

## First boot collection

```bash
adb root
adb shell dmesg > dmesg.txt
adb logcat -d > logcat.txt
adb shell getprop > getprop.txt
adb shell lspci 2>/dev/null || true
adb shell 'ls -l /dev/block/by-name' > by-name.txt
adb shell 'cat /proc/cmdline' > cmdline.txt
adb shell lpdump /dev/block/by-name/super > lpdump.txt
```

Then check:

```bash
grep -iE 'avc: denied|failed to start|init:.*error' logcat.txt dmesg.txt
```

## Things that are intentional

- Single SKU: both devices show OnePlus Ace Racing Edition.
- `ro.boot.prjname` is not used to mutate `ro.product.model`.
- `OPlusSettingsProviderResTarget` has no `requiredSystemPropertyName`, so the
  same overlay applies on 22801 and 21143.
- QTI vibrator was removed; the tree uses the OPLUS AW8697 AIDL vibrator HAL.
- HIDL `vendor.lineage.touch@1.0-service.oplus` was replaced by the AIDL
  `vendor.lineage.touch-service.oplus` module from `hardware/oplus`.
