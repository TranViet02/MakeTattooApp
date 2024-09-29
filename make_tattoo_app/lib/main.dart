import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/providers/app_image_provider.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/editimage/crop_image.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/editimage/filter_image.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/editimage/flip_image.dart';
import 'package:make_tattoo_app/screens/edit_tattoo_image/edit_tattoo_screen.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/mockup_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/my_work_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/select_photo_screen.dart';
import 'package:make_tattoo_app/screens/select_image_tattoo/tattoo_ideas.dart';
import 'package:make_tattoo_app/screens/settings/language/locale_controller.dart';
import 'package:make_tattoo_app/screens/settings/language/translations.dart';
import 'package:make_tattoo_app/screens/splash_onbroading/splash/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppImageProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: MyTranslations(),
      fallbackLocale: const Locale('en'),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashScreen(),
        '/home': (_) => HomeScreen(),
        '/selectphoto': (_) => const SelectPhotoScreen(
              stickerPath: '',
            ),
        '/crop': (_) => const CropScreen(),
        '/filter': (_) => const FilterScreen(),
        '/flip': (_) => const FlipScreen(),
        '/mockup': (_) => const MockupScreen(
              stickerPath: '',
            ),
        '/edit': (_) => const EditTattooScreen(),
        '/tattooIdea': (_) => const TattooIdea(),
        '/mywork': (_) => const MyWorkScreen(),
      },
      initialBinding: BindingsBuilder(() {
        Get.put(LocaleController());
      }),
    );
  }
}
