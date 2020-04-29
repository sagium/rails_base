FROM debian:unstable-slim

ARG USER_UID
ARG USER_GID
ARG NODE_VERSION
ARG RUBY_VERSION

ENV RUBY_VERSION $RUBY_VERSION
ENV NODE_VERSION $NODE_VERSION

RUN echo 'LC_ALL="en_US.UTF-8"' > /etc/default/locale; \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections; \
    apt update && apt install -y \
                      sudo \
                      curl \
                      procps \
                      libpq-dev && rm -rf /var/lib/apt/lists/* && apt autoclean

RUN groupadd -g $USER_GID user; \
    useradd --shell "/bin/bash" -u $USER_UID -g $USER_GID -m user; \
    echo "user ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    echo -e "\nexport PATH=\$PATH:$HOME/app/bin\n" >> ~/.bashrc

USER user

SHELL [ "/bin/bash", "-l", "-c" ]

# Installing NVM
RUN curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh -o tmp/install_nvm.sh; \
    touch ~/.profile; \
    bash tmp/install_nvm.sh && rm tmp/install_nvm.sh; \
    . ~/.nvm/nvm.sh && . ~/.nvm/bash_completion && nvm install v$NODE_VERSION && npm install -g yarn; \
    rm -rf ~/.nvm/.cache

# Installing RVM
RUN curl -sSL get.rvm.io | bash; \
    source ~/.rvm/scripts/rvm; \
    rvm install $RUBY_VERSION; \
    echo 'install: --no-document' > ~/.gemrc; \
    echo 'update: --no-document' > ~/.gemrc; \
    gem install bundler; \
    echo -e '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" \n\n' >> ~/.bashrc; \
    rvm cleanup all; \
    sudo rm -rf /var/lib/apt/lists/* && sudo apt autoclean

WORKDIR /home/user/app

# Port 3035 is used by the debugger on Rubymine
EXPOSE 3000 3035
