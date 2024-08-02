# coreutils

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
