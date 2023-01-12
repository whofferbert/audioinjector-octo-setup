# AudioInjector Octo Setup Script

This is a simple bash script to help set up an audioinjector octo sound card.

To use it, simply download the script to your raspberry pi, and then execute it as the root user:

```
curl -sLO https://raw.githubusercontent.com/whofferbert/audioinjector-octo-setup/master/octo-setup.sh
sudo bash ./octo-setup.sh
```

---

# Kernel problems?

In addition to that, there may be problems using this card with newer kernels (I'm still working to find out why.)

If you have problems using/detecting this card and see things like this in your `dmesg` output:

```
[    5.591921] cs42xx8 1-0048: supply VA not found, using dummy regulator
[    5.592652] cs42xx8 1-0048: supply VD not found, using dummy regulator
[    5.592761] cs42xx8 1-0048: supply VLS not found, using dummy regulator
[    5.592886] cs42xx8 1-0048: supply VLC not found, using dummy regulator
[    5.625126] cs42xx8 1-0048: failed to get device ID, ret = -121
[    5.626362] cs42xx8: probe of 1-0048 failed with error -121
[    6.324566] audioinjector-octo soc:sound: snd_soc_register_card failed (-517)
```

Then you may have this problem too.

To fix that, we can revert to an older kernel.
These steps are for getting to 4.19.118-v7+; implemented based on guidance found here: https://github.com/HinTak/RaspberryPi-Dev/blob/master/Downgrading-Pi-Kernel.md

```
wget -O kernel-headers_armhf.deb http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-kernel-headers_1.20200601-1_armhf.deb
wget -O kernel_armhf.deb http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-kernel_1.20200601-1_armhf.deb
sudo dpkg -i kernel-headers_armhf.deb kernel_armhf.deb
sudo apt-mark hold raspberrypi-kernel-headers raspberrypi-kernel raspberrypi-bootloader
sudo apt-mark showhold
sudo reboot
```

It is important to reboot afterward to get to the new kernel. You can confirm the current kernel version with:
```
uname -a
```

Note that it is very important to make sure these packages are 'held' with apt-mark after we get to a working state:
```
raspberrypi-bootloader
raspberrypi-kernel
raspberrypi-kernel-headers 
```

If those packages are not in a 'hold' state, any `apt-get upgrade` or similar could update your kernel and leave you back in a non-working state.
