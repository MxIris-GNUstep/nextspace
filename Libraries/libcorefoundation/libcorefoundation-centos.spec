%if 0%{?el7}
%global debug_package %{nil}
%endif

Name:     libcorefoundation
Epoch:		0
Release:	0%{?dist}
Summary:	Apple CoreFoundation framework.
License:	Apache 2.0

Version:  5.4.2
URL:      https://github.com/apple/swift-corelibs-foundation
Source0:  libcorefoundation-%{version}.tar.gz
Source1:  CFFileDescriptor.h
Source2:  CFFileDescriptor.c
Source3:  CFNotificationCenter.c
Patch0:   CF_shared_on_linux.patch
Patch1:   CF_centos7.patch
Patch2:   CFFileDescriptor.patch
Patch3:   CFNotificationCenter.patch
Patch4:   CFString_centos.patch

%if 0%{?el7}
BuildRequires:	cmake3
BuildRequires:	llvm-toolset-7.0-clang >= 7.0.1
%define CMAKE cmake3
%define CMAKE_BUILD_TYPE -DCMAKE_BUILD_TYPE=Release
%else
BuildRequires:	cmake
BuildRequires:	clang >= 7.0.1
%define CMAKE cmake
%define CMAKE_BUILD_TYPE -DCMAKE_BUILD_TYPE=Debug
%endif
BuildRequires:	libdispatch-devel
BuildRequires:	libxml2-devel
BuildRequires:	libicu-devel
BuildRequires:	libcurl-devel
BuildRequires:	libuuid-devel

Requires:	libdispatch
Requires:	libxml2
Requires:	libicu
Requires:	libcurl
Requires:	libuuid

%description
Apple Core Foundation framework.

%package devel
Summary: Development header files for CoreFoundation framework.
Requires: %{name}%{?_isa} = %{epoch}:%{version}-%{release}

%description devel
Development header files for CoreFoundation framework.

%prep
%setup -n swift-corelibs-foundation-swift-%{version}-RELEASE
%patch -P0 -p1
%if 0%{?el7}
%patch -P1 -p1
%endif
%patch -P2 -p1
%patch -P3 -p1
%if 0%{?rhel} || 0%{?fedora} < 34
%patch -P4 -p1
%endif
cp %{_sourcedir}/CFNotificationCenter.c CoreFoundation/AppServices.subproj/
cp %{_sourcedir}/CFFileDescriptor.h CoreFoundation/RunLoop.subproj/
cp %{_sourcedir}/CFFileDescriptor.c CoreFoundation/RunLoop.subproj/
cp CoreFoundation/Base.subproj/SwiftRuntime/TargetConditionals.h CoreFoundation/Base.subproj/

%build
mkdir -p CoreFoundation/.build
cd CoreFoundation/.build
#CF_CFLAGS="-I/usr/NextSpace/include -I. -I`pwd`/../Base.subproj -DU_SHOW_DRAFT_API -DCF_BUILDING_CF -DDEPLOYMENT_RUNTIME_C -fconstant-cfstrings -fexceptions -Wno-switch -D_GNU_SOURCE -DCF_CHARACTERSET_DATA_DIR=\"CharacterSets\""
CF_CFLAGS="-I/usr/NextSpace/include -Wno-switch"
%if !0%{?el7}
  CF_CFLAGS+=" -Wno-implicit-const-int-float-conversion"
%endif
%if 0%{?el7}
source /opt/rh/llvm-toolset-7.0/enable
cmake3 .. \
%else
cmake .. \
%endif
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_C_FLAGS="$CF_CFLAGS" \
      -DCMAKE_SHARED_LINKER_FLAGS="-L/usr/NextSpace/lib -luuid" \
      -DCF_DEPLOYMENT_SWIFT=NO \
      -DBUILD_SHARED_LIBS=YES \
      -DCMAKE_INSTALL_PREFIX=/usr/NextSpace \
      -DCMAKE_INSTALL_LIBDIR=/usr/NextSpace/lib \
      -DCMAKE_LIBRARY_PATH=/usr/NextSpace/lib \
      %{CMAKE_BUILD_TYPE}
#%if 0%{?el7}
#      -DCMAKE_BUILD_TYPE=Release
#%else
#      -DCMAKE_BUILD_TYPE=Debug
#%endif

make %{?_smp_mflags}

%install
cd CoreFoundation/.build
# Make GNUstep framework
# Frameworks
mkdir -p %{buildroot}/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/%{version}
cp -R CoreFoundation.framework/Headers %{buildroot}/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/%{version}
cp -R CoreFoundation.framework/libCoreFoundation.so %{buildroot}/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/%{version}/libCoreFoundation.so.%{version}
cd %{buildroot}/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions
ln -s %{version} Current
cd ..
ln -s Versions/Current/Headers Headers
ln -s Versions/Current/libCoreFoundation.so.%{version} libCoreFoundation.so
# lib
mkdir -p %{buildroot}/usr/NextSpace/lib
cd %{buildroot}/usr/NextSpace/lib
ln -s ../Frameworks/CoreFoundation.framework/libCoreFoundation.so libCoreFoundation.so
# include
mkdir -p %{buildroot}/usr/NextSpace/include
cd %{buildroot}/usr/NextSpace/include
ln -s ../Frameworks/CoreFoundation.framework/Headers CoreFoundation

%check

%files
/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/%{version}/libCoreFoundation.so.%{version}
/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/Current
/usr/NextSpace/Frameworks/CoreFoundation.framework/libCoreFoundation.so
/usr/NextSpace/lib/libCoreFoundation.so

%files devel
/usr/NextSpace/Frameworks/CoreFoundation.framework/Versions/%{version}/Headers
/usr/NextSpace/Frameworks/CoreFoundation.framework/Headers
/usr/NextSpace/include/CoreFoundation

#
# Package install
#
# for %pre and %post $1 = 1 - installation, 2 - upgrade
#%pre
#%post
#if [ $1 -eq 1 ]; then
#    ln -s /usr/NextSpace/Frameworks/CoreFoundation.framework/libCoreFoundation.so /usr/NextSpace/lib/libCoreFoundation.so
#fi
#%post devel
#if [ $1 -eq 1 ]; then
#    ln -s /usr/NextSpace/Frameworks/CoreFoundation.framework/Headers /usr/NextSpace/include/CoreFoundation
#fi

# for %preun and %postun $1 = 0 - uninstallation, 1 - upgrade.
#%preun
#if [ $1 -eq 0 ]; then
#    rm /usr/NextSpace/lib/libCoreFoundation.so
#fi
#%preun devel
#if [ $1 -eq 0 ]; then
#    rm /usr/NextSpace/include/CoreFoundation
#fi

%postun
/bin/rm -rf /usr/NextSpace/Frameworks/CoreFoundation.framework

%changelog
* Tue Jan 18 2022 flatpak-session-helper
Renamed to libcorefoundation to not interfere with libfoundation
on Fedora.

* Tue Dec 1 2020 Sergii Stoian <stoyan255@gmail.com>
- CFFileDescriptor was added to the build.

* Sat Nov 21 2020 Sergii Stoian <stoyan255@gmail.com>
- Fixed building on CentOS 7.

* Tue Nov 17 2020 Sergii Stoian <stoyan255@gmail.com>
- Include implementation of CFNotificationCenter.
- Make installation of library as GNUstep framework.

* Wed Nov 11 2020 Sergii Stoian <stoyan255@gmail.com>
- Initial spec.
