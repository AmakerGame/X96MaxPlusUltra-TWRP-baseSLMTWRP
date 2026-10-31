#!/sbin/sh
OUTFD="$2"
ui_print() {
    if [ -n "$OUTFD" ]; then
        echo "ui_print $1" > "/proc/self/fd/$OUTFD"
        echo "ui_print" > "/proc/self/fd/$OUTFD"
    fi
}
fail() { ui_print "ERROR: $1"; exit 1; }
BACKUP=/data/local/tmp/boot_a_before_orangefox.img
TARGET=/dev/block/by-name/boot_a
EXPECTED=ada7a8d030ebbba97c77d60eb97b2c48754f5bcebd92d68fa9c4fce4198341a7
if [ ! -f "$BACKUP" ] && [ -x /sbin/twrp ]; then
    /sbin/twrp mount /data >/dev/null 2>&1
fi
[ -f "$BACKUP" ] || fail "Backup not found at $BACKUP; mount/decrypt Data in TWRP and retry."
[ -e "$TARGET" ] || fail "boot_a partition not found."
SIZE=$(wc -c < "$BACKUP" | tr -d ' ')
HASH=$(sha256sum "$BACKUP" | cut -d ' ' -f1)
ui_print "Backup size=$SIZE"
ui_print "Backup SHA256=$HASH"
[ "$SIZE" = 67108864 ] || fail "Backup size mismatch; nothing was written."
[ "$HASH" = "$EXPECTED" ] || fail "Backup hash mismatch; nothing was written."
ui_print "Restoring original boot_a..."
dd if="$BACKUP" of="$TARGET" bs=4096 count=16384 || fail "Writing boot_a failed."
sync
READBACK=$(dd if="$TARGET" bs=4096 count=16384 2>/dev/null | sha256sum | cut -d ' ' -f1)
ui_print "Readback SHA256=$READBACK"
[ "$READBACK" = "$EXPECTED" ] || fail "Readback verification failed. Do not reboot."
if command -v bootctl >/dev/null 2>&1; then
    bootctl set-active-boot-slot 0 || fail "Could not set slot A active."
    ui_print "Active slot: $(bootctl get-suffix 0)"
else
    ui_print "Select Reboot > Slot A in TWRP before rebooting."
fi
ui_print "boot_a restored and verified. Reboot to System from TWRP."
exit 0
