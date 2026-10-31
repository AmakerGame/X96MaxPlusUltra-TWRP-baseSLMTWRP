Restore the saved original boot_a using TWRP

1. Boot TWRP from this USB drive.
2. Choose Install, select USB OTG storage, and select restore-boot-a.zip.
3. Swipe to install. The installer checks the saved 64 MiB image and SHA256 before writing, then verifies the partition readback.
4. If TWRP reports success, choose Reboot > System.

The backup must exist at /data/local/tmp/boot_a_before_orangefox.img and match SHA256 ada7a8d030ebbba97c77d60eb97b2c48754f5bcebd92d68fa9c4fce4198341a7. The installer aborts before writing if it does not.
