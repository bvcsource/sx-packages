Name: skylable-sx
Version: @VER@
Release: @RELEASE@%{?dist}
Summary: Scalable public and private cloud storage

Group: System Environment/Daemons
License: GPLv2
URL: http://www.skylable.com/products/sx
Source0: sx-%{version}-@RELEASE@.tar
Source1: sxserver.init
Source2: sxserver.sysconfig


%if 0%{?rhel} <= 5 && 0%{?rhel} > 0
# RHEL5 doesn't have yajl-devel, and pkgconfig() macro, also libtool too old,
# can't build ltdl with it
BuildRequires: pkgconfig, openssl-devel, zlib-devel, libidn-devel, perl(List::Util), perl(Time::HiRes), perl(LWP::UserAgent), perl(URI), perl(URI::Escape), perl(HTTP::Date), perl(MIME::Base64), perl(Digest::HMAC_SHA1), perl(Digest::SHA), perl(JSON)
%define _initddir %{_initrddir}
%else
BuildRequires: libtool-ltdl-devel, libtool, yajl-devel, pkgconfig(libcrypto), pkgconfig(openssl), zlib-devel, pkgconfig(libidn), perl(List::Util), perl(Time::HiRes), perl(LWP::UserAgent), perl(URI), perl(URI::Escape), perl(HTTP::Date), perl(MIME::Base64), perl(Digest::HMAC_SHA1), perl(Digest::SHA), perl(JSON), pkgconfig(nss)
%endif

Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
Requires(postun): initscripts
Requires: python, openssl

BuildRoot: %(mktemp -ud %{_tmppath}/sxserver-%{version}-%{release}-XXXXXX)

%description
Skylable Sx is a reliable, fully distributed cluster solution for your data storage needs.

With Sx you can aggregate the disk space available on multiple servers and merge it into a single storage system.
The cluster makes sure that your data is always replicated over multiple nodes
(the exact number of copies is defined by the sysadmin) and synchronized.

Additionally Sx has built-in support for deduplication, client-side encryption, on-the-fly compression and much more.

%prep
%setup -q -n sx-%{version}

%global _hardened_build 1

%build

%if 0%{?rhel} <= 5 && 0%{?rhel} > 0
# use shipped libtool, system one too old, cons: will have rpath in bins
%configure
%else
# libtool doesn't detect that /usr/lib64 should be in sys_lib_dlsearch_path_spec
# use the patched system libtool instead of shipped one
%configure --without-included-ltdl --with-nss --without-ssl
(cd client && rm -f libtool && ln -s /usr/bin/libtool .)
(cd server && rm -f libtool && ln -s /usr/bin/libtool .)
(cd libsx && rm -f libtool && ln -s /usr/bin/libtool .)
%endif

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
%{__install} -d %{buildroot}%{_sysconfdir}/logrotate.d/
%{__install} -d %{buildroot}%{_sysconfdir}/sysconfig/
mv %{buildroot}/usr/share/doc/sx/logrotate.d/sxserver %{buildroot}%{_sysconfdir}/logrotate.d/sxserver
%{__install} -p -D -m 0755 %{SOURCE1} %{buildroot}%{_initddir}/sxserver
%{__install} -p -D -m 0755 %{SOURCE2} %{buildroot}%{_sysconfdir}/sysconfig/sxserver
rm -rf %{buildroot}/usr/share/doc/sx/*

%clean
rm -rf %{buildroot}

%post
/sbin/ldconfig
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add sxserver

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service sxserver stop >/dev/null 2>&1
    /sbin/chkconfig --del sxserver
fi

%postun
/sbin/ldconfig

%check
make check VERBOSE=1

%files
%defattr(-,root,root,-)
%doc COPYING README NEWS QUICKSTART UPGRADE doc/manual/manual.pdf
%{_bindir}/sx*
%{_sbindir}/sx*
%{_mandir}/man1/*
%{_mandir}/man5/*
%{_mandir}/man8/*

%dir %{_libdir}/sxclient
%{_libdir}/libsxclient.so.*
%{_libdir}/sxclient/libsxf*.so

%config(noreplace) %{_sysconfdir}/sysconfig/sxserver
%config(noreplace) %{_sysconfdir}/sxserver/
%config(noreplace) %{_sysconfdir}/logrotate.d/sxserver

%{_initddir}/sxserver

%dir /var/log/sxserver
%dir /var/run/sxserver
# do not remove logfiles, but still associate with package
%ghost %config /var/log/sxserver/

%exclude /usr/include/*
%exclude %{_libdir}/libfcgi*
# exclude symlinks that belong in dev packages
%exclude %{_libdir}/*.so
%exclude %{_libdir}/*.la
%exclude %{_libdir}/sxclient/*.la
%if 0%{?rhel} <= 5 && 0%{?rhel} > 0
# CentOS5 uses builtin libtool, doesn't create the .a files
%else
%exclude %{_libdir}/*.a
%exclude %{_libdir}/sxclient/*.a
%endif

%changelog
* Tue Dec 9 2014 Skylable Dev Team <dev-team@skylable.com> - 1.0
* Tue Sep 30 2014 Skylable Dev Team <dev-team@skylable.com> - 0.9
* Wed Aug 6 2014 Skylable Dev Team <dev-team@skylable.com> - 0.4
* Wed Jun 11 2014 Skylable Dev Team <dev-team@skylable.com> - 0.3
* Thu May 8 2014  Skylable Dev Team <dev-team@skylable.com> - 0.2
* Mon Apr 14 2014 Skylable Dev Team <dev-team@skylable.com> - 0.1
- http://www.skylable.com/2014/04/skylable-sx-beta-released/
