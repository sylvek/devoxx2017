# Fastlane

## Présentation

> fastlane is the tool to release your iOS and Android app 🚀
> It handles all tedious tasks, like generating screenshots, dealing with code signing, and releasing your application.

2014, création de Fastlane par Felix Krause

2015, Fastlane rejoint Twitter _(via Fabric)_

2017, Fastlane rejoint Google _(via Fabric)_

## How to install

```
$> brew install rbenv / apt-get install rbenv ruby-build
$> rbenv init
$> rbenv install -s
$> export PATH="~/.rbenv/shims:${PATH}"
$> gem install bundler
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
```

Let's play with Fastlane! :)

## Course

```
$> fastlane init
```

créé un répertoire fastlane _(dans hello)_ contenant

- un répertoire actions vide
- Appfile
- Fastfile

### Concentrons nous sur Fastfile.

Fastfile est composé de lanes.

Une lane est une série d'actions.

Certaines actions sont incluses dans Fastlane.

{info}Il est possible d'en ajouter unitairement via les plugins et/ou via l'écriture
d'action custom présents dans le répertoire "actions".{info}

Les lanes sont appelées directement en ligne de commande.

```
$> fastlane test
```

### Créons notre propre lane

```
lane :devoxx do
end
```

```
$> fastlane devoxx
```

### Compilons le projet hello

```
lane :devoxx do
  gradle task: "build"
end
```

```
$> fastlane devoxx
```

### Executons le programme

```
lane :devoxx do
  gradle task: "build"
  sh 'java -jar ../build/libs/hello.jar'
end
```

```
$> fastlane devoxx
```

### Archivons le binaire !

```
lane :devoxx do
  gradle task: "build"
  sh 'java -jar ../build/libs/hello.jar'
  zip path: 'build/libs', output_path: '../hello.zip'
end
```

```
$> fastlane devoxx
```

### Demandons un mail à l'execution

```
lane :devoxx do
  gradle task: "build"
  sh 'java -jar ../build/libs/hello.jar'
  zip path: 'build/libs', output_path: '../hello.zip'
  email = prompt text: "email destinataire:"
  puts "dépot sur un ftp, #{email} sera prévenu"
end
```

```
$> fastlane devoxx
```

### Passons le mail dans la ligne de commande

```
lane :devoxx do |options|
  gradle task: "build"
  sh 'java -jar ../build/libs/hello.jar'
  zip path: 'build/libs', output_path: '../hello.zip'
  options[:email] = prompt text: "email destinataire:" unless options.key?(:email)
  puts "dépot sur un ftp, #{options[:email]} sera prévenu"
end
```

```
$> fastlane devoxx email:"smaucourt@gmail.com"
```

### before_all, after_all et error

Trois lanes interviennent dans le cycle de vie de fastlane.

- before_all
- after_all
- error


before_all permet de jouer des actions avant un lane, _ex: jouer cocoapods_

after_all est executé si la lane s'est executé sans erreur.

erreur dans le cas contraire.

Notifions que tout s'est bien passé:

```
after_all do |lane, options|
  # This block is called, only if the executed lane was successful

  UI.success  "bravo #{options[:email]} !"
end
```

Notifions via Slack:

```
after_all do |lane, options|
  # This block is called, only if the executed lane was successful

  slack(
     slack_url: "https://hooks.slack.com/services/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",
     message: "Successfully deployed new App for #{options[:email]} :)"
  )
  UI.success  "bravo #{options[:email]} !"
end
```

### Créons notre propre action permettant d'uploader sur un ftp

```
$> fastlane new_action
$> # nom de l'action: upload_free_ftp
$> # le répertoire actions contient un fichier upload_free_ftp.rb
```

mettre à jour notre action:

```
lane :devoxx do |options|
  gradle task: "build"
  sh 'java -jar ../build/libs/hello.jar'
  zip path: 'build/libs', output_path: '../hello.zip'
  options[:email] = prompt text: "email destinataire:" unless options.key?(:email)
  puts "dépot sur un ftp, #{options[:email]} sera prévenu"
  upload_free_ftp binary: 'hello.zip'
end
```

Une action contient plusieurs fonctions:

| fonction | description |
|----------|-------------|
|self.run(params)|fonction mère, contenant le coeur de l'action|
|self.available_options|permet de lister les options disponibles dans l'action|
|self.is_supported?(platform)|permet d'indiquer si l'action est compatible avec Android/iOS|

```
def self.run(params)
  random = ""; 8.times{random << (65 + rand(25)).chr}
  UI.message "we upload #{params[:binary]}"
  ftp = Net::FTP.new('ec2-54-93-156-69.eu-central-1.compute.amazonaws.com')
  ftp.login 'bob', 'devoxx'
  ftp.putbinaryfile params[:binary], "#{random}.jar"
  ftp.close
  UI.message "done"
end

def self.available_options
  [
    FastlaneCore::ConfigItem.new(key: :binary,
                                 env_name: "FL_UPLOAD_FREE_FTP_BINARY",
                                 description: "binary file to upload",
                                 is_string: true)
  ]
end
```

```
$> fastlane devoxx email:"smaucourt@gmail.com"
```
