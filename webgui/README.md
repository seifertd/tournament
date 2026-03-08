# Tournament Webgui

This documents how to run the legacy Rails 2.3.11 app (Ruby 1.9.3) on a modern Linux system using Docker.

## Prerequisites

Install Docker (on CachyOS/Arch, doing this on other distros is out-of-scope for this document):

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker.socket
sudo usermod -aG docker $USER
newgrp docker
```

Verify Docker is working:

```bash
docker run hello-world
```

## Project Files

### Gemfile

Create a `Gemfile` in the root of your Rails app (Rails 2.3.11 predates Bundler, so this needs to be added manually):

```ruby
source 'https://rubygems.org'

gem 'rails', '2.3.11'
gem 'sqlite3', '1.4.4'
gem 'tournament' 
```

### Dockerfile

```dockerfile
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

# Build OpenSSL 1.0.2 from source (required for Ruby 1.9.3 — incompatible with OpenSSL 3.x)
RUN wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz && \
    tar xzf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config --prefix=/usr/local/openssl-1.0.2 --openssldir=/etc/ssl shared && \
    make && make install && \
    cd .. && rm -rf openssl-1.0.2u*

# Build Ruby 1.9.3 from source
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
```

**Why so much from source?**
- Modern Debian ships OpenSSL 3.x, which Ruby 1.9.3 cannot build against — OpenSSL 1.0.2u must be compiled separately.
- Ruby 1.9.3 packages are no longer available in any current distro repos.

### docker-compose.yml

```yaml
services:
  web:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
```

The volume mount means local file edits are reflected immediately without rebuilding.

## Building and Running

Build the image (takes a few minutes the first time due to compiling OpenSSL and Ruby):

```bash
docker compose build
```

Start the app:

```bash
docker compose up
```

The app will be available at http://localhost:3000.

Stop the app:

```bash
docker compose down
```

## Useful Commands

Run the Rails console:

```bash
docker compose exec web bundle exec ruby script/console
```

Run a one-off command:

```bash
docker compose exec web bundle exec rake db:migrate
```

Open a shell in the container:

```bash
docker compose exec web bash
```

## Notes

- The build will emit many deprecation warnings about `Gem.source_index` — these are harmless, just Rails 2.x running on a newer RubyGems than it was designed for.
- The first `docker compose build` is slow; subsequent builds are fast unless you change the `Gemfile`.
