import '../utils/dialog.dart';
import '../utils/toast.dart';
import '../widgets/place_preview.dart';
import '/blocs/admin_bloc.dart';
import '/utils/styles.dart';
import '/widgets/place_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadPlace extends StatefulWidget {
  UploadPlace({Key? key}) : super(key: key);

  @override
  _UploadPlaceState createState() => _UploadPlaceState();
}

class _UploadPlaceState extends State<UploadPlace> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'places';
  List paths =[];
  final int _loves = 0;
  final int _commentsCount = 0;
  late String _date;
  late String _timestamp;
  String _helperText = 'Nhập danh sách hướng dẫn để giúp người dùng đi đến điểm mong muốn như: Từ Sân bay đến Bến Thành bằng xe buýt số .....';

  var stateSelection;

  var nameCtrl = TextEditingController();
  var locationCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var image1Ctrl = TextEditingController();
  var image2Ctrl = TextEditingController();
  var image3Ctrl = TextEditingController();
  var latCtrl = TextEditingController();
  var lngCtrl = TextEditingController();


  var startpointNameCtrl = TextEditingController();
  var endpointNameCtrl = TextEditingController();
  var priceCtrl = TextEditingController();
  var startpointLatCtrl = TextEditingController();
  var startpointLngCtrl = TextEditingController();
  var endpointLatCtrl = TextEditingController();
  var endpointLngCtrl = TextEditingController();
  var pathsCtrl = TextEditingController();



  clearFields(){
    nameCtrl.clear();
    locationCtrl.clear();
    descriptionCtrl.clear();
    image1Ctrl.clear();
    image2Ctrl.clear();
    image3Ctrl.clear();
    latCtrl.clear();
    lngCtrl.clear();
    startpointNameCtrl.clear();
    endpointNameCtrl.clear();
    priceCtrl.clear();
    startpointLatCtrl.clear();
    startpointLngCtrl.clear();
    endpointLatCtrl.clear();
    endpointLngCtrl.clear();
    pathsCtrl.clear();
    paths.clear();
    FocusScope.of(context).unfocus();
  }




  bool notifyUsers = true;
  bool uploadStarted = false;




  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);

    if(stateSelection == null){
      openDialog(context, 'Chọn tỉnh/thành phố trước', '');
    }
    else{
      if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if(paths.isEmpty){
        //openSnacbar(scaffoldKey, 'Paths List can not be empty');
      } else {
        if (ab.userType == 'tester') {
        openDialog(context, 'Bạn là Tester', 'Chỉ có Admin mới có thể tải lên, xóa và sửa đổi nội dung');
      } else {
        setState(()=> uploadStarted = true);
        await getDate().then((_) async{
          await saveToDatabase()
          .then((value) => context.read<AdminBloc>().increaseCount('places_count'));
          setState(()=> uploadStarted = false);
          openDialog(context, 'Đã tải lên thành công', '');
          clearFields();

        });
      }
      }

    }
    }

  }

  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    String _t = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      _timestamp = _t;
      _date = _d;
    });

  }



  Future saveToDatabase() async {
    final DocumentReference ref = firestore.collection(collectionName).doc(_timestamp);
    final DocumentReference ref1 = firestore.collection(collectionName).doc(_timestamp).collection('travel guide').doc(_timestamp);


    var _placeData = {
      'state' : stateSelection,
      'place name' : nameCtrl.text,
      'location' : locationCtrl.text,
      'latitude' : double.parse(latCtrl.text),
      'longitude' : double.parse(lngCtrl.text),
      'description' : descriptionCtrl.text,
      'image-1' : image1Ctrl.text,
      'image-2' : image2Ctrl.text,
      'image-3' : image3Ctrl.text,
      'loves' : _loves,
      'comments count' : _commentsCount,
      'date' : _date,
      'timestamp' : _timestamp
    };

    var _guideData  = {
      'startpoint name' : startpointNameCtrl.text,
      'endpoint name' : endpointNameCtrl.text,
      'startpoint lat' : double.parse(startpointLatCtrl.text),
      'startpoint lng' : double.parse(startpointLngCtrl.text),
      'endpoint lat' : double.parse(endpointLatCtrl.text),
      'endpoint lng' : double.parse(endpointLngCtrl.text),
      'price': priceCtrl.text,
      'paths' : paths
    };

    await ref.set(_placeData)
    .then((value) => ref1.set(_guideData));
  }






  handlePreview() async{
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if(paths.isNotEmpty){
        showPlacePreview(
          context,
          nameCtrl.text,
          locationCtrl.text,
          image1Ctrl.text,
          descriptionCtrl.text,
          double.parse(latCtrl.text),
          double.parse(lngCtrl.text),
          startpointNameCtrl.text,
          endpointNameCtrl.text,
          double.parse(startpointLatCtrl.text),
          double.parse(startpointLngCtrl.text),
          double.parse(endpointLatCtrl.text),
          double.parse(endpointLngCtrl.text),
          priceCtrl.text,
          paths
        );
      }else{
        openToast(context, 'Danh sách hướng dẫn đang trống!');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      body: Form(
            key: formKey,
            child: ListView(children: <Widget>[
              SizedBox(height: h * 0.10,),
              const Text('Chi tiết địa điểm', style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800
              ),),
              const SizedBox(height: 20,),
              statesDropdown(),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: inputDecoration('Nhập tên địa điểm', 'Tên địa điểm', nameCtrl),
                controller: nameCtrl,
                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: inputDecoration('Nhập tên vị trí', 'Tên vị trí', locationCtrl),
                controller: locationCtrl,

                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 20,),


              Row(
                children: <Widget>[
                  Expanded(
                child: TextFormField(
                decoration: inputDecoration('Nhập vĩ độ', 'Vĩ độ', latCtrl),
                controller: latCtrl,
                keyboardType: TextInputType.number,
                validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
            ),
              const SizedBox(width: 10,),
              Expanded(
                            child: TextFormField(
                  decoration: inputDecoration('Nhập kinh độ', 'Kinh độ', lngCtrl),
                  keyboardType: TextInputType.number,

                  controller: lngCtrl,
                  validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                  },

                ),
              ),

                ],
              ),
              const SizedBox(height: 20,),


              TextFormField(
                decoration: inputDecoration('Nhập URL hình ảnh (thumbnail)', 'Image1(Thumbnail)', image1Ctrl),
                controller: image1Ctrl,
                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: inputDecoration('Nhập URL hình ảnh', 'Image2', image2Ctrl),
                controller: image2Ctrl,
                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: inputDecoration('Nhập URL hình ảnh', 'Image3', image3Ctrl),
                controller: image3Ctrl,
                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Nhập thông tin chi tiết về địa điểm (Html hoặc văn bản thường)',
                  border: const OutlineInputBorder(),
                  labelText: 'Chi tiết địa điểm',
                  contentPadding: const EdgeInsets.only(right: 0, left: 10, top: 15, bottom: 5),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey[300],
                      child: IconButton(icon: const Icon(Icons.close, size: 15), onPressed: (){
                        descriptionCtrl.clear();
                      }),
                    ),
                  )

                ),
                textAlignVertical: TextAlignVertical.top,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: descriptionCtrl,
                validator: (value){
                  if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
              const SizedBox(height: 50,),
              const Text('Chi tiết hướng dẫn du lịch', style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800
              ),),
              const SizedBox(height: 20,),


              Row(
                children: <Widget>[
                  Expanded(
                                    child: TextFormField(
                decoration: inputDecoration('Nhập tên điểm bắt đầu', 'Tên điểm bắt đầu', startpointNameCtrl),
                controller: startpointNameCtrl,

                validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
                  ),
              const SizedBox(width: 10,),
              Expanded(
                            child: TextFormField(
                  decoration: inputDecoration('Nhập tên điểm đến', 'Tên điểm đến', endpointNameCtrl),


                  controller: endpointNameCtrl,
                  validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                  },

                ),
              ),

                ],
              ),

              const SizedBox(height: 20,),
              TextFormField(
                  decoration: inputDecoration('Nhập chi phí đi lại', 'Giá', priceCtrl),
                  keyboardType: TextInputType.number,

                  controller: priceCtrl,
                  validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                  },

                ),
              const SizedBox(height: 20,),

              Row(
                children: <Widget>[
                  Expanded(
                                    child: TextFormField(
                decoration: inputDecoration('Nhập vĩ độ điểm bắt đầu', 'Vĩ độ điểm bắt đầu', startpointLatCtrl),
                controller: startpointLatCtrl,
                keyboardType: TextInputType.number,
                validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
                  ),
              const SizedBox(width: 10,),
              Expanded(
                            child: TextFormField(
                  decoration: inputDecoration('Nhập kinh độ điểm bắt đầu', 'Kinh độ điểm bắt đầu', startpointLngCtrl),
                  keyboardType: TextInputType.number,

                  controller: startpointLngCtrl,
                  validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                  },

                ),
              ),

                ],
              ),
              const SizedBox(height: 20,),

              Row(
                children: <Widget>[
                  Expanded(
                                    child: TextFormField(
                decoration: inputDecoration('Nhập vĩ độ điểm đến', 'Vĩ độ điểm đến', endpointLatCtrl),
                controller: endpointLatCtrl,
                keyboardType: TextInputType.number,
                validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                },

              ),
                  ),
              const SizedBox(width: 10,),
              Expanded(
                  child: TextFormField(
                  decoration: inputDecoration('Nhập kinh độ điểm đến', 'Kinh độ điểm đến', endpointLngCtrl),
                  keyboardType: TextInputType.number,

                  controller: endpointLngCtrl,
                  validator: (value){
                    if(value!.isEmpty) return 'Không để trống'; return null;
                  },

                ),
              ),

                ],
              ),
              const SizedBox(height: 20,),

              TextFormField(

                  decoration: InputDecoration(
                  hintText: "Nhập danh sách hướng dẫn từng cái một bằng cách nhấn 'Enter' mỗi lần",
                  border: const OutlineInputBorder(),
                  labelText: 'Danh sách hướng dẫn',
                  helperText: _helperText,
                  contentPadding: const EdgeInsets.only(right: 0, left: 10, top: 15, bottom: 5),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey[300],
                      child: IconButton(icon: const Icon(Icons.clear, size: 15, color: Colors.blueAccent,), onPressed: (){
                        pathsCtrl.clear();
                      }),
                    ),
                  )

                ),
                  controller: pathsCtrl,

                  onFieldSubmitted: (String value) {
                    if(value.isEmpty){
                      setState(() {
                      _helperText = "Bạn không thể đặt mục trống vào danh sách";

                      });
                    } else{
                      setState(() {
                      paths.add(value);
                      _helperText = 'Added ${paths.length} items';
                      print(paths);
                    });
                    }

                  },
                ),

              const SizedBox(height: 20,),
              Container(

                child: paths.isEmpty ? const Center(child: Text('Không có danh sách hướng dẫn nào được thêm vào'),) :

                ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paths.length,
                      itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(index.toString()),
                        ),
                        title: Text(paths[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: (){
                            setState(() {
                              paths.remove(paths[index]);
                              _helperText = 'Thêm ${paths.length} items';

                            });
                          }),
                      );
                     },
                    ),


              ),


              const SizedBox(height: 100,),


                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton.icon(
                          icon: const Icon(Icons.remove_red_eye, size: 25, color: Colors.blueAccent,),
                          label: const Text('Xem trước', style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black
                          ),),
                          onPressed: (){
                            handlePreview();
                          }
                        )
                      ],
                    ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    color: Colors.deepPurpleAccent,
                    height: 45,
                    child: uploadStarted == true
                      ? Center(child: Container(height: 30, width: 30,child: const CircularProgressIndicator()),)
                      : TextButton(
                        child: const Text(
                          'Tải lên dữ liệu địa điểm',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async{
                          handleSubmit();

                        })

                      ),
                const SizedBox(
                  height: 200,
                ),



            ],)),
      );

   }



  Widget statesDropdown() {
    final AdminBloc ab = Provider.of(context, listen: false);
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                //fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                stateSelection = value;
              });
            },
            onSaved: (value) {
              setState(() {
                stateSelection = value;
              });
            },
            value: stateSelection,
            hint: const Text('Chọn tỉnh/thành phố'),
            items: ab.states.map((f) {
              return DropdownMenuItem(
                value: f,
                child: Text(f),
              );
            }).toList()));
  }


}
