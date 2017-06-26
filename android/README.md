# Android App for Wifi Configuration
![screenshot](screenshot_500.png "App Screenshot")
This is the Android Appp for the Wifi C.A.T.

The App is intendet to be installed from an Website, which is an "untrusted source" in Andorid. It is not recommended to publish this version of the App via Play Store.

 The requests to uninstall itself afer successfull configuration.
## Build the App
Create an Java Keystore and Key
```
keytool -genkey -alias signing -keyalg RSA -keystore app/wificat.keystore -keysize 2048
```
And insert the Keystore password in `app/build.gradle`

Now Build the App using `gradlew`
```
./gradlew assemble
```

## TODO
  - [ ] optimize the app for play store
    - [ ] make the configuration updateable -> request the user to update the network settings
## License
the source code is licenced under AGPL v3.0

### External Work
the project uses RootBeer, by scottyab licensed under an Apache-2 license, as an external build
dependency.
