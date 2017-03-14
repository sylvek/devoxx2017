#!/bin/bash
#brew install rbenv / apt-get install rbenv ruby-build
rbenv install -s
rbenv init
export PATH=~/.rbenv/shims:${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
gem install bundler
rbenv rehash
bundle
rbenv rehash
fastlane --version
