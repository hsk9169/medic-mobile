import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:medic_app/widgets/dismiss_keyboard.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/app.dart';
import 'firebase_options.dart';
import 'kakao_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  dynamic firstCamera;
  try {
    firstCamera = cameras.first;
  } catch (err) {
    firstCamera = null;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // fix screen rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(DismissKeyboard(
        child: MultiProvider(providers: [
      ChangeNotifierProvider<Session>.value(value: Session()),
      ChangeNotifierProvider<Platform>.value(value: Platform()),
    ], child: MyApp(camera: firstCamera))));
  });
}
