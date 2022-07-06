FROM debian

RUN apt-get update && apt-get install -y sqlite3 cron

RUN apt-get update -q && \
    apt-get install -qy procps curl ca-certificates gnupg2 build-essential --no-install-recommends && apt-get clean

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.6"
ENV PATH="/usr/local/rvm/gems/ruby-2.6.6/bin/:${PATH}"
ENV PATH="/usr/local/rvm/gems/ruby-2.6.6@global/bin/:${PATH}"
ENV PATH="/usr/local/rvm/rubies/ruby-2.6.6/bin/:${PATH}"
ENV PATH="/usr/local/rvm/bin/:${PATH}"

ENV NODE_VERSION=16.15.1
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN npm install yarn --location=global

WORKDIR /app

COPY . .

RUN bundle install

EXPOSE 3000
