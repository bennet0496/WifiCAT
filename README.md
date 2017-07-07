# Wifi C.A.T.

The Wifi Configuration Assist Tool (short C.A.T.) automatically configures an WPA2 Enterprise Wifi-network on a user's device.

The tool is available for Windows (Vista and above), Linux (NetworkManager and WPA Supplicant), Android (4.3 and above), macOS and iOS (also if technically speak it is more an Configuration Generator than a Configuration Assistant for the last both).

Currently for Android it is possible to configure constraints for Devices so that they have to fulfill certain requirements. So you can configure that Devices shall not be Rooted, are Password/PIN/Pattern Protected or are from a Manufacturer in a configurable List. It is planned to extend this to Windows and Linux too.



You are welcome to file Bugs on the Projects Issues Page. For known Bug please have a look on the Issues Page

## Features

- Install WPA/WPA2 Enterprise Networks with Username/Password or User Certificate.
  - Supported EAP Method are PEAP, TLS and TTLS
  - Supported Phase 2 Methods GTC, MSCHAP, MSCHAPv2, PAP
- Delete an SSID (to delete the Network from which the App is downloading, because this is probably an unsecured one)
- Check for Device Root Status, Lock State and Manufacturer on Android
- Optionally Force the User to enter the Data manually (Disallow Paste) on Windows
- Digitally sign the Applications

### Planned Features

- [ ] Check whether System is Up-to-Date
- [ ] Check for full Device Encryption
- [ ] Check for Password on Windows

Feel free to create an Feature Request on the Issues Page

## Structure

This Project contains the Android App, the Windows Application, the Linux Script, an Configuration Skeleton for Apple OSes, the Webpage Skeleton for Distributing and an Building tool to configure and build the before named with ease.

Please have a look in each individual Folder for the corresponding Tool for further documentation.

## License

All Source Code is published under [GNU Affero General Public License v3.0](LICENSE). Pictures are published under [Creative Commons Attribution-NoDerivatives 4.0 International](http://creativecommons.org/licenses/by-nd/4.0/)

![license](https://i.creativecommons.org/l/by-nd/4.0/88x31.png)

> Copyright (C) 2017 Bennet Becker <bennet@becker-dd.de>
>
> This program is free software: you can redistribute it and/or modify 
> it under the terms of the GNU Affero General Public License as published by 
> the Free Software Foundation, either version 3 of the License, or 
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful, 
> but WITHOUT ANY WARRANTY; without even the implied warranty of 
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
> GNU Affero General Public License for more details.
>
> You should have received a copy of the GNU Affero General Public License 
> along with this program. If not, see <http://www.gnu.org/licenses/>.

### External Work

These files are provided by 3rd-parties and licensed differently as the source code mentioned above

  - `webpage/src/jquery.min.js` from JQuery is provided by the JS Foundation under MIT License
  - `webpage/src/material{,.min}.{js,css,map}` from Material Design Lite is provided by Google under an Apache-2 license
  - `webpage/src/jsclient.js` by Christian Ludwig (https://stackoverflow.com/questions/9514179/how-to-find-the-operating-system-version-using-javascript/18706818#18706818)
  - The Windows Tool uses the [Managed Wifi API](https://managedwifi.codeplex.com/) by [ikonst](https://www.codeplex.com/site/users/view/ikonst)

### Programs Used

- [Android Studio](https://developer.android.com/studio/index.html) by Google
- [PhpStorm](https://www.jetbrains.com/phpstorm/) by JetBrains
- [PyCharm](https://www.jetbrains.com/pycharm/) by JetBrains
- [Visual Studio Community](https://www.visualstudio.com/vs/) by Microsoft with [ReSharper](https://www.jetbrains.com/resharper/) by JetBrains
- [Typora](https://typora.io/)

