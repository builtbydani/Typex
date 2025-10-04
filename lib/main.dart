import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/local_data_service.dart';
import 'viewmodels/type_chart_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/team_builder_viewmodel.dart';
import 'views/type_chart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TypeChartViewModel(LocalDataService())..load(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => TeamBuilderViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'Pokémon Type Chart',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const TypeChartScreen(),
          );
        },
      ),
    );
  }
}
