# qqcandy hardware and partition notes

## Identity

| Item | Value |
|---|---|
| Codename | `qqcandy` |
| Retail names | OnePlus Ace Racing Edition (PGZ110), OPPO K10 (PGJM10) |
| Product device | `OP5911` |
| Platform | MediaTek `mt6895` / MT6895Z |
| Project base | `k6895v1_64` |
| Bootloader | A/B, UEFI, boot header v4 |
| Android baseline | ColorOS/OxygenOS 15, API 35, 5.10.209 kernel |

Bootloader mapping:

- `ro.boot.prjname=22801` — OnePlus Ace Racing Edition / PGZ110
- `ro.boot.prjname=21143` — OPPO K10 / PGJM10, used for the K10 camera path
- Except for the camera path, the hardware configuration follows 22801.

## Hardware

| Part | Detail |
|---|---|
| Display | 6.59" 1080x2412 LCD, 120 Hz, Tianma NT36672C, 480 dpi |
| Panel driver | `oplus21143_tianma_nt36672c_dsi_vdo` |
| Touch | Novatek NT36672C, 240 Hz touch sampling |
| Fingerprint | Side-mounted Goodix GSL6159 (`S_gsl6159`) |
| SoC | MediaTek MT6895 (Dimensity 8100-Max / 8000-Max family) |
| RAM / storage | LPDDR5 / UFS 3.1 |
| Battery | 5000 mAh, 67 W SuperVOOC |
| Haptics | AW8697 X-axis linear motor, OPLUS richtap stack |
| NFC | STMicroelectronics/NXP SN100 family |
| Audio | MT6368 + AW882xx smart PA |
| Camera | OV64B 64 MP (22801 main), IMX355 8 MP (21143 UW), GC02M1 2 MP (21143 macro), S5K3P9SP 16 MP front (21143) |

The 21143/22801 split is why the tree keeps both camera tuning families and
both project config sets.

## Partitions (observed)

| Partition | Size |
|---|---:|
| boot_a/b | 67,108,864 |
| vendor_boot_a/b | 67,108,864 |
| dtbo_a/b | 8,388,608 |
| super (stock) | 9,126,805,504 |
| super (expanded) | 12,348,030,976 |
| metadata | 33,554,432 |

Stock qqcandy `super` matches OnePlus Ace: `9,126,805,504` bytes. The
expanded value is an optional build override, not the default.

## Dynamic partitions

The Lineage layout builds only:

```
system  system_ext  product  vendor  odm  vendor_dlkm  odm_dlkm
```

The stock super still contains OPLUS-only logical partitions
(`my_product`, `my_stock`, `my_heytap`, `my_carrier`, `my_region`,
`my_company`, `my_preload`, `my_bigball`, `my_manifest`, `my_engineering`).
A first flash with `super_empty.img`/`fastboot wipe-super` is the clean way to
remove them; otherwise the group can remain full and logical partition
creation may fail.

## Firmware images

`vendor/oplus/mt6895-common/radio/` contains the 19 firmware images extracted
from this device's PGZ110 15.0.0.501 payload:

```
apusys audio_dsp ccu dpm dtbo gpueb gz lk mcf_ota mcupm md1img
mvpu_algo pi_img preloader_raw scp spmfw sspm tee vcp
```

Their SHA1s in `vendor/oplus/mt6895-common/Android.mk` were regenerated.
Do not mix them with OnePlus 10R/Ace firmware.
