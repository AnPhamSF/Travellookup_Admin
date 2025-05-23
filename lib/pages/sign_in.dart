import '/blocs/admin_bloc.dart';
import '/config/config.dart';
import '/pages/home.dart';
import '/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {


  var passwordCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  late String password;


  handleSignIn () async{
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState!.validate()) {
      if (password == Config().testerPassword) {
        await ab.setSignInForTesting()
            .then((value) => nextScreenReplace(context, HomePage()));
      } else {
        await ab.setSignIn()
            .then((value) => nextScreenReplace(context, HomePage()));
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          
          height: 400,
          width: 600,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, blurRadius: 10, offset: Offset(3, 3))
            ],
          ),
          child: Column(
            
            children: <Widget>[
              const SizedBox(height: 50,),
              
              Text(Config().appName, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),

              const Text('Chào mừng đến với Admin Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              const SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                  hintText: 'Nhập Password',
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  contentPadding: const EdgeInsets.only(right: 0, left: 10),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey[300],
                      child: IconButton(icon: const Icon(Icons.close, size: 15), onPressed: (){
                        passwordCtrl.clear();
                      }),
                    ),
                  )
                  
                ),
                validator: (String? value) {
                  String? adminPassword = ab.adminPass;
                  if (value == null || value.isEmpty) {
                    return "Mật khẩu không được để trống";
                  } else if (value != adminPassword && value != Config().testerPassword) {
                    return 'Mật khẩu sai! Vui lòng thử lại.';
                  }
                  return null;
                },
                onChanged: (String value){
                  setState(() {
                    password = value;
                  });
                },
                )),
              ),
              const SizedBox(height: 30,),
              Container(
            height: 45,
            width: 200,
            decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10,
                offset: Offset(2, 2)
              )
            ]

            ),
            child: TextButton.icon(
              //padding: EdgeInsets.only(left: 30, right: 30),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  )
                )
              ),
              icon: const Icon(LineIcons.arrowRight, color: Colors.white, size: 25,),
              label: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),),
              onPressed: () => handleSignIn(), 
              ),
          ),
            ],
          ),
        ),
      )
    );
  }
}