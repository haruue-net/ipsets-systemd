# Maintainer: Haruue Icymoon <i@haruue.moe>

pkgname=ipsets-systemd
pkgver=1.0
pkgrel=1
pkgdesc="Scripts & systemd unit for multiple ipset management"
arch=('any')
url="https://github.com/haruue-net/ipsets-systemd"
license=('APACHE')
depends=('ipset' 'systemd' 'bash' 'coreutils' 'sed')
source=("ipsets.sh" "ipsets@.service")
sha256sums=('SKIP' 'SKIP')

pkgver() {
    git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

package() {
  cd "$srcdir"
  install -Dm755 ipsets.sh "$pkgdir/usr/lib/ipsets/ipsets.sh"
  install -Dm644 ipsets@.service "$pkgdir/usr/lib/systemd/system/ipsets@.service"
  sed -i 's+/etc/systemd/system/ipsets@.service.d/+/usr/lib/ipsets/+g' \
    "$pkgdir/usr/lib/systemd/system/ipsets@.service"
}
