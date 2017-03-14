# Fastlane

## Qui suis-je ?

![Sylvek](https://avatars3.githubusercontent.com/u/2259101?v=3&s=460)

- Sylvain Maucourt
- https://github.com/sylvek
- https://twitter.com/sylv3k
- _ancien_ Fastlane commiter
- _ancien_ membre de la communauté Android
- _ancien_ Release Manager Mobile chez Deveryware _(ils recrutent !)_

![Deveryware](https://media.licdn.com/mpr/mpr/shrink_200_200/AAEAAQAAAAAAAAeIAAAAJGM5ZDNlMmY2LTczOGYtNGY5OC1hNzQzLTBhODRmYzBhZTNiZg.png)

## Fastlane

![fastlane](https://fastlane.tools/assets/img/logo-desktop.png)

> fastlane is the tool to release your iOS and Android app 🚀
> It handles all tedious tasks, like generating screenshots, dealing with code signing, and releasing your application.

2014, création de Fastlane par Felix Krause

2015, Fastlane rejoint Twitter _(via Fabric)_

2017, Fastlane rejoint Google _(via Fabric)_

## How to install

```
$> gem install fastlane
```

## Action !

On va builder une application Android jouer les tests et prendre une série de screenshots.

Comme on est super cool, on va aussi la zipper puis la stocker sur un ftp et envoyer une notification Slack.

Et tout ça… sans les mains ou presque.

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
  gradle(task: "assembleDebug assembleAndroidTest")
end
```

```
$> fastlane devoxx
```

### Capturons les écrans!

```
lane :devoxx do
  gradle(task: "assembleDebug assembleAndroidTest")
  screengrab(
    locales: ['fr-FR', 'en-US', 'es-ES', 'de-DE'],
    clear_previous_screenshots: true,
    tests_apk_path: 'app/build/outputs/apk/app-debug.apk'
  )
end
```

```
$> fastlane devoxx
```

### Archivons le binaire !

```
lane :devoxx do
  gradle(task: "assembleDebug assembleAndroidTest")
  screengrab(
    locales: ['fr-FR', 'en-US', 'es-ES', 'de-DE'],
    clear_previous_screenshots: true,
    tests_apk_path: 'app/build/outputs/apk/app-debug.apk'
  )
  zip path: 'fastlane/metadata', output_path: '../metadata.zip'
end
```

```
$> fastlane devoxx
```

### Demandons un mail à l'execution

```
lane :devoxx do |options|
  gradle(task: "assembleDebug assembleAndroidTest")
  screengrab(
    locales: ['fr-FR', 'en-US', 'es-ES', 'de-DE'],
    clear_previous_screenshots: true,
    tests_apk_path: 'app/build/outputs/apk/app-debug.apk'
  )
  zip path: 'fastlane/metadata', output_path: '../metadata.zip'
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
  gradle(task: "assembleDebug assembleAndroidTest")
  screengrab(
    locales: ['fr-FR', 'en-US', 'es-ES', 'de-DE'],
    clear_previous_screenshots: true,
    tests_apk_path: 'app/build/outputs/apk/app-debug.apk'
  )
  zip path: 'fastlane/metadata', output_path: '../metadata.zip'
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
  gradle(task: "assembleDebug assembleAndroidTest")
  screengrab(
    locales: ['fr-FR', 'en-US', 'es-ES', 'de-DE'],
    clear_previous_screenshots: true,
    tests_apk_path: 'app/build/outputs/apk/app-debug.apk'
  )
  zip path: 'fastlane/metadata', output_path: '../metadata.zip'
  options[:email] = prompt text: "email destinataire:" unless options.key?(:email)
  puts "dépot sur un ftp, #{options[:email]} sera prévenu"
  upload_free_ftp binary: 'metadata.zip'
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
