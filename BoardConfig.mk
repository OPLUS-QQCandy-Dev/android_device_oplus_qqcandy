#
# Copyright (C) 2025-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oplus/qqcandy

# Include the common MT6895 configuration.
include device/oplus/mt6895-common/BoardConfigCommon.mk

# A/B
AB_OTA_UPDATER := true

# Assert
TARGET_OTA_ASSERT_DEVICE := OP5911,PGZ110,PGJM10,qqcandy

# Display
TARGET_SCREEN_DENSITY := 480

# Fingerprint
# qqcandy uses a side-mounted Goodix GSL6159. This also covers first boot on a
# wiped persist partition, where the stock value is not present yet.
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Kernel / boot
# Prebuilt 5.10.209 from PGZ110_15.0.0.501(CN01). The source-kernel path is
# documented in docs/SOURCE_KERNEL.md and is intentionally opt-in.
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864

BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img

# Dynamic partitions
# Stock PGZ110/PGJM10 uses the same 9,126,805,504-byte super as OnePlus Ace.
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 9122611200

# The user's device has an expanded super partition. Keep the stock layout as
# the default; use QQCANDY_EXPANDED_SUPER=true only for an already-expanded
# device.
ifeq ($(QQCANDY_EXPANDED_SUPER),true)
BOARD_SUPER_PARTITION_SIZE := 12348030976
BOARD_ONEPLUS_DYNAMIC_PARTITIONS_SIZE := 12343836672
endif

BOARD_ONEPLUS_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vendor_dlkm \
    odm_dlkm

# Platform
BOARD_HAS_MTK_HARDWARE := true
TARGET_BOARD_PLATFORM := mt6895

# Security
VENDOR_SECURITY_PATCH := 2025-01-01
BOOT_SECURITY_PATCH := 2025-01-01

# Verified boot
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_VENDOR := vendor odm

# Include the proprietary files BoardConfig.
include vendor/oplus/qqcandy/BoardConfigVendor.mk
