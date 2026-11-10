import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'app_state.dart';
import '../navigation/main_navigation.dart';
import '../core/widgets/phone_frame_wrapper.dart';

class GreenPulseApp extends StatelessWidget {
  const GreenPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'GREENPULSE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const PhoneFrameWrapper(
          child: MainNavigation(),
        ),
      ),
    );
  }
}
