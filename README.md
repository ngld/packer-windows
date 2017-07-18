# Windows Templates for Packer

### Introduction

This repository contains Windows templates that can be used to create boxes for Vagrant using Packer ([Website](http://www.packer.io)) ([Github](http://github.com/mitchellh/packer)).

It is based on https://github.com/joefitzgerald/packer-windows and has been adapted to my own needs. I've replaced the way updates are installed to cut down the build time. Chocolatey and Rsync are now installed by default and I've removed files I don't use to reduce clutter.

### Packer Version

[Packer](https://github.com/mitchellh/packer/blob/master/CHANGELOG.md) `1.0.0` or greater is required.

### Product Keys

The `Autounattend.xml` files are configured to work correctly with trial ISOs (which will be downloaded and cached for you the first time you perform a `packer build`). If you would like to use retail or volume license ISOs, you need to update the `UserData`>`ProductKey` element as follows:

* Uncomment the `<Key>...</Key>` element
* Insert your product key into the `Key` element

If you are going to configure your VM as a KMS client, you can use the product keys at http://technet.microsoft.com/en-us/library/jj612867.aspx. These are the default values used in the `Key` element.

### Windows Updates

These templates use [WSUS Offline](http://wsusoffline.net/) to install required Windows updates. This avoids multiple downloads of the same updates between builds but you'll have to run the `wsusoffline.sh` script at least once before you can run Packer.

### OpenSSH / WinRM

[Packer](http://packer.io) supports WinRM but I couldn't get the `windows-restart` provisioner work reliably with it. The WinRM command triggering the restart returns `3011` as the exit code which means "Restart required". The `windows-restart` provisioner then aborts the build because of a non-zero exit code.

### Using .box Files With Vagrant

The generated box files include a Vagrantfile template that is suitable for
use with Vagrant 1.6.2+, which includes native support for Windows and uses
WinRM to communicate with the box.

### Getting Started

Trial versions of Windows 7 / 10 are used by default. These images can be used for 90 days without activation.

Alternatively – if you have access to [MSDN](http://msdn.microsoft.com) or [TechNet](http://technet.microsoft.com/) – you can download retail or volume license ISO images and place them in the `iso` directory. If you do, you should supply appropriate values for `iso_url` (e.g. `./iso/<path to your iso>.iso`) and `iso_checksum` (e.g. `<the md5 of your iso>`) to the Packer command.

### Variables

The Packer templates support the following variables:

| Name                | Description                                                      |
| --------------------|------------------------------------------------------------------|
| `iso_url`           | Path or URL to ISO file                                          |
| `iso_checksum`      | Checksum (see also `iso_checksum_type`) of the ISO file          |
| `iso_checksum_type` | The checksum algorithm to use (out of those supported by Packer) |
| `autounattend`      | Path to the Autounattend.xml file                                |

### Contributing

Pull requests welcomed.
