# LineageOS 24 build guide (qqcandy)

## 1. Server prerequisites

Ubuntu 24.04, 28 cores / 31 GB RAM / 860 GB free on `/home` is enough.
The Android build itself should live under `/home`, not the 19 GB root
filesystem.

Install the usual LineageOS build packages (once the server has working
outbound HTTPS):

```bash
sudo apt update
sudo apt install -y \
  bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
  git git-lfs gnupg gperf imagemagick lib32ncurses-dev lib32readline-dev \
  lib32z1-dev libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 \
  libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc \
  zip zlib1g-dev openjdk-21-jdk python3 python3-pip repo
```

Configure git and ccache:

```bash
git config --global user.name  "your-name"
git config --global user.email "you@example.com"
git lfs install
export USE_CCACHE=1
export CCACHE_DIR=/home/$USER/.ccache
ccache -M 50G
```

## 2. Sync LineageOS 24.0

```bash
mkdir -p /home/$USER/android/lineage-24
cd /home/$USER/android/lineage-24
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
```

## 3. Copy this device tree into the source

From this workspace:

```bash
SRC=/home/$USER/android/lineage-24
HERE=/path/to/QQCandy-AOSP

mkdir -p "$SRC/device/oplus" "$SRC/vendor/oplus" \
         "$SRC/device/mediatek" "$SRC/hardware"

rsync -a "$HERE/device/oplus/qqcandy/"          "$SRC/device/oplus/qqcandy/"
rsync -a "$HERE/device/oplus/mt6895-common/"    "$SRC/device/oplus/mt6895-common/"
rsync -a "$HERE/device/oplus/mt6895-kernel/"   "$SRC/device/oplus/mt6895-kernel/"
rsync -a "$HERE/device/mediatek/sepolicy_vndr/" "$SRC/device/mediatek/sepolicy_vndr/"
rsync -a "$HERE/hardware/mediatek/"             "$SRC/hardware/mediatek/"
rsync -a "$HERE/hardware/oplus/"                "$SRC/hardware/oplus/"
rsync -a "$HERE/vendor/oplus/mt6895-common/"    "$SRC/vendor/oplus/mt6895-common/"
rsync -a "$HERE/vendor/oplus/qqcandy/"          "$SRC/vendor/oplus/qqcandy/"
```

`device/oplus/qqcandy/lineage.dependencies` lists the remaining upstream
Lineage/AOSP dependencies. If `breakfast` does not fetch them, clone manually:

```bash
cd "$SRC"
git clone -b lineage-24.0 https://github.com/LineageOS/android_hardware_lineage_interfaces.git hardware/lineage/interfaces
git clone -b lineage-24.0 https://github.com/LineageOS/android_hardware_google_pixel.git hardware/google/pixel
git clone -b lineage-24.0 https://github.com/LineageOS/android_device_lineage_sepolicy.git device/lineage/sepolicy
```

`device/generic/trusty` is already in the AOSP part of the Lineage manifest.

## 4. Build

> 31 GB RAM: use `-j12`. Do **not** use `-j$(nproc)` (28 jobs); this
> machine will OOM during Soong/Ninja. `repo sync` can stay at `-j8`.

`cp2a` is the Android 17 release config: `PLATFORM_VERSION=17` and
`PLATFORM_SDK_VERSION=37`. `trunk_staging` is the in-development trunk and
still reports the old codename string (`PLATFORM_VERSION=Baklava`); do not use
it for release builds.

Stock `super` layout (default):

```bash
cd "$SRC"
source build/envsetup.sh
lunch lineage_qqcandy-cp2a-userdebug
mka bacon -j12
```

Already-expanded `super` (12,348,030,976 bytes):

```bash
QQCANDY_EXPANDED_SUPER=true mka bacon -j12
```

Only use the expanded flag on a device whose GPT/super was actually expanded.
The default is the stock `9,126,805,504`-byte layout shared with OnePlus Ace.

## 5. Outputs

```
out/target/product/qqcandy/lineage-24.0-*-qqcandy.zip
out/target/product/qqcandy/boot.img
out/target/product/qqcandy/vendor_boot.img
out/target/product/qqcandy/dtbo.img
out/target/product/qqcandy/super_empty.img
```

## 6. Flashing notes

- Unlock the bootloader first.
- The firmware images in `vendor/oplus/mt6895-common/radio/` have already
  been replaced with the PGZ110 15.0.0.501 set and SHA1s recalculated.
  Do **not** replace them with OnePlus 10R/Ace images.
- For a first dynamic-partition flash, use the generated `super_empty.img`
  with `fastboot wipe-super` if your flashing flow requires it, then flash the
  Lineage zip via recovery sideload or `fastboot update`.
- `dtbo` partition is 8 MiB on qqcandy. Do not use the 10R 3 MiB/32 MiB
  values.
- If the device was already expanded, keep using the expanded build; otherwise
  flash the stock-size build.

## 7. First-boot logs

Use `device/oplus/qqcandy/scripts/collect-logs.sh` after boot, or from
recovery:

```bash
adb root
adb shell dmesg                 > dmesg.txt
adb logcat -d                   > logcat.txt
adb shell getprop               > getprop.txt
adb shell lpdump /dev/block/by-name/super > lpdump.txt
```
