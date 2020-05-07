# Applozic flutter chat plugin
A flutter wraper for Applozic native android and iOS SDKs.

## Getting Started
[Sign up](https://console.applozic.com/login) for Applozic to get your application Id. This application Id is used to login user to applozic.

## Prerequisites
Apps using Applozic can target Xcode 11 or later and AndroidX is required.

## Installation
1) Add the below dependency in your pubspec.yaml file:
```yaml
 dependencies:
  # other dependencies
 applozic_flutter: ^0.0.1
```

2) Install the package as below:
```
  flutter pub get
```

3) For iOS, navigate to your App/iOS directory from terminal and run the below command:
```
pod install
```

> Note: Applozic iOS requires min iOS platform version 10 and uses dynamic frameworks. Make sure you have the below settings at the top of your iOS/Podfile:
```ruby
platform :ios, '10.0'
use_frameworks!
```

4) Import the applozic_flutter in your .dart file to use the methods from Applozic:
```dart
import 'package:applozic_flutter/applozic_flutter.dart';
```

## Authentication
Create Applozic user and pass user to login() function as below:
```dart
dynamic user = {
      'applicationId': "<APPLICATION_ID>",   //Mandatory
      'userId': userId.text,                 //Mandatory
      'displayName': displayName.text,
      'password': password.text,
      'authenticationTypeId': 1              //Mandatory
  };

ApplozicFlutter.login(user).then((response) {
      print("Login success : " + response)
    }).catchError((error, stack) =>
      print("Error while logging in : " + error.toString()));
```

> Note: Please remember you have to log in once and only after you log out you must log in again. Use below code to check if   the user is already logged in:

```dart
ApplozicFlutter.isLoggedIn().then((isLoggedIn) {
       print("Logged in : " + value.toString());
        if (isLoggedIn) {
          //The user is logged in
         } esle {
          //The user is not logged in
         }
     });
```

## Conversation
### Launch main chat screen
Launch the main chat screen as below:
```dart
  ApplozicFlutter.launchChat();
```

### Launch Chat with a specific User
Launch the conversation with a user by passing the userId as below:
```dart
  ApplozicFlutter.launchChatWithUser("<USER_ID>");
```

### Launch Chat with a specific Group
Launch the conversation with a group by passing the groupId as below:
```dart
  ApplozicFlutter.launchChatWithGroupId(<GROUP_ID>)
                        .then((value) =>
                            print("Launched successfully : " + value))
                        .catchError((error, stack) {
                      print("Unable to launch group : " + error.toString());
                    });
```

## Group

