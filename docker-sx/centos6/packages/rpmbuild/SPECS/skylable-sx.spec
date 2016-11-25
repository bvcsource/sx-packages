%global _hardened_build 1
%define relabel_files() \
restorecon -R -i /usr/sbin/sx.fcgi; \
restorecon -R -i /usr/lib/systemd/system/sx-nginx.service; \
restorecon -R -i /usr/lib/systemd/system/sxserver.service; \
restorecon -R -i /var/lib/sxserver/storage; \
restorecon -R -i /var/log/sxserver; \
restorecon -R -i /var/run/sxserver; \

Name: skylable-sx
Version: @VER@
Release: @RELEASE@%{?dist}
Summary: A reliable and scalable storage cluster
Group: System Environment/Daemons
# See COPYING for license breakdown
License: GPLv2 with exceptions and LGPLv2+ and BSD and MIT
URL: http://www.skylable.com/products/sx
Source0: sx-%{version}-@RELEASE@.tar

# initscripts for CentOS, because systemd doesn't work with docker
# no selinux either, the policy is only meant to be used with systemd
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
Source1: sxserver.init
Source2: sxserver.sysconfig
%else
Patch0: sxserver.patch
Source1: sx-nginx.service
Source2: sxserver.service
Source3: sxserver.conf
Source4: sxserver.te
Source5: sxserver.if
Source6: sxserver.fc
Source7: sxserver_selinux.8
%endif
BuildRequires: libtool-ltdl-devel, libtool, yajl-devel, pkgconfig(libcrypto), pkgconfig(openssl), zlib-devel, perl(List::Util), perl(Time::HiRes), perl(LWP::UserAgent), perl(URI), perl(URI::Escape), perl(HTTP::Date), perl(MIME::Base64), perl(Digest::HMAC_SHA1), perl(Digest::SHA), perl(JSON), pkgconfig(nss), pkgconfig(sqlite3), curl-devel, fuse-devel
Requires: %{name}-client%{?_isa} = %{version}-%{release}, logrotate, openssl
Requires: policycoreutils, libselinux-utils
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
Requires(postun): initscripts
%else
BuildRequires: systemd, selinux-policy-devel, fcgi-devel, nginx
Requires: nginx
Requires(post): systemd, selinux-policy-base >= %{_selinux_policy_version}, policycoreutils
Requires(preun): systemd
Requires(postun): systemd, policycoreutils
%endif

%description
Skylable SX is a storage cluster solution featuring a shared-nothing
architecture, built with the goal of being scalable, reliable, secure and fast.

You control how many copies of your data you want to keep on a per-volume
basis.  In case of node failure, your data will be still available on the
surviving nodes.  When you replace the dead node with a new one, the new node
will be automatically repopulated with a copy of your data.

If your data needs outgrow the size of your cluster, you can grow the size of
your existing nodes or add new nodes. The cluster will automatically rebalance
the data among all nodes of the cluster using our optimized version of the
consistent hashing algorithm.

Skylable SX supports deduplication, client-side encryption, on-the-fly
compression and encrypts all communications (client-to-server and
server-to-server) by default.

%package client
Summary: Skylable SX client
Group: Cloud Infrastructure
Requires: %{name}-libs%{?_isa} = %{version}-%{release}, ca-certificates

%description client
Skylable SX client software.

%package devel
Summary: Skylable SX devel
Group: Development/Libraries
Requires: %{name}-libs%{?_isa} = %{version}-%{release}
License: LGPLv2+ with exceptions

%description devel
Development files for Skylable SX.

%package libs
Summary: Skylable SX library and plugins
Group: System Environment/Libraries
License: LGPLv2+ with exceptions and MIT

%description libs
Skylable SX library and plugins.

%prep
%setup -q -n sx-%{version}
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
%else
%patch0 -p 1
%endif

