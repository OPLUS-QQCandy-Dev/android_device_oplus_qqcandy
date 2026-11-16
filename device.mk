#
# Copyright (C) 2025-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oplus/qqcandy

# Boot animation
TARGET_SCREEN_HEIGHT := 2412
TARGET_SCREEN_WIDTH := 1080

# Display
TARGET_SCREEN_DENSITY := 480
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# Inherit from the common MT6895 configuration. Most HALs, init scripts,
# overlays, audio policy, sensors and media configuration live there.
$(call inherit-product, device/oplus/mt6895-common/common.mk)

# qqcandy-specific packages
PRODUCT_PACKAGES += \
    qqcandy-model.sh \
    vendor.oplus.hardware.vibrator-service.qqcandy

PRODUCT_COPY_FILES += \
    vendor/oplus/qqcandy/proprietary/odm/etc/init/vibrator-default.rc:$(TARGET_COPY_OUT_ODM)/etc/init/vibrator-default.rc \
    vendor/oplus/qqcandy/proprietary/odm/etc/vintf/manifest/vibrator-default.xml:$(TARGET_COPY_OUT_ODM)/etc/vintf/manifest/vibrator-default.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init/init.qqcandy.model.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.qqcandy.model.rc

# Inherit the proprietary files. vendor/oplus/mt6895-common contains the
# shared MTK/OPLUS blobs (with qqcandy firmware images), while
# vendor/oplus/qqcandy contains the device-specific camera/BT data.
$(call inherit-product, vendor/oplus/qqcandy/qqcandy-vendor.mk)

# qqcandy-specific configs/firmware that are not in the generated vendor
# makefiles (full 21143 + 22801 mixed set).
$(call inherit-product, vendor/oplus/qqcandy/qqcandy-vendor-extra.mk)
