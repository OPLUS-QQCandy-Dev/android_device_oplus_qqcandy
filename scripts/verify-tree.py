#!/usr/bin/env python3
#
# Static checks for the qqcandy device tree.
# Run from the root of the partial LineageOS tree:
#
#   python3 device/oplus/qqcandy/scripts/verify-tree.py
#
# This does not replace a real build. It catches the common path/duplicate
# mistakes that would otherwise fail at lunch/Ninja time.

from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
ERRORS = []
WARNINGS = []


def err(msg):
    ERRORS.append(msg)


def warn(msg):
    WARNINGS.append(msg)


def exists(rel):
    return (ROOT / rel).exists()


def check_required():
    required = [
        "device/oplus/qqcandy/BoardConfig.mk",
        "device/oplus/qqcandy/device.mk",
        "device/oplus/qqcandy/lineage_qqcandy.mk",
        "device/oplus/qqcandy/AndroidProducts.mk",
        "device/oplus/qqcandy/lineage.dependencies",
        "device/oplus/mt6895-common/BoardConfigCommon.mk",
        "device/oplus/mt6895-common/common.mk",
        "device/oplus/mt6895-kernel/Image.gz",
        "device/oplus/mt6895-kernel/dtb/mt6895.dtb",
        "device/oplus/mt6895-kernel/dtbo.img",
        "device/oplus/mt6895-kernel/modules/vendor_dlkm.modules.load",
        "device/oplus/mt6895-kernel/modules/vendor_ramdisk.modules.load",
        "vendor/oplus/mt6895-common/mt6895-common-vendor.mk",
        "vendor/oplus/qqcandy/qqcandy-vendor.mk",
        "vendor/oplus/qqcandy/qqcandy-vendor-extra.mk",
        "device/mediatek/sepolicy_vndr/SEPolicy.mk",
        "hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml",
        "hardware/oplus/vintf/device_framework_matrix.xml",
    ]
    for rel in required:
        if not exists(rel):
            err(f"missing required file: {rel}")


def check_kernel_modules():
    kdir = ROOT / "device/oplus/mt6895-kernel"
    lists = [
        "modules/vendor_dlkm.modules.load",
        "modules/vendor_ramdisk.modules.load",
        "modules/vendor_ramdisk.modules.load.recovery",
    ]
    for rel in lists:
        p = kdir / rel
        if not p.exists():
            err(f"missing module list: {rel}")
            continue
        names = [x.strip() for x in p.read_text().splitlines() if x.strip() and not x.startswith("#")]
        missing = [x for x in names if not (kdir / "modules" / x).exists()]
        if missing:
            err(f"{rel}: {len(missing)} modules missing, first: {missing[:5]}")

    forced = [
        "bt_drv_6895.ko", "connfem.ko", "conninfra.ko",
        "fmradio_drv_connac2x.ko", "gps_drv_dl_v050.ko", "gps_pwr.ko",
        "gps_scp.ko", "wlan_drv_gen4m_6895.ko", "wmt_chrdev_wifi_connac2.ko",
    ]
    for name in forced:
        if not (kdir / "modules" / name).exists():
            err(f"forced kernel module missing: {name}")


def check_radio_sha1():
    radio_dir = ROOT / "vendor/oplus/mt6895-common/radio"
    mk = ROOT / "vendor/oplus/mt6895-common/Android.mk"
    if not mk.exists():
        err("missing vendor/oplus/mt6895-common/Android.mk")
        return
    entries = 0
    for line in mk.read_text().splitlines():
        m = re.search(r"radio/([^,]+),([0-9a-f]{40})", line)
        if not m:
            continue
        entries += 1
        p = radio_dir / m.group(1)
        if not p.exists():
            err(f"radio image missing: {m.group(1)}")
            continue
        if hashlib.sha1(p.read_bytes()).hexdigest() != m.group(2):
            err(f"radio SHA1 mismatch: {m.group(1)}")
    if entries != 19:
        warn(f"expected 19 radio images, found {entries}")


def check_duplicate_copy_destinations():
    dests = {}
    for root in [ROOT / "device/oplus", ROOT / "vendor/oplus"]:
        for p in root.rglob("*.mk"):
            try:
                s = p.read_text(errors="replace")
            except OSError:
                continue
            for m in re.finditer(r":(\$\(TARGET_COPY_OUT_[A-Z_]+\)/[^ \t\\]+)", s):
                dests.setdefault(m.group(1), []).append(str(p.relative_to(ROOT)))
    for dest, files in dests.items():
        if len(files) > 1:
            err(f"duplicate PRODUCT_COPY_FILES destination {dest}: {files}")


