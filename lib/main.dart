import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/auth_service.dart';
import 'data/repositories/rtdb_repository.dart';
import 'logic/bloc/auth_bloc.dart';
import 'logic/bloc/general_bloc.dart';
import 'logic/bloc/lecture_bloc.dart';
import 'presentation/themes/app_theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final repo = RTDBRepo();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(auth)..add(AuthWatchRequested())),
        BlocProvider(create: (_) => GeneralBloc(repo)),
        BlocProvider(create: (_) => LectureBloc(repo)),
      ],
      child: MaterialApp(
        title: 'Class Whisperer',
        theme: appTheme(),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.map,
      ),
    );
  }
}
