import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orario_scuola/components/scaffold.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orario_scuola/util/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class TOS extends StatefulWidget {
  const TOS({Key? key}) : super(key: key);

  @override
  State<TOS> createState() => _TOS();
}

class _TOS extends State<TOS> {
  final String tos = AppLocalizations.instance.text("tos.tos");

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: ["email"]
    ).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context2) {
    ThemeData theme = Theme.of(context2);
    return ScaffoldComponent(
      showSettings: false,
      title: AppLocalizations.instance.text("appbar.title.tos"),
      child: Container(
        margin: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.instance.text("tos.welcome"),
                            style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                            text: "\n" + AppLocalizations.instance.text("tos.name"),
                            style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xFFE9B03E))
                          )
                        ]
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/svg/icons8-school.svg",
                    semanticsLabel: "Undraw Login",
                    width: MediaQuery.of(context2).size.width,
                  ),
                  Column(
                    children: <Widget>[
                      InkWell(
                        onTap: signInWithGoogle,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 0.2, blurRadius: 5, offset: Offset.fromDirection(315, 4))
                            ]
                          ),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SvgPicture.asset("assets/svg/google.svg"), // <-- Use 'Image.asset(...)' here
                              SizedBox(width: 12),
                              Text('Login con Google', style: theme.textTheme.subtitle2?.copyWith(color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: tos.substring(0, tos.indexOf("{%}")),
                              style: theme.textTheme.subtitle2!
                            ),
                            TextSpan(
                              text: tos.substring(tos.indexOf("{%}")+3, tos.lastIndexOf("{%}")),
                              style: theme.textTheme.subtitle2!.copyWith(decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunch("https://www.termsandconditionsgenerator.com/live.php?token=huchWUopclp87QWoBkKmCuuUUDrl3nqh")) await launch("https://www.termsandconditionsgenerator.com/live.php?token=huchWUopclp87QWoBkKmCuuUUDrl3nqh");
                              }
                            ),
                            TextSpan(
                              text: tos.substring(tos.lastIndexOf("{%}")+3, tos.indexOf("{\$}")),
                              style: theme.textTheme.subtitle2!
                            ),
                            TextSpan(
                              text: tos.substring(tos.indexOf("{\$}")+3, tos.lastIndexOf("{\$}")),
                              style: theme.textTheme.subtitle2!.copyWith(decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunch("https://www.privacypolicygenerator.info/live.php?token=atqi08asBRdTR9HSmKIbl94xBVbN4Emz")) await launch("https://www.privacypolicygenerator.info/live.php?token=atqi08asBRdTR9HSmKIbl94xBVbN4Emz");
                              }
                            ),
                            TextSpan(
                              text: tos.substring(tos.lastIndexOf("{\$}")+3),
                              style: theme.textTheme.subtitle2!
                            )
                          ]
                        )
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