def check_extra_makefile():
    p = ROOT / "vendor/oplus/qqcandy/qqcandy-vendor-extra.mk"
    if not p.exists():
        return
    s = p.read_text()
    srcs = re.findall(r"vendor/oplus/qqcandy/proprietary/([^:]+):", s)
    dests = re.findall(r":(\$\(TARGET_COPY_OUT_[A-Z_]+\)/[^ \\]+)", s)
    missing = [x for x in srcs if not (ROOT / "vendor/oplus/qqcandy/proprietary" / x).exists()]
    if missing:
        err(f"extra makefile: {len(missing)} source files missing, first: {missing[:5]}")
    if len(dests) != len(set(dests)):
        err("extra makefile: duplicate destinations")
    print(f"extra vendor copy rules: {len(srcs)}")


def check_module_duplicates():
    files = [
        ROOT / "vendor/oplus/qqcandy/Android.bp",
        ROOT / "vendor/oplus/mt6895-common/Android.bp",
    ]
    modules = {}
    for p in files:
        s = p.read_text(errors="replace")
        for m in re.finditer(r"(?<![A-Za-z_])name:\s*\"([^\"]+)\"", s):
            modules.setdefault(m.group(1), []).append(str(p.relative_to(ROOT)))
    for name, where in modules.items():
        if len(where) > 1:
            err(f"duplicate Soong module {name}: {where}")


def check_board_config():
    p = ROOT / "device/oplus/qqcandy/BoardConfig.mk"
    s = p.read_text()
    checks = {
        "BOARD_SUPER_PARTITION_SIZE := 9126805504": "stock super size",
        "BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 9122611200": "stock group size",
        "BOARD_DTBOIMG_PARTITION_SIZE := 8388608": "qqcandy dtbo size",
        "BOARD_PREBUILT_DTBOIMAGE": "prebuilt dtbo",
        "AB_OTA_UPDATER := true": "A/B updater",
    }
    for needle, what in checks.items():
        if needle not in s:
            err(f"BoardConfig missing {what}: {needle}")
    if "QQCANDY_EXPANDED_SUPER" not in s:
        warn("expanded-super override not present")


def check_dependencies_json():
    p = ROOT / "device/oplus/qqcandy/lineage.dependencies"
    try:
        json.loads(p.read_text())
    except Exception as e:
        err(f"lineage.dependencies is not valid JSON: {e}")


def check_known_lineage24_paths():
    missing = []
    for rel in [
        "device/oplus/mt6895-common/touch/include/TouchscreenGestureConfig.h",
        "vendor/oplus/qqcandy/proprietary/odm/etc/fingerprint.json",
    ]:
        if not exists(rel):
            missing.append(rel)
    if not (
        exists("vendor/oplus/mt6895-common/proprietary/odm/etc/camera/CameraHWConfiguration.config")
        or exists("vendor/oplus/qqcandy/proprietary/odm/etc/camera/CameraHWConfiguration.config")
    ):
        missing.append("odm/etc/camera/CameraHWConfiguration.config")
    for rel in missing:
        warn(f"optional/known path not present: {rel}")

    # Both camera project families must be present: 21143 is the K10 camera
    # path, 22801 is the Ace Racing / platform base.
    camera_dir = ROOT / "vendor/oplus/qqcandy/proprietary/odm/lib64/mt6895"
    for needle in ("21143", "22801"):
        if not any(needle in p.name for p in camera_dir.glob("*.so")):
            err(f"camera blob family missing in vendor: {needle}")

    # Single-SKU tree: the K10 product makefile should not exist.
    if exists("device/oplus/qqcandy/lineage_qqcandy_k10.mk"):
        err("K10 product makefile still present; this is a single-SKU tree")

    # The old HIDL touch module must not be referenced on 24.0.
    for p in [ROOT / "device/oplus", ROOT / "vendor/oplus"]:
        for f in p.rglob("*.mk"):
            if "vendor.lineage.touch@1.0-service.oplus" in f.read_text(errors="replace"):
                err(f"old HIDL touch module still referenced in {f.relative_to(ROOT)}")


def main():
    check_required()
    check_kernel_modules()
    check_radio_sha1()
    check_duplicate_copy_destinations()
    check_extra_makefile()
    check_module_duplicates()
    check_board_config()
    check_dependencies_json()
    check_known_lineage24_paths()

    for w in WARNINGS:
        print(f"WARN: {w}")
    for e in ERRORS:
        print(f"ERROR: {e}")

    print()
    print(f"errors: {len(ERRORS)}, warnings: {len(WARNINGS)}")
    return 1 if ERRORS else 0


if __name__ == "__main__":
    sys.exit(main())
