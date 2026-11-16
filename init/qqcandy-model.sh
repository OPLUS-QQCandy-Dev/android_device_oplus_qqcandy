#!/vendor/bin/sh
#
# qqcandy model / project detection helper.
#
# Project mapping:
#   22801 = OnePlus Ace Racing Edition (PGZ110)
#   21143 = OPPO K10 (PGJM10), with its own camera driver path
#
# This tree is a single-SKU image: both retail names are presented as OnePlus
# Ace Racing. The detection is still useful because qqcandy mixes the two
# project families in hardware config: 22801 is the platform base, while K10
# uses 21143 for camera. Both 21143 and 22801 camera tuning/config sets are
# shipped in vendor/oplus/qqcandy.
#
# Android's ro.product.model is fixed at build time and cannot be changed
# reliably after the property service has frozen it. This helper therefore
# only reports the detected values.

project="$(getprop ro.boot.prjname)"
hardware="$(getprop ro.boot.hardware)"
model="$(getprop ro.product.model)"
device="$(getprop ro.product.device)"
market="$(getprop ro.vendor.oplus.market.enname)"

case "$project" in
    22801)
        board_name="OnePlus Ace Racing (PGZ110, project 22801)"
        ;;
    21143)
        board_name="OPPO K10 (PGJM10, project 21143, K10 camera path)"
        ;;
    "")
        board_name="qqcandy (project id unavailable)"
        ;;
    *)
        board_name="qqcandy (project $project)"
        ;;
esac

printf 'project=%s\n' "$project"
printf 'hardware=%s\n' "$hardware"
printf 'product.device=%s\n' "$device"
printf 'product.model=%s\n' "$model"
printf 'market=%s\n' "$market"
printf 'board=%s\n' "$board_name"

# Also make the detection visible in the kernel log. This is deliberately
# read-only: we do not try to change ro.product.model at runtime.
printf 'qqcandy-model: project=%s hardware=%s model=%s board=%s\n' \
    "$project" "$hardware" "$model" "$board_name" > /dev/kmsg
