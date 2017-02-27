#!/bin/bash
#brew install rbenv / apt-get install rbenv ruby-build
rbenv init
rbenv install -s
export PATH="~/.rbenv/shims:${PATH}"
gem install blunder
rbenv rehash
bundle
rbenv rehash
fastlane --version