%build
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
%else
cp %{SOURCE4} .
cp %{SOURCE5} .
cp %{SOURCE6} .
make -f /usr/share/selinux/devel/Makefile sxserver.pp
%endif
#sepolicy manpage -p . -d sxserver
# libtool doesn't detect that /usr/lib64 should be in sys_lib_dlsearch_path_spec
# use the patched system libtool instead of shipped one

# difference from official fedora package:
# use embedded sqlite3, and other libs where needed (system too old)
# this makes it possible to support centos7, which would otherwise wouldn't meet
# minimum package requirements
# prefer system nginx (it gets security updates, etc.), except for CentOS 6
%configure --with-nss --without-ssl --without-included-ltdl \
	%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
	%else
	--disable-sxhttpd
	%endif

(cd client && rm -f libtool && ln -s /usr/bin/libtool .)
(cd server && rm -f libtool && ln -s /usr/bin/libtool .)
(cd libsxclient && rm -f libtool && ln -s /usr/bin/libtool .)

make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}
%{__install} -d %{buildroot}%{_sysconfdir}/logrotate.d/
%{__install} -d %{buildroot}%{_sysconfdir}/sysconfig/
mv %{buildroot}/usr/share/doc/sx/logrotate.d/sxserver %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
rm -rf %{buildroot}/usr/share/doc/sx/*
mkdir -p %{buildroot}/run
install -d -m 0755 %{buildroot}/run/sxserver/
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
%{__install} -p -D -m 0755 %{SOURCE1} %{buildroot}%{_initddir}/sxserver
%{__install} -p -D -m 0755 %{SOURCE2} %{buildroot}%{_sysconfdir}/sysconfig/sxserver
%else
mkdir -p %{buildroot}%{_unitdir}
%{__install} -p -D -m 0644 %{SOURCE1} %{buildroot}%{_unitdir}
%{__install} -p -D -m 0644 %{SOURCE2} %{buildroot}%{_unitdir}

mkdir -p %{buildroot}%{_tmpfilesdir}
install -m 0644 %{SOURCE3} %{buildroot}%{_tmpfilesdir}/

install -d %{buildroot}%{_datadir}/selinux/packages
install -m 644 sxserver.pp %{buildroot}%{_datadir}/selinux/packages
install -d %{buildroot}%{_datadir}/selinux/devel/include/contrib
install -m 644 %{SOURCE5} %{buildroot}%{_datadir}/selinux/devel/include/contrib/
install -d %{buildroot}%{_mandir}/man8/
install -m 644 %{SOURCE7} %{buildroot}%{_mandir}/man8/sxserver_selinux.8
install -d %{buildroot}/etc/selinux/targeted/contexts/users/
%endif


%check
make check VERBOSE=1

# This informs systemd about our services.
%post
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add sxserver
%else
%systemd_post sxserver.service
%systemd_post sx-nginx.service
# This sets up the SELinux policy
semodule -n -i %{_datadir}/selinux/packages/sxserver.pp
if /usr/sbin/selinuxenabled ; then
    /usr/sbin/load_policy
    %relabel_files

fi;
%endif
if [ $1 -ge 1 ]; then
	# Package upgrade or uninstall/reinstall
	if [ -f /etc/sxserver/sxsetup.conf ]; then
		/usr/sbin/sxsetup --upgrade
	fi
fi
exit 0

%preun
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
if [ $1 -eq 0 ] ; then
    /sbin/service sxserver stop >/dev/null 2>&1
    /sbin/chkconfig --del sxserver
fi
%else
%systemd_preun sxserver.service
%systemd_preun sx-nginx.service
%endif

%postun
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
%else
%systemd_postun sxserver.service
%systemd_postun sx-nginx.service
# This removes the SELinux policy
if [ $1 -eq 0 ]; then
    semodule -n -r sxserver
    if /usr/sbin/selinuxenabled ; then
       /usr/sbin/load_policy
       %relabel_files

    fi;
fi;
%endif
exit 0

%post libs -p /sbin/ldconfig

%postun libs -p /sbin/ldconfig

%files
%doc COPYING README NEWS QUICKSTART UPGRADE doc/manual/manual.pdf
%{_sbindir}/sx*
%config(noreplace) %{_sysconfdir}/sxserver/
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%if 0%{?rhel} <= 7 && 0%{?rhel} > 0
%{_initddir}/sxserver
%dir /var/run/sxserver
%config(noreplace) %{_sysconfdir}/sysconfig/sxserver
%else
%{_unitdir}/sx-nginx.service
%{_unitdir}/sxserver.service
%{_tmpfilesdir}/sxserver.conf
%attr(0600,root,root) %{_datadir}/selinux/packages/sxserver.pp
%{_datadir}/selinux/devel/include/contrib/sxserver.if
%endif
%exclude /var/run/sxserver
# do not remove logfiles, but still associate with package
%attr(755,nobody,nobody) %dir /var/log/sxserver/
# exclude symlinks that belong in dev packages
%exclude %{_libdir}/*.la
%exclude %{_libdir}/sxclient/*.la
%exclude %{_libdir}/*.a
%exclude %{_libdir}/sxclient/*.a
%exclude /usr/include/f*
%exclude %{_libdir}/libfcgi*
%attr(755,nobody,nobody) %dir /run/sxserver/

%{_mandir}/man5/*
%{_mandir}/man8/*

%files libs
%doc COPYING
%dir %{_libdir}/sxclient
%{_libdir}/libsxclient.so.*
%{_libdir}/sxclient/libsxf_*-*.so

%files devel
%doc COPYING
%{_includedir}/sx.h
%{_libdir}/*.so
%exclude %{_libdir}/sxclient/libsxf_*-*.so
%{_libdir}/sxclient/libsxf*.so

%files client
%doc COPYING README NEWS
%{_bindir}/sx*
%{_mandir}/man1/*

%changelog
* Fri Dec 04 2015 Skylable Dev Team <dev-team@skylable.com> - 2.0-1
- new upstream release SX 2.0
- add fuse build dependency
- run sxsetup --upgrade on upgrades (noop if no changes needed)
- libsxclient.so.2 -> libsxclient.so.3

* Mon Jul 27 2015 Skylable Dev Team <dev-team@skylable.com> - 1.2-1
- new upstream release SX 1.2
- renamed libsx.so.2 to libsxclient.so.2
- use version macro in source URL

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Tue May 12 2015 Skylable Dev Team <dev-team@skylable.com> - 1.1-2
- update tag

* Tue May 12 2015 Skylable Dev Team <dev-team@skylable.com> - 1.1-1
- new upstream release SX 1.1
- added server manpages
- upgrade from 1.0 will require running /usr/sbin/sxsetup --upgrade
- added python dependency for new sxdump script
- do not automatically restart on upgrades (due to manual step)
- ignore nonexistent files when relabeling on package removal
- use builtin {_selinux_policy_version} macro

* Thu Mar 19 2015 Skylable Dev Team <dev-team@skylable.com> - 1.0-7
- Update description

* Thu Mar 12 2015 Skylable Dev Team <dev-team@skylable.com> - 1.0-5
- License field updated

* Mon Feb 16 2015 Skylable Dev Team <dev-team@skylable.com> - 1.0-4
- SELinux policy

* Fri Feb 13 2015 Skylable Dev Team <dev-team@skylable.com> - 1.0-3
- create required directories in package
- fix pidfile in sxnginx.service
- redirect /usr/sbin/sxserver to systemctl
- set SELinux label on sxserver to allow nginx <-> sx.fcgi communication via socket

* Thu Feb  5 2015 Tom Callaway <spot@fedoraproject.org> - 1.0-2
- clean up spec file
- add systemd support

* Tue Dec 9 2014 Skylable Dev Team <dev-team@skylable.com> - 1.0
- initial packaging
