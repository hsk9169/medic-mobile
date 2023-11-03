import 'dart:io';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/screens/signup/user/customer_signup_view.dart';
import 'package:medic_app/screens/signup/medic/search_hospital_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/screens/screens.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/services/encrypted_storage_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final dynamic camera;
  MyApp({required this.camera, Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
        name: 'intro',
        path: '/',
        builder: (context, state) => IntroView(),
        routes: [
          GoRoute(
            name: 'signin',
            path: 'signin',
            builder: (context, state) {
              int data = state.extra as int;
              return SigninView(userDiv: data);
            },
          ),
          GoRoute(
            name: 'signup',
            path: 'signup',
            builder: (context, state) => SignupView(),
          ),
          GoRoute(
              name: 'selMethod',
              path: 'selMethod',
              builder: (context, state) {
                int data = state.extra as int;
                return SelMethodView(userDiv: data);
              }),
          GoRoute(
              name: 'customerSignup',
              path: 'customerSignup',
              builder: (context, state) => CustomerSignupView(
                  username: state.queryParameters['username'] ?? '',
                  birthDate: state.queryParameters['birthDate'] ?? '',
                  phone: state.queryParameters['phone'] ?? '')),
          GoRoute(
              name: 'medicSignup',
              path: 'medicSignup',
              builder: (context, state) => MedicSignupView(
                  username: state.queryParameters['username'] ?? '',
                  birthDate: state.queryParameters['birthDate'] ?? '',
                  phone: state.queryParameters['phone'] ?? '')),
          GoRoute(
            name: 'searchAddress',
            path: 'searchAddress',
            builder: (context, state) => SearchAddressView(),
          ),
          GoRoute(
            name: 'searchHospital',
            path: 'searchHospital',
            builder: (context, state) => SearchHospitalView(),
          ),
          GoRoute(
            name: 'addAuthImage',
            path: 'addAuthImage',
            builder: (context, state) => AddAuthImageView(),
          ),
        ]),
    GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => HomeView(),
        routes: [
          GoRoute(
            name: 'registerPatient',
            path: 'registerPatient',
            builder: (context, state) {
              String data = state.extra as String;
              return RegisterView(codeNum: data);
            },
          ),
          GoRoute(
              name: 'takePicture',
              path: 'takePicture',
              builder: (context, state) {
                PatientDataRes data = state.extra as PatientDataRes;
                return CameraView(patientData: data);
              }),
          GoRoute(
              name: 'patientPage',
              path: 'patientPage',
              builder: (context, state) {
                PatientDataRes data = state.extra as PatientDataRes;
                return PatientMainView(patientData: data);
              }),
          GoRoute(
              path: 'feedPage',
              name: 'feedPage',
              builder: (context, state) {
                final extra = state.extra! as Map<String, dynamic>;
                PatientDataRes patientData =
                    extra['patientData'] as PatientDataRes;
                FeedData feedData = extra['feedData'] as FeedData;
                return PatientFeedView(
                    patientData: patientData, feedData: feedData);
              }),
        ]),
  ],
);

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'bottom nav bar with nested routing',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.mainMaterialColor,
        scaffoldBackgroundColor: Colors.white,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final platformProvider = Provider.of<Platform>(context, listen: false);
      await _initializeDeviceStorage();

      FirebaseMessaging.instance.getToken().then((token) {
        platformProvider.fcmToken = token ?? '';
      });
      platformProvider.camera = widget.camera;
      if (Theme.of(context).platform == TargetPlatform.android) {
        platformProvider.osDiv = '1';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        platformProvider.osDiv = '2';
      }
    });
  }

  Future<void> _initializeDeviceStorage() async {
    await EncryptedStorageService().initStorage();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await EncryptedStorageService().deleteAllData();
      prefs.setBool('first_run', false);
    }
  }
}
