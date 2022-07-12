# LOBSTA Client

LOBSTA is a new kind of task manager that helps you manage all kinds of location-based tasks collaboratively and more efficient.

## Getting Started

LOBSTA Client is build with Flutter. For help getting started with Flutter, view [online documentation](https://flutter.dev/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

* [Install Flutter](https://docs.flutter.dev/get-started/install) 
* Install Android Studio, start the program and follow the setup wizard
* Check your environment and resolve eventual issues:

```sh
flutter doctor
```

* Agree to Android licenses if needed

```sh
flutter doctor --android-licenses
```

### Installation on Linux through `snap`

```sh
sudo snap install flutter --classic
sudo snap install android-studio --classic
```

## How to Develop

TBD

### Run the app

Check available device:

```sh
flutter devices
```

Run the app:

```sh
flutter run
```

### Build for Android

Create file name ```android/key.properties``` that contains the reference to keystore:

```
storePassword=<store password>
keyPassword=<key password>
keyAlias=<key alias>
storeFile=<keystore location of the key store file, such as /Users/<user name>/upload-keystore.jks>
```

Follow [here](https://docs.flutter.dev/deployment/android#configure-signing-in-gradle) to configure signing in gradle.

Need to run ```flutter clean ``` after changing the gradle:

Building an APK:

```sh
flutter build apk
```

Building an App Bundle:

```sh
flutter build appbundle
```

### Build for iOS

1. In Xcode, open ```Runner.xcworkspace``` in your app’s ```ios``` folder
2. Select ```Product > Archive```
3. Click the ```Validate App``` button
4. Click ```Distribute App``` and follow details on [App Store Connect](https://appstoreconnect.apple.com/)

## Contributing and Support

The project appreciates any [contributions](https://github.com/georepublic/.github/blob/main/CONTRIBUTING.md)! Feel free to contact us for [reporting problems and support](https://github.com/Georepublic/lobsta_client/issues).

## Version History

See [all releases](https://github.com/georepublic/lobsta_client/releases) with release notes.

## LICENSE

This program is free software. See [LICENSE](LICENSE) for more information.
