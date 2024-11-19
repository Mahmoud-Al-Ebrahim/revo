import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/firebase_options.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/router.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/notifications/local_notification_service.dart';
import 'features/notifications/notification_process.dart';
import 'features/user_profile/controller/user_profile_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

        LocalNotificationService()
            .showNotificationWithPayload(message: message);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationProcess().init();
  NotificationProcess().fcmToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      child: MyApp(
        sharedPreferences:
            sharedPreferences,
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  getData(WidgetRef ref, User? data) async {
    if (data == null) return null;
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    ref
        .read(userProfileControllerProvider
        .notifier)
        .updateUserFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) => FutureBuilder(
              future: getData(ref, data),
              builder: (context, snapShot) {
                if (snapShot.connectionState != ConnectionState.done) {
                  return const Loader();
                }
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Revo Application',
                  theme: ref.watch(themeNotifierProvider),
                  routerDelegate: RoutemasterDelegate(
                    routesBuilder: (context) {
                      print('data  $userModel');
                      if (data != null) {
                        getData(ref, data);
                        print('userModel  $userModel');
                        if (userModel != null) {
                          return loggedInRoute;
                        }
                      }
                      if(widget.sharedPreferences.getBool('user_saw_onBoarding') == null){
                        return loggedOutRouteWithOnBoardingRoute;
                      }
                      return loggedOutRoute;
                    },
                  ),
                  routeInformationParser: const RoutemasterParser(),
                );
              }),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
