FROM debian:stable
MAINTAINER "gustav@rnld.se"
# PRIVIOUS MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

# ------------------------------------------------------------------------------
# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential git pylint virtualenv python3-dev python3-pip openssh-server \
    curl python3-setuptools gnupg zsh \
 && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
 && apt-get install -y --no-install-recommends nodejs \
 && ln -s /usr/bin/nodejs /usr/bin/node \
 && curl -sL https://deb.nodesource.com/setup | bash - \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && pip3 install chaperone \
 && mkdir /etc/chaperone.d /cloud9 /var/run/sshd

# ------------------------------------------------------------------------------
# Get cloud9 source and install
WORKDIR /cloud9
RUN git clone https://github.com/c9/core.git . \
 && scripts/install-sdk.sh \
 && sed -i -e 's_127.0.0.1_0.0.0.0_g' configs/standalone.js \
 && sed -i -e 's_message: "-d all -e E -e F",_message: "-d all -e E,F,W",_g' plugins/c9.ide.language.python/python.js \
 && mkdir workspace

# ------------------------------------------------------------------------------
# Add workspace volumes
VOLUME /cloud9/workspace

# ------------------------------------------------------------------------------
# Set default workspace dir
ENV C9_WORKSPACE /cloud9/workspace
#ENV AUTHORIZED_KEYS **None**

# ------------------------------------------------------------------------------
# Configuration
COPY conf/chaperone.conf /etc/chaperone.d/chaperone.conf
ADD sshd.sh /sshd.sh

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8080 22 5000 8888 8889 8890

# ------------------------------------------------------------------------------
# Start
ENTRYPOINT ["/usr/local/bin/chaperone"]
