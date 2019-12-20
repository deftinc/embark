#!/usr/bin/env bash

embark_version() {
  echo "0.1.0"
}

embark_describe() {
  echo "===> $1…"
}

embark_squelch() {
  $@ > /dev/null 2>&1
}

embark_install_brew_dependencies() {
  if [ -f "Brewfile" ] && [ "$(uname -s)" = "Darwin" ]; then
    squelch brew bundle check || {
      describe "Installing Homebrew dependencies"
      brew bundle
    }
  fi
}

embark_configure_asdf_for_bash() {
  squelch grep -Fq 'asdf' $HOME/.bash_profile || {
    describe "Configuring asdf for bash"
    echo "# Setup for asdf" >> $HOME/.bash_profile
    echo ". $(brew --prefix asdf)/asdf.sh" >> $HOME/.bash_profile
    echo ". $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> $HOME/.bash_profile
    . $(brew --prefix asdf)/asdf.sh
  }
}

embark_add_asdf_ruby_plugin() {
  if [ -z "$(asdf plugin-list | grep ruby || true)" ]; then
    describe "Installing asdf ruby plugin"
    asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  fi
}

embark_add_asdf_node_plugin() {
  if [ -z "$(asdf plugin-list | grep nodejs || true)" ]; then
    describe "Installing asdf nodejs plugin"
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
  fi
}

embark_update_asdf_plugins() {
  describe "Updating asdf language plugins"
  asdf plugin-update --all
}

embark_asdf_install_tools() {
  if [ -f .tool-versions ]; then
    need_to_install=0

    desired_node=$(grep nodejs .tool-versions | sed 's/^nodejs \(.*\)$/\1/')
    actual_node=$(node -v | cut -d 'v' -f 2)
    [ ! -z "$desired_node" ] && [ "$actual_node" != "$desired_node" ] && need_to_install=1

    desired_ruby=$(grep ruby .tool-versions | sed 's/^ruby \(.*\)$/\1/')
    actual_ruby=$(sed 's/^ruby \(.*\)p.*$/\1/' <<< $(ruby -v))
    [ ! -z "$desired_ruby" ] && [ "$actual_ruby" != "$desired_ruby" ] && need_to_install=1

    if ((need_to_install)); then
      describe "Installing .tools-versions languages"
      asdf install
    fi
  fi
}

embark_install_yarn_version_from_package_json() {
  if [ -f packag.json ]; then
    yarn_version=$(cat package.json | jq -er '.engines.yarn')
    if [ "$(yarn --version)" != "$yarn_version" ]; then
      describe "Installing yarn version from package.json"
      npm install -g yarn@${yarn_version}
    fi
  fi
}

embark_install_bundler_version() {
  if [ -f Gemfile.lock ]; then
    desired_bunder=$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -n 1 | awk '{$1=$1};1')
    actual_bundler=$(bundler --version| sed 's/^Bundler version \(.*\)$/\1/')
    if [ ! -z "$desired_bunder" ] && [ "$actual_bundler" != "$desired_bunder" ]; then
      describe "Installing bundler version from Gemfile.lock"
      [ ! -z "$actual_bundler" ] && {
        gem uninstall bundler -v ${actual_bundler}
      }
      gem install bundler -v ${desired_bunder}
    fi
  fi
}

embark_install_gems() {
  if [ -f Gemfile ]; then
    squelch bundle check || {
      describe "Installing gem dependencies"
      ./bin/bundle install
    }
  fi
}

embark_install_node_packages_with_yarn() {
  if [ -f yarn.lock ]; then
    squelch yarn check --verify-tree || {
      describe "Installing npm library dependencies"
      yarn install
    }
  fi
}

embark_run_rails_migrations() {
  if [ -f ./bin/rails ]; then
    PENDING_MIGRATIONS=$(./bin/rails db:migrate:status | grep down || true)
    if [[ -n "$PENDING_MIGRATIONS" ]]; then
      describe "Running database migrations"
      ./bin/rails db:migrate
    fi
  fi
}

embark_seed_rails_database() {
  if [ -f ./bin/rails ]; then
    describe "Seeding database"
    ./bin/rails db:seed
  fi
}

embark_use_development_log() {
  touch ./log/development.log
}

embark_use_pids() {
  mkdir -p ./tmp/pids/
}

embark_services_up() {
  if [ -f docker-compose.yml ]; then
    docker-compose up > ./log/development.log 2>&1 &
    echo $! > ./tmp/pids/docker-compose.pid
  fi
}

embark_services_down() {
  if [ -f docker-compose.yml ]; then
    docker-compose down && rm ./tmp/pids/docker-compose.pid || pkill -F ./tmp/pids/docker-compose.pid
  fi
}

embark_rails_server() {
  if [ -f ./bin/rails ]; then
    ./bin/rails server > ./log/development.log 2>&1 &
    echo $! > ./tmp/pids/rails-server.pid
  fi
}

embark_cleanup() {
  echo "Cleaning up..."
  [ -f docker-compose.yml ] && docker-compose down
  [ -f ./tmp/pids/rails-server.pid ] && pkill -F ./tmp/pids/rails-server.pid
  [ -f ./tmp/pids/docker-compose.pid ] && pkill -F ./tmp/pids/docker-compose.pid
}
