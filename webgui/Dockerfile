FROM debian:bookworm-slim

RUN apt-get update && \
    dpkg --configure -a && \
    apt-get install -y --fix-broken \
    build-essential \
    wget \
    libreadline-dev \
    zlib1g-dev \
    libsqlite3-dev \
    sqlite3 \
    libyaml-dev \
    libgdbm-dev \
    libffi-dev \
    ca-certificates

# Build OpenSSL 1.0.2 from source
RUN wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz && \
    tar xzf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config --prefix=/usr/local/openssl-1.0.2 --openssldir=/etc/ssl shared && \
    make && make install && \
    cd .. && rm -rf openssl-1.0.2u*

RUN wget https://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p551.tar.gz && \
    tar xzf ruby-1.9.3-p551.tar.gz && \
    cd ruby-1.9.3-p551 && \
    ./configure --with-openssl-dir=/usr/local/openssl-1.0.2 --with-yaml-dir=/usr --disable-install-rdoc && \
    make && \
    make install && \
    cd .. && rm -rf ruby-1.9.3-p551*

RUN gem install bundler -v 1.17.3

WORKDIR /app
COPY Gemfile .
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "ruby", "/app/script/server", "-b", "0.0.0.0"]
