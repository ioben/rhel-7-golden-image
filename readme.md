RHEL 7 Golden Image
===================

Tools to extract and repackage RHEL 7 ISO with custom kickstart file.


Using Tools
-----------

```bash
tools/extract-iso -f ~/Downloads/CentOS-7-x86_64-Minimal-1810.iso tmp/

cp anaconda-ks.cfg tmp/ks.cfg

docker build -t centos-iso:latest .
docker run -ti -u "$(id -u)" -v "$(pwd):/project" centos-iso:latest /tools/create-iso -f tmp/ centos-7-x86_64-minimal-1810-golden-image.iso

rm -rf tmp/

sudo dd if=centos-7-x86_64-minimal-1810-golden-image.iso of=/dev/DEVICE bs=1M
```


Manually
--------

```bash
sudo pacman -S cdrtools syslinux isomd5sum

sudo mount -o loop ~/Downloads/CentOS-7-x86_64-Minimal-1810.iso /mnt
mkdir tmp
cp -r /mnt/* tmp/
chmod -R u+w tmp/

sudo umount /mnt

cp anaconda-ks.cfg tmp/ks.cfg

# TODO - Add local packages if wanted
# cp packages/*.rpm tmp/Packages/.
# (cd tmp/Packages && createrepo -dpo .. .)

# Add kickstart to boot options
# sed -i 's@append initrd=initrd.img@\0 inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet ks=cdrom:/ks.cfg@' tmp/isolinux/isolinux.cfg

sed -i 's@^\s*linuxefi.*$@\0 inst.ks=cdrom:/ks.cfg@' tmp/EFI/BOOT/grub.cfg

# Create new ISO
docker build -t centos-iso:latest .
docker run -u "$(id -u)" -v "$(pwd):/project" -ti centos-iso:latest bash
# cd /project/tmp
# genisoimage -U -r -v -T -J -joliet-long \
#     -V "CentOS 7 x86_64" \
#     -volset "CentOS 7 x86_64" \
#     -A "CentOS 7 x86_64" \
#     -b isolinux/isolinux.bin \
#     -c isolinux/boot.cat \
#     -no-emul-boot \
#     -boot-load-size 4 \
#     -boot-info-table \
#     -eltorito-alt-boot \
#     -e images/efiboot.img \
#     -no-emul-boot \
#     -o ../NEWISO.iso .
# exit

isohybrid --uefi NEWISO.iso

implantisomd5 NEWISO.iso

mv NEWISO.iso centos-7-x86_64-minimal-1810-golden-image.iso

sudo dd if=centos-7-x86_64-minimal-1810-golden-image.iso of=/dev/DEVICE bs=1M
```
