---
title: Debian for Gaming
description: A post describing how to set up a Debian system for gaming
date: 2023-12-09
tags: [debian, linux, gaming]
image: https://www.debian.org/Pics/debian-logo-1024x576.png
card: summary
toc: true
layout: aside
---

# Debian for Gaming

Having recently built a desktop computer with the main intent being for gaming, the logical thing to do was to install [my favourite Linux distribution](https://www.debian.org/) on it.

I have decided to use [Debian `testing`](https://wiki.debian.org/DebianTesting) as it provides me with a good balance between stability and updates.

Furthermore, since this computer is going to be used for gaming, I want to keep up with the latest Mesa.

## Considerations

### Hardware

I have installed a recent AMD Radeon GPU on this machine as it has better Linux support, with fully functional drivers being open source and distributed with the kernel.

### What's not covered

I will not cover the basic installation of Debian. This should be relatively straightforward.

Also outside of the scope of this post is installing [Steam](https://store.steampowered.com/), [Heroic Games Launcher](https://heroicgameslauncher.com/), [Lutris](https://lutris.net/) or any other Game launchers or actual games.

## Basic configuration

### `apt` sources

After the initial installation is ready and we have a Debian `testing` system running, it's time to add `apt` sources so we can pull packages from `unstable` (aka `sid`) or `experimental` should they be needed.

We start by deleting the main sources config. We'll cover everything as targeted files under `/etc/apt/sources.list.d`:

```shell
rm /etc/apt/sources.list
```

Next, we create the following files:

`/etc/apt/sources.list.d/00testing.list`:

    deb http://deb.debian.org/debian testing main contrib non-free-firmware
    deb-src http://deb.debian.org/debian testing main contrib non-free-firmware

    deb http://deb.debian.org/debian testing-updates main non-free-firmware
    deb-src http://deb.debian.org/debian testing-updates main non-free-firmware

    deb http://security.debian.org/debian-security/ testing-security main non-free-firmware
    deb-src http://security.debian.org/debian-security/ testing-security main non-free-firmware

`/etc/apt/sources.list.d/01unstable.list`:

    deb http://deb.debian.org/debian unstable main contrib non-free-firmware
    deb-src http://deb.debian.org/debian unstable main contrib non-free-firmware

`/etc/apt/sources.list.d/02experimental.list`:

    deb http://deb.debian.org/debian experimental main contrib non-free-firmware
    deb-src http://deb.debian.org/debian experimental main contrib non-free-firmware

**❗️ WARNING**<br/>
Do not run `apt update` and `apt upgrade` at this point. Doing so will instruct `apt` to attempt to upgrade your entire system to `experimental`.<br/>Please go through the [apt Pinning](#apt-pinning) section below before attempting to update your system.

### `apt` Pinning

Now that we have all `apt` sources setup, we should instruct the system to always prefer to install packages from `testing`. We do that by using a technique known as [apt pinning](https://wiki.debian.org/AptConfiguration#apt_preferences_.28APT_pinning.29).

To do so, create the following files:

`/etc/apt/preferences.d/00testing.pref`:

    # 500 <= P < 990: causes a version to be installed unless there is a
    # version available belonging to the target release or the installed
    # version is more recent

    Package: *
    Pin: release a=testing
    Pin-Priority: 900

`/etc/apt/preferences.d/01unstable.pref`:

    # 100 <= P < 500: causes a version to be installed unless there is a
    # version available belonging to some other distribution or the installed
    # version is more recent

    Package: *
    Pin: release a=unstable
    Pin-Priority: 400

`/etc/apt/preferences.d/02experimental.pref`:

    # 0 < P < 100: causes a version to be installed only if there is no
    # installed version of the package

    Package: *
    Pin: release a=experimental
    Pin-Priority: 50

With those files in place, it's again safe to run `apt upgrade`.

### Firmware

Some hardware require proprietary firmware for certain features, stability, performance, or to function at all.

For general information about non-free firmware and Debian, check [the official documentation](https://wiki.debian.org/Firmware).

Because I'm using a fairly recent AMD GPU, some of the required firmware is not yet present in Debian packages. This is easily resolved by copying those files from the upstream Kernel `git` archives by adapting the technique described in [Firmware missing from Debian](https://wiki.debian.org/Firmware#Firmware_missing_from_Debian) and running:

```shell
mkdir firmware
cd firmware
wget -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/amdgpu/
sudo mv *.bin /lib/firmware/amdgpu/
sudo update-initramfs -c -k all
```

💡 There's no harm in pulling these firmware files from upstream. If they're not needed by the driver, they just don't get used.

## Gaming-related additions

In this section I'll cover some additions with the specific intent of having the best possible gaming experience.

### Mesa

[Mesa](https://mesa3d.org/) (or Mesa 3D) is, according to their website:

> Open source implementations of OpenGL, OpenGL ES, Vulkan, OpenCL, and more!

Suffice it to say that it's imperative to have a recent version of Mesa in order to get the best performance and compatibility with games, especially AAAs or new ones.

In order to achieve that, we tell our system to always pull the Mesa packages from the bleeding-edge `experimental` distribution. To achieve that taking advantage of the same [`apt` Pinning](#apt-pinning) technique above, create the following file:

`/etc/apt/preferences.d/user-mesa.pref`:

    Package: libegl-mesa0 libgl1-mesa-dri libglx-mesa0 libosmesa6 mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers libgbm1 libglapi-mesa
    Explanation: Keep up with latest Mesa
    Pin: release a=experimental
    Pin-Priority: 950

    Package: libegl-mesa0:i386 libgl1-mesa-dri:i386 libglx-mesa0:i386 libosmesa6:i386 mesa-va-drivers:i386 mesa-vdpau-drivers:i386 mesa-vulkan-drivers:i386 libgbm1:i386 libglapi-mesa:i386
    Explanation: Keep up with latest Mesa (32-bit)
    Pin: release a=experimental
    Pin-Priority: 950

💡 We're pulling both the default `amd64` and `i386` versions of those packages. Some games are 32-bit and require the latter ones.

### Virtual surround sound on headphones

To get virtual surround audio on Pipewire, a new audio sink must be created.

Start by copying the example config file to your `~/.config` directory:

```shell
mkdir -p ~/.config/pipewire/filter-chain.conf.d/
cp /usr/share/pipewire/filter-chain/sink-virtual-surround-7.1-hesuvi.conf ~/.config/pipewire/filter-chain.conf.d/
```

Now grab an impulse response WAV file. I've tested both Atmos and DTS:X and decided on Atmos. Select one from [this list](https://airtable.com/appayGNkn3nSuXkaz/shruimhjdSakUPg2m/tbloLjoZKWJDnLtTc) and download the WAV. I copied the WAV file over to `~/.config/pipewire/filter-chain.conf.d/` where the config file lives.

Edit the file and replace all references to `hrir_hesuvi/hrir.wav` with the full path of your new impulse response WAV (e.g. `/home/gamer/.config/pipewire/filter-chain.conf.d/atmos.wav`).

Restart Pipewire:

```shell
systemctl --user restart pipewire.service
```

At this point you should be able to select the `Virtual Surround Sink` by clicking on the speaker icon on the tray. If it's not showing, open the hamburger menu and tick `Show virtual devices`.

[This video](https://www.youtube.com/watch?v=xCbLLge0tOE) is mixed to 7.1 channels and can be used to test the surround. A good test is to alternate between the regular headphones sink and the virtual surround one.

❕ The virtual surround setup should work for any distribution that uses Pipewire. On some distros, the use config file should be on `~/.config/pipewire/pipewire.conf.d` instead of `filter-chain.conf.d` like in Debian.

### Kernel

‼️ **NOTE**: I had some pretty bad jitter on some games (I believe DX12-based ones) as of recent. Using the [Liquorix kernel](#liquorix-kernel) instead of the Debian upstream made the problem go away.

You may want to install a newer Kernel version, or an alternative Kernel distribution more focussed on gaming and desktop workloads.

I'll explore some options in this section.

Feel free to install as many kernels as you'd like to test. At boot time, use the GRUB menu to select the one you'd like to use.

If and when you settle on one kernel over the others, just set up GRUB to use that as a default. If you don't know how to do that, [this Stack Exchange answer](https://unix.stackexchange.com/a/694348) has a good break down.

#### Debian `experimental`

If all you want is to follow the upstream Linux version a bit more closely, it's possible to pin and install it from the `experimental` sources.

To do so, first pin it by creating the following file:

`/etc/apt/preferences.d/experimental-kernel.pref`:

    Package: linux-image-amd64
    Pin: release a=experimental
    Pin-Priority: 950

Run `apt update && apt -y upgrade` and you should have a newer kernel installed. Reboot and voilà.

#### Liquorix Kernel

[Liquorix](https://liquorix.net/) describes itself in the following manner:

> Liquorix is an enthusiast Linux kernel designed for uncompromised responsiveness in interactive systems, enabling low latency compute in A/V production, and reduced frame time deviations in games.

They tend to publish new versions of their packages shortly after a new upstream version comes out.

To make use of it, follow the [instructions](https://liquorix.net/#install) on their website.

#### XanMod Kernel

[XanMod Kernel](https://xanmod.org/) describes itself as so:

> XanMod is a general-purpose Linux kernel distribution with custom settings and new features. Built to provide a stable, smooth and solid system experience.

To install, follow the [APT Repository instructions](https://xanmod.org/#apt_repository) on the website.

## Wrapping up

At this point, make sure you fully update and reboot your system.

By following this post, you should end up with a gaming-ready Debian system.

I have been running this setup for a few months with no major glitches or loss of functionality.

Since we brought Mesa down from `experimental` into our base system, Steam can be freely installed as a package (as opposed to a Flatpak) and benefit from it. It also ensures games outside of Steam are covered.

Thank you for reading and happy gaming!

---

#### Edit [15/12/2023]

Added a note explaining there's not harm in pulling firmware files from upstream.

Added a little more information on the kernel section, including link to instructions on how to configure the default.

#### Edit [06/02/2024]

Added a section on virtual surround sound for headphones

#### Edit [19/08/2024]

Added a note about recent jitter issues and fixing them with the Liquorix kernel.
