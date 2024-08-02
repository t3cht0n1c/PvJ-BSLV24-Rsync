# static-binaries

## busybox

The idea is to use a statically compiled busybox binary to avoid backdoor'd binaries on a system, and help get a better overview of system activity from a *more* trustworthy shell. This is not a perfect solution, but should be one additional tool to have available in case. The `menuconfig` and `libncurses-dev` dependancy were suggested by ChatGPT to get this working (it's much easier to configure a static build this way).

```bash
mkdir ~/src
sudo sed -i_bkup 's/# deb-src/deb-src/g' /etc/apt/sources.list
sudo sed -i_bkup 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update
# Essentials
sudo apt install -y make automake texinfo flex
# For yara
sudo apt install -y bison libtool pkg-config libprotobuf-c-dev libssl-dev libjansson-dev libmagic-dev
# For busybox
libncurses-dev

cd ~/src
apt-get source busybox
cd busybox-1.36.1
make defconfig
make menuconfig
# Settings -> Build Options -> [*] Build BusyBox as a static binary (no shared libs)
make
file ./busybox

# Now to use it exclusively on a system
mkdir ~/busybox-bin
cd ~/busybox-bin
cp ~/src/busybox-1.36.1/busybox .
for cmd in $(./busybox --list); do ln -s busybox "$cmd"; done
export PATH=~/busybox-bin
which ls
```

## coreutils

[Statically compiled coreutils binaries](https://straysheep.dev/blog/2024/07/12/atomic-red-team-x-unix-artifacts-collector/#coreutils). Built on Ubuntu 24.04, tested on Ubuntu 16.04.

```bash
mkdir ~/src
# 22.04 and earlier
sudo sed -i_bkup 's/# deb-src/deb-src/g' /etc/apt/sources.list
# 24.04+
sudo sed -i_bkup 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update
# Essentials
sudo apt install -y make automake texinfo flex
# For yara
sudo apt install -y bison libtool pkg-config libprotobuf-c-dev libssl-dev libjansson-dev libmagic-dev

cd ~/src
apt-get source coreutils
rm -rf ~/src/coreutils-9.4
tar -xvf ./coreutils_9.4.orig.tar.xz
cd ./coreutils-9.4
./configure LDFLAGS="-static" FORCE_UNSAFE_CONFIGURE=1 --disable-xattr --disable-libcap --disable-libsmack --without-selinux --without-gmp
make
# Everything's built under ./src/
find ./src -type f -executable -ls
```
