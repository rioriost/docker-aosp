FROM ubuntu:14.04
MAINTAINER Rio Fujita <rifujita@microsoft.com>

# See https://source.android.com/setup/

# Using a separate output directory
# See the section, https://source.android.com/setup/build/initializing#using-a-separate-output-directory
#ENV OUT_DIR_COMMON_BASE=kubernetes persistent volume?

# Working directory where repo runs in
ENV WORKING_DIRECTORY="/usr/local/aosp/master/"

# Gerrit master server
ENV GERRIT_MASTER="gitreplica.eastus.cloudapp.azure.com"
ENV GERRIT_USER="rifujita"
ENV GERRIT_DIR="/media/repo/aosp/mirror"

# Mitigating amount of files to be synced
ENV REPO_GROUP="default,-arm,-mips,-darwin"
ENV REPO_BRANCH="android-7.0.0_r14"

# Avoiding Debian Frontend errors
ENV DEBIAN_FRONTEND noninteractive

# /bin/sh points to Dash by default, reconfigure to use bash until Android build becomes POSIX compliant
RUN \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure -p critical dash

# Installing required packages (Ubuntu 14.04)
# See the section, https://source.android.com/setup/build/initializing#installing-required-packages-ubuntu-1404
RUN apt-get update -y && \
  apt-get upgrade -y
RUN \
  apt-get install -y \
  git-core gnupg flex bison gperf build-essential curl zip zlib1g-dev gcc-multilib g++-multilib \
  libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip python && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Installing the JDK
# See the section, https://source.android.com/setup/build/initializing#installing-the-jdk
RUN \
  curl -L -O "http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre-headless_8u45-b14-1_amd64.deb" \
    -O "http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre_8u45-b14-1_amd64.deb" \
    -O "http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jdk_8u45-b14-1_amd64.deb"
RUN \
  dpkg -i openjdk-8*; exit 0
RUN \
  apt-get -f -y install &&\
  rm -f "openjdk-8*"
ENV \
  JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Installing Repo
# See the section, https://source.android.com/setup/build/downloading#installing-repo
RUN \
  mkdir ~/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && \
  chmod a+x ~/bin/repo
ENV PATH=~/bin:$PATH

# Initializing a Repo client to use a local mirror
# See the section, https://source.android.com/setup/build/downloading#initializing-a-repo-client and
# https://source.android.com/setup/build/downloading#using-a-local-mirror
COPY gitconfig /root/.gitconfig

# Using Authentication
# See the section, https://source.android.com/setup/build/downloading#using-authentication
# THIS WORKAROUND IS AGAINST ABOVE. DIRTY HACK.
RUN \
  mkdir /root/.ssh && \
  chmod 700 /root/.ssh && \
  echo -e "Host *"                            > /root/.ssh/config && \
  echo -e "  User $GERRIT_USER"              >> /root/.ssh/config && \
  echo -e "  IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config && \
  echo -e "  StrictHostKeyChecking no"       >> /root/.ssh/config
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# It's not safe, should be given when it's executed
RUN \
  mkdir -p $WORKING_DIRECTORY && \
  cd $WORKING_DIRECTORY && \
  repo init -u ssh://$GERRIT_MASTER$GERRIT_DIR/platform/manifest.git -g $REPO_GROUP -b $REPO_BRANCH --depth 1
RUN \
  cd $WORKING_DIRECTORY && \
  cpus=$(grep ^processor /proc/cpuinfo | wc -l) && \
  repo sync -j $cpus
RUN \
  rm -f /root/.ssh/id_rsa

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

COPY utils/docker_entrypoint.sh /root/docker_entrypoint.sh
ENTRYPOINT ["/root/docker_entrypoint.sh"]
