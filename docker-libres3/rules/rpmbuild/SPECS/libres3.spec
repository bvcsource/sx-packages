Name: libres3
Version: @VER@
Release: @RELEASE@%{?dist}
Summary: Amazon S3 compatible server

Group: System Environment/Daemons
License: GPLv2
URL: http://www.skylable.com/products/libres3
Source0: %{name}-%{version}-@RELEASE@.tar
Source1: %{name}.init
Source2: %{name}.sysconfig

BuildRequires: ocaml >= 3.12.1
BuildRequires: /usr/bin/camlp4of, /usr/bin/camlp4rf, /usr/bin/camlp4
BuildRequires: pcre-devel, openssl-devel, make, m4, libev-devel
# For EPEL-6:
BuildRequires: ncurses-devel, /usr/bin/ocamlopt

Requires: openssl
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
Requires(postun): initscripts

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
LibreS3 is a robust Open Source replacement for the Amazon S3 service,
implementing (a subset of) the S3 REST API.

Standard S3 client libraries and tools (for example s3cmd, python-boto, ...)
can be used to access it.

It uses Skylable SX as the storage backend, which automatically provides
data deduplication and replication.

%prep
%setup -q -n libres3-%{version}

%build

./configure --enable-tests --prefix=/usr\
            --localstatedir /var --sharedstatedir /var/lib\
            --sysconfdir /etc\
            --destdir=%{_topdir}/BUILDROOT/%{name}-%{version}-%{release}.%{_arch}

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
make reinstall
%{__install} -d %{buildroot}%{_sysconfdir}/logrotate.d/
%{__install} -d %{buildroot}%{_sysconfdir}/sysconfig/
mv %{buildroot}/usr/share/doc/libres3/logrotate.d/libres3 %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
%{__install} -p -D -m 0755 %{SOURCE1} %{buildroot}%{_initddir}/%{name}
%{__install} -p -D -m 0755 %{SOURCE2} %{buildroot}%{_sysconfdir}/sysconfig/%{name}
mkdir %{buildroot}/var/log/%{name} -p
mkdir %{buildroot}/var/run/%{name} -p

%clean
rm -rf %{buildroot}

%post
# This adds the proper /etc/rc*.d links for the script
if [ $1 -eq 1 ]; then
    /sbin/chkconfig --add %{name}
fi

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%postun
if [ "$1" -ge "1" ] ; then
    /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi
if [ $1 -eq 0 ]; then
    rm -rf /var/lib/libres3 /var/run/libres3
fi

%check
make check

%files
%defattr(-,root,root,-)
%doc %{_docdir}/%{name}/COPYING
%doc %{_docdir}/%{name}/README
%doc %{_docdir}/%{name}/s3genlink.py
%doc %{_docdir}/%{name}/manual.pdf
%exclude %{_docdir}/%{name}/*.pyc
%exclude %{_docdir}/%{name}/*.pyo
%{_sbindir}/libres3*
/var/log/%{name}/info.log

%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/%{name}/
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}

%{_initddir}/%{name}

%dir /var/log/%{name}
%dir /var/run/%{name}
# do not remove logfiles, but still associate with package
%ghost %config /var/log/%{name}/

%changelog
* Tue Apr 29 2014 Skylable Dev Team <dev-team@skylable.com> - 0.1
- http://www.skylable.com/products/libres3
