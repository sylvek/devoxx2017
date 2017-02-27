# Tool in action, Fastlane

## How to install

```
$> brew install rbenv / apt-get install rbenv ruby-build
$> rbenv init
$> rbenv install -s
$> export PATH="~/.rbenv/shims:${PATH}"
$> gem install blunder
$> rbenv rehash
$> bundle
$> rbenv rehash
$> fastlane --version
```

or...
```
$> ./install-fastlane.sh
$> # you have to use bash, zsh seems to not work.
$> fastlane --version
```

or...
```
$> gem install fastlane
```

## How to use

```
$> cd hello
$> fastlane init
$> fastlane new_action
```

Let's play with Fastlane! :)
