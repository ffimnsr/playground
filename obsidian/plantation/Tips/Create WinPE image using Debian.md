1. Download Windows ISO image.
2. Install `wimtools` (debian) or `wimlib` (arch).
3. Mount ISO file:
```bash
$ mount --mkdir <ISO> /media/winimg
```
4. Create legacy bootable ISO:
```bash
$ mkwinpeimg --iso --windows-dir=/media/winimg winpe.iso
```
5. Prepare bootable WinPE media for UEFI:
```bash
$ mount --mkdir winpe.iso /media/winpe
$ cp -r /media/winpe/* winpe_uefi
$ cp -r /media/winimg/efi winpe_uefi
$ umount /media/winimg
$ umount /media/winpe
```
6. To create ISO (optional):
```bash
$ mkisofs \
    -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -disable-deep-relocation \
    -omit-version-number \
    -relaxed-filenames \
    -output "winpe_uefi.iso" \
    winpe_uefi
```
7. To create a USB key for UEFI systems. First, create or format the USB to have GPT partition table with single partition of type EFI System. Then format the partition to FAT32. After that execute the code below:
```bash
$ mount --mkdir /dev/sdXX /media/usb
$ cp -r winpe_uefi/* /media/usb
```
8. Boot the device.