
Creating DEB packages:

```bash
sudo apt-get install -y fakeroot
mkdir -p dist/deb/DEBIAN dist/deb/usr/bin
cp target/${{ matrix.target }}/release/${{ matrix.artifact_name }} dist/deb/usr/bin/
cat << EOF > dist/deb/DEBIAN/control
Package: sample
Version: ${{ github.event.inputs.version }}
Architecture: ${{ contains(matrix.target, 'aarch64') && 'arm64' || 'amd64' }}
Maintainer: Sample Maintainer <maintainer@example.com>
Description: Sample application
EOF
fakeroot dpkg-deb --build dist/deb dist/${{ matrix.asset_name }}.deb
```

Creating RPM packages:

```bash
sudo apt-get install -y rpm
mkdir -p dist/rpm/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp target/${{ matrix.target }}/release/${{ matrix.artifact_name }} dist/rpm/SOURCES/
cat << EOF > dist/rpm/SPECS/sample.spec
Name: sample
Version: ${{ github.event.inputs.version }}
Release: 1
Summary: Sample application
License: MIT
BuildArch: $(uname -m)

%description
Sample description

%install
mkdir -p %{buildroot}/usr/bin
cp %{_sourcedir}/sample %{buildroot}/usr/bin/sample

%files
/usr/bin/sample

%define __strip /bin/true
%define __spec_install_post %{nil}
EOF
rpmbuild -bb --define "_topdir $(pwd)/dist/rpm" dist/rpm/SPECS/sample.spec
find dist/rpm/RPMS -name '*.rpm' -exec mv {} dist/${{ matrix.asset_name }}.rpm \;
```