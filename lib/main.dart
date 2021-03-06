import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/core/models/settings.dart';
import 'package:flutter_firebase_template/core/models/setup_data.dart';
import 'package:flutter_firebase_template/core/models/user.dart';
import 'package:flutter_firebase_template/core/services/authentication_service.dart';
import 'package:flutter_firebase_template/core/services/setting_keys.dart';
import 'package:flutter_firebase_template/core/services/settings_service.dart';
import 'package:flutter_firebase_template/locator.dart';
import 'package:flutter_firebase_template/ui/app_localizations.dart';
import 'package:flutter_firebase_template/ui/navigation_service.dart';
import 'package:flutter_firebase_template/ui/router.dart';
import 'package:flutter_firebase_template/ui/theme_service.dart';
import 'package:flutter_firebase_template/ui/views/loading_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SetupData>(
      future: Future.wait([
        locator<AuthenticationService>().getCurrentUser(),
        locator<SettingsService>().getSettingsFromLocalStorage()
      ]).then(
        (response) => SetupData(user: response[0], settings: response[1]),
      ),
      builder: (context, AsyncSnapshot<SetupData> snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.done):
            return MultiProvider(
              providers: [
                StreamProvider<User>(
                  builder: (_) => locator<AuthenticationService>().userStream,
                  initialData: snapshot.data.user,
                ),
                ChangeNotifierProvider<Settings>(
                  builder: (_) => snapshot.data.settings,
                ),
              ],
              child: MultiProvider(
                providers: [
                  ProxyProvider<Settings, ThemeData>(
                      builder: (context, settings, _) => locator<ThemeService>()
                          .getThemeData(
                              settings.getSettingValue(SettingKeys.theme))),
                  ProxyProvider<Settings, Locale>(
                    builder: (context, settings, _) =>
                        Locale(settings.getSettingValue(SettingKeys.locale)),
                  ),
                ],
                child: Consumer<ThemeData>(
                  builder: (context, theme, _) => Consumer<Locale>(
                    builder: (context, locale, _) => MaterialApp(
                      onGenerateTitle: (BuildContext context) =>
                          AppLocalizations.of(context).title,
                      theme: theme,
                      initialRoute: snapshot.data.user != null
                          ? Router.home
                          : Router.login,
                      navigatorKey: locator<NavigationService>().navigatorKey,
                      onGenerateRoute: Router.generateRoute,
                      locale: locale,
                      localizationsDelegates: [
                        const AppLocalizationsDelegate(),
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: [
                        const Locale('en'),
                        const Locale('de'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          default:
            return LoadingView();
        }
      },
    );
  }
}
