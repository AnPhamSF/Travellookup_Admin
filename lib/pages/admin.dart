import '/blocs/admin_bloc.dart';
import '/utils/dialog.dart';
import '/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {


  final formKey = GlobalKey<FormState>();
  var passwordOldCtrl = TextEditingController();
  var passwordNewCtrl = TextEditingController();
  bool changeStarted = false;


  Future handleChange () async {
    final ab = context.read<AdminBloc>();
    if (ab.userType == 'tester') {
       openDialog(context, 'Bạn là Tester', 'Chỉ Admin mới có thể tải lên, xóa và sửa đổi nội dung');
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        setState(() {
          changeStarted = true;
        });

        await context.read<AdminBloc>().saveNewAdminPassword(passwordNewCtrl.text)
            .then((value) => openDialog(context, 'Mật khẩu đã được thay đổi thành công!', ''));

        setState(() {
          changeStarted = false;
        });

        clearTextFields();
      }
    }
  }



  clearTextFields (){
    passwordOldCtrl.clear();
    passwordNewCtrl.clear();
  }


  @override
  Widget build(BuildContext context) {
    final String adminPass = context.watch<AdminBloc>().adminPass;
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
          ),
          const Text("Đổi mật khẩu Admin", style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w800
          ),),
          Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(15)),
            ),
          const SizedBox(
            height: 100,
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: passwordOldCtrl,
                  decoration: inputDecoration('Nhập mật khẩu cũ', 'Mật khẩu cũ', passwordOldCtrl),
                  validator: (String? value){
                    if(value == null || value.isEmpty) return 'Mật khẩu cũ đang trống!';
                    if(value != adminPass) return 'Mật khẩu cũ không đúng. Hãy thử lại';
                    return null;
                  },
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  controller: passwordNewCtrl,
                  decoration: inputDecoration('Nhập mật khẩu mới', 'Mật khẩu mới', passwordNewCtrl),
                  obscureText: true,
                  validator: (String? value){
                    if(value == null || value.isEmpty) return 'Mật khẩu mới đang trống!';
                    if(value == adminPass) return 'Vui lòng sử dụng một mật khẩu khác';
                    return null;
                  },

                ),


                const SizedBox(height: 200,),


                Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.deepPurpleAccent,
                    height: 45,
                    child: changeStarted == true
                      ? Center(child: Container(height: 30, width: 30,child: const CircularProgressIndicator()),)
                      : TextButton(
                        child: const Text(
                          'Cập nhật mật khẩu',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async{
                          handleChange();
                          
                        })
                      
                      ),

              ],
            ),
          )
        ],
      )
    );
  }
}