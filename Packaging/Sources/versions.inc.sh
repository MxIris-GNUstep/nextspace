#----------------------------------------
# Versions
#----------------------------------------
libdispatch_version=5.9.2
libcorefoundation_version=5.9.2
libobjc2_version=2.1
gnustep_make_version=2_9_1
gnustep_base_version=1_29_0
gnustep_gui_version=0_30_0
#gnustep_back_version=0_30_0

gorm_version=1_3_1
projectcenter_version=0_7_0

roboto_mono_version=0.2020.05.08
roboto_mono_checkout=master

ECHO="/usr/bin/echo -e"

#----------------------------------------
# Paths
#----------------------------------------
_PWD=`pwd`
BUILD_ROOT="${_PWD}/BUILD_ROOT"
if [ ! -d ${BUILD_ROOT} ]; then
  mkdir ${BUILD_ROOT}
fi
${ECHO} "Build in:\t${BUILD_ROOT}"

# Directory where nextspace GitHub repo resides
cd ../..
PROJECT_DIR=`pwd`
cd ${PWD}
${ECHO} "NextSpace:\t${PROJECT_DIR}"
cd ${_PWD}

#----------------------------------------
# Tools
#----------------------------------------
# Make
MAKE_CMD=make
if type "gmake" 2>/dev/null >/dev/null ;then
  MAKE_CMD=gmake
fi
# Linker
ld -v | grep "gold" 2>&1 > /dev/null
if [ "$?" = "1" ]; then
	${ECHO} "Setting up Gold linker..."
	sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 10
	sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.gold 100
else
  ${ECHO} "Using linker:\tGold"
fi
# Compiler
which clang 2>&1 > /dev/null || `echo "No clang compiler found. Please install clang package."; exit 1`
C_COMPILER=clang
which clang++ 2>&1 > /dev/null || `echo "No clang++ compiler found. Please install clang++ package."; exit 1`
CXX_COMPILER=clang++

#----------------------------------------
# OS release
#----------------------------------------
OS_NAME=`cat /etc/os-release | grep "^ID=" | awk -F= '{print $2}'`
OS_VERSION=`cat /etc/os-release | grep "^VERSION_ID" | awk -F= '{print $2}'`
VER=`echo ${OS_VERSION} | awk -F\" '{print $2}'`
if [ -n "${VER}" ] && [ "${VER}" != " " ]; then
  VER=`echo ${VER} | awk -F\. '{print $2}'`
  if [ -n "${VER}" ] && [ "${VER}" != " " ]; then
    OS_VERSION=${VER}
  fi
fi
${ECHO} "OS:\t\t${OS_NAME}-${OS_VERSION}"

if [ ${OS_NAME} = "debian" ] || [ ${OS_NAME} = "ubuntu" ]; then
    . ./${OS_NAME}-${OS_VERSION}.deps.sh || exit 1
#else
#    ${ECHO} "${OS_NAME} ${OS_VERSION} is not supported by these build scripts."
#    exit 1
fi

#----------------------------------------
# Functions
#----------------------------------------
git_remote_archive() {
  local url="$1"
  local dest="$2"
  local branch="$3"

  cd ${BUILD_ROOT}

  if [ -d "$dest" ];then
    echo "$dest exists, skipping"
  else
    git clone --recurse-submodules "$url" "$dest"
    cd "$dest"
    if [ "$branch" != "master" ];then
      git checkout $branch
    fi
  fi
}

install_packages() {
  apt-get install -y $@ || exit 1
#  for PKG in $@ ;do
#    ${ECHO} $PKG
#    apt-get install -y  || exit 1
#  done
}

uninstall_packages() {
  apt-get purge -y $@
#  for PKG in $@ ;do
#    ${ECHO} $PKG
#    apt-get purge -y $PKG || exit 1
#  done
}