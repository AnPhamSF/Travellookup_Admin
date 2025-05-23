import '/blocs/admin_bloc.dart';
import '/models/state.dart';
import '/utils/dialog.dart';
import '/utils/styles.dart';
import '/utils/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class States extends StatefulWidget {
  const States({Key? key}) : super(key: key);

  @override
  _CitiesPageState createState() => _CitiesPageState();
}

class _CitiesPageState extends State<States> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = new List<DocumentSnapshot>.empty(growable: true);
  List<StateModel> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'states';

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
          .limit(15)
          .get();
    }

    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs.last;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => StateModel.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      //openToast(context, 'No more contents available!');
    }
    return;
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
            Text('Muốn xóa mục này khỏi cơ sở dữ liệu?',
                
                style: TextStyle(
                    color: Colors.grey[900],
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)))),
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
                    openDialog(context, 'Bạn là Tester','Chỉ có admin có thể xóa');
                  } else {
                    await ab.deleteContent(timestamp1, collectionName)
                    .then((value) => ab.getStates())
                    .then((value) => ab.decreaseCount('states_count'))
                    .then((value) => openToast1(context, 'Xóa thành công'));
                    refreshData();
                    Navigator.pop(context);
                    

                  }
                },
              ),

              const SizedBox(width: 10),

              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)))),
                child: const Text(
                  'Không',
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
              'Tỉnh/Thành phố',
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
                  openAddDialog();
                }, 
                icon: const Icon(LineIcons.list),
                label: const Text('Thêm tỉnh/thành phố')),
                
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
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: RefreshIndicator(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _data.length + 1,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10,),
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




  Widget dataList(StateModel d) {
    return Container(
          height: 130,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: CachedNetworkImageProvider(d.thumbnailUrl),
              fit: BoxFit.cover
            )
          ),

          child: 
          
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(d.name, style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white
              ),),
              const Spacer(),
              InkWell(
               child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.delete,
                                    size: 16, color: Colors.grey[800])),
                            onTap: (){
                              handleDelete(d.timestamp);
                            }),
                          

            ],
          ),
          
          
    );
  }





  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var thumbnailCtrl = TextEditingController();
  late String timestamp;


  Future addState () async{
    final DocumentReference ref = firestore.collection(collectionName).doc(timestamp);
    await ref.set({
      'name' : nameCtrl.text,
      'thumbnail' : thumbnailCtrl.text,
      'timestamp' : timestamp
    });
  }



  handleAddState () async{
    final AdminBloc ab  = Provider.of<AdminBloc>(context, listen: false);
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      if (ab.userType == 'tester') {
        Navigator.pop(context);
        openDialog(context, 'Bạn là Tester', 'Chỉ có admin mới có thể thêm nội dung');
      } else {
        await getTimestamp()
        .then((value) => addState())
        .then((value) => context.read<AdminBloc>().increaseCount('states_count'))
        .then((value) => ab.getStates());
        refreshData();
        Navigator.pop(context);
      }
      

    }
  }


  clearTextfields (){
    nameCtrl.clear();
    thumbnailCtrl.clear();
  }



  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      timestamp = _timestamp;
    });
    
  }



  openAddDialog (){
    showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
            contentPadding: const EdgeInsets.all(100),
            children: <Widget>[
              const Text('Thêm tỉnh/thành phố vào cơ sở dữ liệu', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
              const SizedBox(height: 50,),
              Form(
                key: formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                  decoration: inputDecoration('Nhập tên tỉnh/thành phố', 'Tên tỉnh thành phố', nameCtrl),
                  controller: nameCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Tên tỉnh/thành phố trống';
                    return null;
                    },
                  
                  ),

                  

                  const SizedBox(height: 20,),

                  TextFormField(
                  decoration: inputDecoration('Nhập URL Thumbnail', 'Thumbnail Url', thumbnailCtrl),
                  controller: thumbnailCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Thumbnail url trống';
                    return null;
                    },
                  
                  ),

                const SizedBox(height: 50,),

                Center(
                child: Row(
                children: <Widget>[


                  TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)))),
                child: const Text(
                  'Thêm tỉnh/thành',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: ()async{
                  

                  await handleAddState();
                  clearTextfields();
                  
                  
                  
                  
                },
              ),

              const SizedBox(width: 10),

              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)))),
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