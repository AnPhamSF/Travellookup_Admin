import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:travellookup_admin/firebase_options.dart';
import '/pages/home.dart';
import '/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '/blocs/admin_bloc.dart';
import '/blocs/notification_bloc.dart';
import '/blocs/comment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminBloc>(create: (_) => AdminBloc()),
        ChangeNotifierProvider<CommentBloc>(create: (_) => CommentBloc()),
        ChangeNotifierProvider<NotificationBloc>(create: (_) => NotificationBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          ToastContext().init(context);
          return child!;
        },
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Muli',
          appBarTheme: AppBarTheme(
            color: Colors.white,
            elevation: 0,
            actionsIconTheme: IconThemeData(color: Colors.grey[900]),
            iconTheme: IconThemeData(color: Colors.grey[900]),
            toolbarTextStyle: TextTheme(
              titleLarge: TextStyle(
                fontFamily: 'Muli',
                color: Colors.grey[900],
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ).bodyMedium,
            titleTextStyle: TextTheme(
              titleLarge: TextStyle(
                fontFamily: 'Muli',
                color: Colors.grey[900],
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ).titleLarge,
          ),
        ),
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ab = context.watch<AdminBloc>();
    return ab.isSignedIn ? HomePage() : const SignInPage();
  }
}
