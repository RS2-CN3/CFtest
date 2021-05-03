#!/usr/bin/env bash

wipefs -a -f /dev/sda
echo 'mklabel gpt
mkpart "EFI" fat32 1MiB 512MiB
set 1 esp on
mkpart "Root" ext4 512MiB 100GiB
mkpart "Home" ext4 100GiB 100%
quit' | parted /dev/sda

mkfs.fat -F32 /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sda3

mount /dev/sda2 /mnt
mkdir /mnt/home
mount /dev/sda3 /mnt/home

mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
pacstrap -i /mnt base base-devel linux linux-headers linux-firmware nano networkmanager --noconfirm

echo 'systemctl enable NetworkManager' | arch-chroot /mnt
echo 'sed -i '13,14s/.//' /etc/locale.gen' | arch-chroot /mnt
echo 'locale-gen' | arch-chroot /mnt
echo 'passwd
1051
1051' | arch-chroot /mnt
echo 'useradd -m -g users -G wheel ujjwal' | arch-chroot /mnt
echo 'passwd ujjwal
1051
1051' | arch-chroot /mnt
echo 'sed -i '85s/.//' /etc/sudoers' | arch-chroot /mnt
echo 'mkinitcpio -p linux' | arch-chroot /mnt
echo 'pacman -S grub efibootmgr dosfstools os-prober mtools --noconfirm' | arch-chroot /mnt
echo 'mkdir /boot/EFI' | arch-chroot /mnt
echo 'mount /dev/sda1 /boot/EFI' | arch-chroot /mnt
echo 'grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck' | arch-chroot /mnt
echo 'mkdir /boot/grub/locale' | arch-chroot /mnt
echo 'cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo' | arch-chroot /mnt
echo 'grub-mkconfig -o /boot/grub/grub.cfg' | arch-chroot /mnt
echo 'pacman -S intel-ucode xorg-server xfce4 xfce4-goodies lightdm lightdm-gtk-greeter git sddm konsole --noconfirm' | arch-chroot /mnt
echo 'systemctl enable lightdm' | arch-chroot /mnt
