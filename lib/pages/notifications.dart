import '/blocs/admin_bloc.dart';
import '/blocs/notification_bloc.dart';
import '/config/config.dart';
import '/models/notification.dart';
import '/utils/dialog.dart';
import '/utils/notification_preview.dart';
import '/utils/styles.dart';
import '/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
//import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';



class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
   DocumentSnapshot? _lastVisible;
  late bool _isLoading;
   List<DocumentSnapshot> _snap = List<DocumentSnapshot>.empty(growable: true);
   List<NotificationModel> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
   final collectionName = 'notifications';

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

   Future<void> _getData() async {
     QuerySnapshot data;
     if (_lastVisible == null) {
       data = await firestore
           .collection(collectionName)
           .orderBy('timestamp', descending: true)
           .limit(10)
           .get();
     } else {
       data = await firestore
           .collection(collectionName)
           .orderBy('timestamp', descending: true)
           .startAfter([_lastVisible!['timestamp']])
           .limit(10)
           .get();
     }

     if (data.docs.isNotEmpty) {
       _lastVisible = data.docs[data.docs.length - 1];
       if (mounted) {
         setState(() {
           _isLoading = false;
           _snap.addAll(data.docs);
           _data = _snap.map((e) => NotificationModel.fromFirestore(e)).toList();
         });
       }
     } else {
       setState(() => _isLoading = false);
       //openToast(context, 'No more contents available!');
     }
     return null;
   }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }


   refreshData (){
     setState(() {
       _data.clear();
       _snap.clear();
       _lastVisible = null;
     });
     _getData();
   }



   handleDelete(timestamp1) {
     final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
     showDialog(
         context: context,
         builder: (BuildContext context) {
           return SimpleDialog(
           contentPadding: const EdgeInsets.all(50),
           elevation: 0,
           children: <Widget>[
             const Text('Xóa?',
                 style: TextStyle(
                     color: Colors.black,
                     fontSize: 20,
                     fontWeight: FontWeight.w900)),
             const SizedBox(
               height: 10,
             ),
             const Text('Muốn xóa mục này khỏi cơ sở dữ liệu?',
                 style: TextStyle(
                     color: Colors.grey,
                     fontSize: 16,
                     fontWeight: FontWeight.w700)),
             const SizedBox(
               height: 30,
             ),
             Center(
               child: Row(
                 children: <Widget>[
                   TextButton(
                 style: ButtonStyle(
                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25))
                     ),
                     backgroundColor: MaterialStateProperty.all(Colors.redAccent)
                   ),
                 child: const Text(
                   'Có',
                   style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.w600),
                 ),
                 onPressed: ()async{
                   if (ab.userType == 'tester') {
                     Navigator.pop(context);
                     openDialog(context, 'You are a Tester','Only admin can delete contents');
                   } else {
                     await ab.deleteContent(timestamp1, collectionName)
                     .then((value) => ab.decreaseCount('notifications_count'));
                     refreshData();
                     Navigator.pop(context);
                   }
                 },
               ),

               const SizedBox(width: 10),

               TextButton(
                 style: ButtonStyle(
                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25))
                     ),
                     backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent)
                   ),
                 child: const Text(
                   'No',
                   style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.w600),
                 ),
                 onPressed: () => Navigator.pop(context),
               ),
                 ],
               )
             )
           ],
         );
         
         });
   }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Container(
              width: 300,
              height: 40,
              padding: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(30)),
              child: TextButton.icon(
                onPressed: (){
                  openSendNotificationDialog();
                }, 
                icon: const Icon(LineIcons.bell),
                label: const Text('Gửi thông báo')),
                
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 10),
          height: 3,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(15)),
        ),
         Expanded(
           child: RefreshIndicator(
             child: ListView.builder(
               padding: const EdgeInsets.only(top: 30, bottom: 20),
               controller: controller,
               physics: const AlwaysScrollableScrollPhysics(),
               itemCount: _data.length + 1,
               itemBuilder: (_, int index) {
                 if (index < _data.length) {
                   return dataList(_data[index]);
                 }
                 return Center(
                   child: new Opacity(
                     opacity: _isLoading ? 1.0 : 0.0,
                     child: new SizedBox(
                         width: 32.0,
                         height: 32.0,
                         child: new CircularProgressIndicator()),
                   ),
                 );
               },
             ),
             onRefresh: () async {
               refreshData();

                    
             },
           ),
         ),
      ],
    );
  }

   Widget dataList(NotificationModel d) {
     return Container(
           margin: const EdgeInsets.only(top: 5, bottom: 5),
           padding: const EdgeInsets.all(15),
           decoration: BoxDecoration(
               border: Border.all(color: Colors.grey),
               borderRadius: BorderRadius.circular(10)),
           child: ListTile(
             leading: ClipRRect(
               borderRadius: BorderRadius.circular(10),
               child: Image.asset(Config().icon)),
             title: Text(d.title, style:const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
             subtitle: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Text(d.description,
                   maxLines: 3,
                   overflow: TextOverflow.ellipsis,
                   style:const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                 const SizedBox(height: 5,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: <Widget>[
                     const Icon(Icons.access_time, size: 16, color: Colors.grey),
                     const SizedBox(width: 2),
                     Text(d.createdAt, style:const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
                   ],
                 )
               ],
             ),
             isThreeLine: true,
             trailing: InkWell(
                child: Container(
                         height: 35,
                         width: 45,
                         decoration: BoxDecoration(
                           color: Colors.grey[200],
                           borderRadius: BorderRadius.circular(10)),
                         child: Icon(Icons.delete,
                                     size: 16, color: Colors.grey[800])),
                             onTap: (){
                               handleDelete(d.timestamp);
                             }),
                           ),
          
          
           );
   }





  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  late String timestamp;



   handleSendNotification () async{
     final AdminBloc ab  = Provider.of<AdminBloc>(context, listen: false);
     if(formKey.currentState!.validate()){
       formKey.currentState!.save();
       if (ab.userType == 'tester') {
         Navigator.pop(context);
         openDialog(context, 'bạn là Tester', 'chỉ có admin có thể gửi thông báo');
       } else {
         await getTimestamp()
         .then((value) => context.read<NotificationBloc>().sendNotification(titleCtrl.text, descriptionCtrl.text))
         .then((value) => context.read<NotificationBloc>().saveToDatabase(timestamp, titleCtrl.text, descriptionCtrl.text))
         .then((value) => context.read<AdminBloc>().increaseCount('notifications_count'));
         refreshData();
         Navigator.pop(context);
       }
      
      

     }
   }


  clearTextfields (){
    titleCtrl.clear();
    descriptionCtrl.clear();
  }


   handleOpenPreview (){
     if(formKey.currentState!.validate()){
       formKey.currentState!.save();
       showNotificationPreview(context, titleCtrl.text, descriptionCtrl.text);
     }
   }


  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      timestamp = _timestamp;
    });
    
  }

   openSendNotificationDialog (){
     showDialog(
       context: context,
       builder: (context){
         return SimpleDialog(
             contentPadding: const EdgeInsets.all(100),
             children: <Widget>[
               const Text('Gửi thông báo đẩy tới tất cả người dùng', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
               const SizedBox(height: 50,),
               Form(
                 key: formKey,
                 child: Column(children: <Widget>[
                   TextFormField(
                   decoration: inputDecoration('Nhập tiêu đề thông báo', 'Tiêu đề', titleCtrl),
                   controller: titleCtrl,
                   validator: (value) {
                     if (value!.isEmpty) return 'Tiêu đề trống';
                     return null;
                     },
                  
                   ),

                  

                   const SizedBox(height: 20,),

                   TextFormField(
                   decoration: InputDecoration(
                       hintText: 'Nhập mô tả (hỗ trợ văn bản HTML)',
                       border: const OutlineInputBorder(),
                       labelText: 'Mô tả',
                       contentPadding: const EdgeInsets.only(
                           right: 0, left: 10, top: 15, bottom: 5),
                       suffixIcon: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: CircleAvatar(
                           radius: 15,
                           backgroundColor: Colors.grey[300],
                           child: IconButton(
                               icon: const Icon(Icons.close, size: 15),
                               onPressed: () {
                                 descriptionCtrl.clear();
                               }),
                         ),
                       )),
                   textAlignVertical: TextAlignVertical.top,
                   minLines: 4,
                   maxLines: null,
                   keyboardType: TextInputType.multiline,
                   controller: descriptionCtrl,
                   validator: (value) {
                     if (value!.isEmpty) return 'Mô tả trống';
                     return null;
                   },
                  
                 ),
                
                  


                 const SizedBox(height: 50,),

                 Center(
                 child: Row(
                 children: <Widget>[

                   TextButton(
                 style: ButtonStyle(
                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25))
                     ),
                     backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent)
                   ),
                 child: const Text(
                   'Xem trước',
                   style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.w600),
                 ),
                 onPressed: ()async{
                 
                   handleOpenPreview();
                  
                  
                  
                 },
               ),

               const SizedBox(width: 10),


                   TextButton(
                 style: ButtonStyle(
                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25))
                     ),
                     backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent)
                   ),
                 child: const Text(
                   'Send Now',
                   style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.w600),
                 ),
                 onPressed: ()async{
                  

                   await handleSendNotification();
                   clearTextfields();
                  
                  
                  
                  
                 },
               ),

               const SizedBox(width: 10),

               TextButton(
                 style: ButtonStyle(
                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25))
                     ),
                     backgroundColor: MaterialStateProperty.all(Colors.redAccent)
                   ),
                 child: const Text(
                   'Cancel',
                   style: TextStyle(
                       color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.w600),
                 ),
                 onPressed: () => Navigator.pop(context),
               ),
                 ],
               )
             )
                 ],)
               )
             ],
           );
        
       }
     );
   }


}