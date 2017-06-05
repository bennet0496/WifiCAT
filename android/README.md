# Android App for Wifi Configuration
![screenshot](screenshot.png "App Screenshot")
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
