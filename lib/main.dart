import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/local_data_service.dart';
import 'viewmodels/type_chart_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TypeChartViewModel(LocalDataService())..load(),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
      ],
      child: MaterialApp(
        title: 'Pokémon Type Chart',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
