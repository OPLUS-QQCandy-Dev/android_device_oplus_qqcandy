#
# Copyright (C) 2025-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from the qqcandy device configuration.
$(call inherit-product, device/oplus/qqcandy/device.mk)

# Inherit from the LineageOS configuration.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_BRAND := OnePlus
PRODUCT_DEVICE := qqcandy
PRODUCT_MANUFACTURER := OnePlus
PRODUCT_MODEL := PGZ110
PRODUCT_NAME := lineage_qqcandy

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_CHARACTERISTICS := nosdcard

# Retail-name overlay. qqcandy is sold as OnePlus Ace Racing Edition in
# China; OPPO K10 is the same hardware and uses the same image.
PRODUCT_PACKAGES += \
    OPlusSettingsProviderResTarget

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="sys_mssi_64_cn_armv82-user 15 AP3A.240617.008 1739548515603 release-keys" \
    BuildFingerprint=OnePlus/PGZ110/OP5911:15/AP3A.240617.008/S.1c86eac-1-1958c:user/release-keys \
    DeviceName=PGZ110 \
    DeviceProduct=PGZ110 \
    SystemDevice=PGZ110 \
    SystemName=PGZ110
