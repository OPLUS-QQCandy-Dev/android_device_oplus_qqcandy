# Android device tree for OnePlus Ace Racing Edition / OPPO K10 (qqcandy)

Single-SKU LineageOS 24 tree. Both retail devices run the same image and are
presented as **OnePlus Ace Racing Edition (PGZ110)**.

## Key facts

- Platform: MediaTek MT6895 (`k6895v1_64`)
- A/B, virtual A/B, dynamic partitions
- Boot header v4, 5.10.209 prebuilt kernel
- 1080x2412 120 Hz LCD, side-mounted Goodix GSL6159
- Stock super: 9,126,805,504 bytes
- dtbo: 8,388,608 bytes
- Project mapping:
  - 22801 = Ace Racing / platform base
  - 21143 = OPPO K10 camera path
- Both 21143 and 22801 camera tuning/config sets are shipped.

## Build

```bash
lunch lineage_qqcandy-trunk_staging-userdebug
mka bacon -j12
```

Expanded super only:

```bash
QQCANDY_EXPANDED_SUPER=true mka bacon -j12
```

## Layout

```
BoardConfig.mk              partition sizes, A/B, AVB, kernel
device.mk                   product packages and vendor inheritance
lineage_qqcandy.mk          product identity (PGZ110 / OnePlus)
init/                       runtime project detection helper
overlay/                    retail-name RRO
scripts/verify-tree.py      static checks
scripts/collect-logs.sh     first-boot log collector
```

## Validation

```bash
python3 device/oplus/qqcandy/scripts/verify-tree.py
```

Expected tail:

```
extra vendor copy rules: 3467

errors: 0, warnings: 0
```

## Notes

- Do not replace `vendor/oplus/mt6895-common/radio/*.img` with 10R/Ace
  firmware. The current 19 images are from this qqcandy payload and their SHA1s
  were regenerated.
- The upstream OPPO MT6895 common tree originally contained 10R configs. This
  tree replaces same-path configs with qqcandy versions and adds the missing
  21143/22801 files through `qqcandy-vendor-extra.mk`.
- See `docs/KNOWN_ISSUES.md` before reporting first-boot problems.
