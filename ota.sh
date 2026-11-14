
#!/bin/bash
set -e
VERSION=$1
DEVICE=spes
OEM=Xiaomi
OUT=$(ls -td ~/*/out/target/product/$DEVICE 2>/dev/null | head -1)
[ -z "$OUT" ] && { echo "No $DEVICE build found in any folder in your home"; exit 1; }
ZIP=$(ls -t $OUT/*Rising*.zip | head -1)
NAME=$(basename "$ZIP")
SIZE=$(stat -c%s "$ZIP")
MD5=$(md5sum "$ZIP" | cut -d' ' -f1)
SHA=$(sha256sum "$ZIP" | cut -d' ' -f1)
DATE=$(grep -m1 ro.build.date.utc $OUT/system/build.prop | cut -d= -f2)
URL="https://github.com/nunchaii/rising_ota/releases/download/$VERSION/$NAME"

gh release create "$VERSION" "$ZIP" -R nunchaii/rising_ota --notes "RisingOS $VERSION $DEVICE" \
  || gh release upload "$VERSION" "$ZIP" -R nunchaii/rising_ota --clobber

rm -rf ~/rising_ota && git clone https://github.com/nunchaii/rising_ota.git ~/rising_ota
cd ~/rising_ota
cat > $DEVICE.json <<EOF
{
	"response": [
		{
			"maintainer": "nunchaii",
			"oem": "$OEM",
			"device": "$DEVICE",
			"filename": "$NAME",
			"download": "$URL",
			"timestamp": $DATE,
			"md5": "$MD5",
			"sha256": "$SHA",
			"size": $SIZE,
			"version": "$VERSION",
			"buildtype": "UNOFFICIAL",
			"forum": "",
			"recovery": "",
			"paypal": "",
			"telegram": ""
		}
	]
}
EOF
cp changelog.txt changelog_$DEVICE.txt
git add . && git commit -m "$DEVICE $VERSION" && git push
