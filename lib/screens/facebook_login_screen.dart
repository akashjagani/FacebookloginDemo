import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class FacebookLoginScreen extends StatefulWidget {
  @override
  _FacebookLoginScreenState createState() => _FacebookLoginScreenState();
}

class _FacebookLoginScreenState extends State<FacebookLoginScreen> {
  bool isLoggedIn = false;
  Map userProfile;
  final facebookLogin = FacebookLogin();

  _login() async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        // final FacebookAccessToken accessToken = result.accessToken;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}'));
        var profile = jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          isLoggedIn = true;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(
          () => isLoggedIn = false,
        );
        break;
      case FacebookLoginStatus.error:
        setState(
          () => isLoggedIn = false,
        );
        break;
    }
  }

  _logout() {
    facebookLogin.logOut();
    setState(
      () => isLoggedIn = false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    userProfile['picture']['data']['url'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  Text(userProfile['name']),
                  OutlinedButton(
                    onPressed: () {
                      _logout();
                    },
                    child: Text('Logout'),
                  ),
                ],
              )
            : OutlinedButton(
                onPressed: () {
                  _login();
                },
                child: Text('Login With Facebook'),
              ),
      ),
    );
  }
}
