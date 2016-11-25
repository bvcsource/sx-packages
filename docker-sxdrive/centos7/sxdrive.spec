Name: sxdrive
Version: SRCVERSION
Release: 1%{?dist}
Summary: GUI client for Skylable Sx
License: AllRightsReserved
Group: Applications/Internet
URL: http://www.skylable.com/products/sxdrive
Source0: sxdrive-SRCVERSION.tar

BuildRequires: qt5-qtbase-devel qt5-qttools-devel

Requires: epel-release

%description
Skylable SxDrive is a multi-platform file-sync application which runs on your
PCs (Windows, MacOSX, Linux) and mobile devices (Android and iOS phones and
tablets).
It keeps your files synchronized between your Skylable SX cluster and the
devices you always bring with you.
You get the comfort of accessing the files stored in your storage cluster as a
plain directory on your PC or from a lightweight app on your phone, and at the
same time you get the protection and security of Skylable SX server.

%prep
%setup -q -n sxdrive-SRCVERSION

%global _hardened_build 1

%build
qmake-qt5
make

%install
rm -rf %{buildroot}
make install INSTALL_ROOT=%{buildroot}

%clean
rm -rf %{buildroot}

%check
make check

%files
%defattr(-,root,root,-)
%{_bindir}/sxdrive

%changelog
 * Thu Oct  2 2014 Skylable Dev Team <dev-team@skylable.com> - 0.1
- Initial build
