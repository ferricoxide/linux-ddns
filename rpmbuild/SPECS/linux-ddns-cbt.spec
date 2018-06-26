Name:		linux-ddns-cbt
Version:	1.0
Release:	3
Summary:	Dynamic DNS Update Tool

Group:		System Environment/Base
License:	Apache 2.0
URL:		(none)
Source0:	README.md
Source1:	linux-ddns.conf
Source2:	nsupdate-boot
Source3:	nsupdate.sh
Source4:	nsupdateprep.sh

BuildRequires:	rpm
Requires:	bind-utils
BuildArch:	noarch

%description
This RPM wraps the nsupdate tool from the bind-utils RPM to ease
the automated updating of DDNS records associated with a running,
EnterprisE Linux based host. See the included README file for
details on the use of this package.

%prep


%build


%install
rm -rf ${RPM_BUILD_ROOT}
install -d -m 0755 ${RPM_BUILD_ROOT}/usr/sbin
install -d -m 0755 ${RPM_BUILD_ROOT}/usr/share/linux-ddns
install -d -m 0755 ${RPM_BUILD_ROOT}/etc/rc.d/init.d
install -m 644 %{Source0} ${RPM_BUILD_ROOT}/usr/share/linux-ddns
install -m 644 %{Source1} ${RPM_BUILD_ROOT}/etc
install -m 754 %{Source2} ${RPM_BUILD_ROOT}/etc/rc.d/init.d
install -m 754 %{Source3} ${RPM_BUILD_ROOT}/usr/sbin
install -m 754 %{Source4} ${RPM_BUILD_ROOT}/usr/sbin

%clean
rm -rf ${RPM_BUILD_ROOT}


%files
%defattr(-,root,root,-)
/usr/sbin/nsupdate.sh
/usr/sbin/nsupdateprep.sh
/etc/rc.d/init.d/nsupdate-boot
%config(noreplace) /etc/linux-ddns.conf
%doc /usr/share/linux-ddns/README.md


%post
#!/bin/bash
/sbin/chkconfig --add nsupdate-boot
/sbin/chkconfig --nsupdate-boot on
/sbin/service nsupdate-boot start

%preun
/sbin/chkconfig nsupdate-boot off
/sbin/chkconfig --del nsupdate-boot


%changelog

* Tue Jun 26 2018 Thomas H Jones II <thomas.jones@plus3it.com>
- Update software to allow persistent behavior-modification
- through use of the /etc/linux-ddns.conf file
* Tue Feb 20 2018 Thomas H Jones II <thomas.jones@plus3it.com>
- Update scripts to be a little more stylistically- and 
- functionally-sound
- Update packaging to include setting up of boot-time (re)running
- of the DDNS request
* Wed Mar 22 2017 Thomas H Jones II <thomas.jones@plus3it.com>
- Initial bundling of previously stand-alone DDNS scripts
- into an installable/trackable RPM package.
