import '/blocs/admin_bloc.dart';
import '/models/blog.dart';
import '/utils/dialog.dart';
import '/utils/styles.dart';
import '/widgets/blog_preview.dart';
import '/widgets/cover_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateBlog extends StatefulWidget {
  final Blog blogData;
  UpdateBlog({Key? key, required this.blogData}) : super(key: key);

  @override
  _UpdateBlogState createState() => _UpdateBlogState();
}

class _UpdateBlogState extends State<UpdateBlog> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var sourceCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();


  //bool notifyUsers = true;
  bool uploadStarted = false;




  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
      if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'You are a Tester', 'Only Admin can upload, delete & modify contents');
      } else {
        setState(()=> uploadStarted = true);
        await updateDatabase();
        setState(()=> uploadStarted = false);
        openDialog(context, 'Updated Successfully', '');
      }
    }
    
  }







  Future updateDatabase() async {
    final DocumentReference ref = firestore.collection('blogs').doc(widget.blogData.timestamp);
    var _blogData = {
      'title' : titleCtrl.text,
      'description' : descriptionCtrl.text,
      'image url' : imageUrlCtrl.text,
      'source' : sourceCtrl.text,
      
    };
    await ref.update(_blogData);
  }


  clearTextFeilds() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
    sourceCtrl.clear();
    FocusScope.of(context).unfocus();
  }




  handlePreview() async{
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await showBlogPreview(context, titleCtrl.text, descriptionCtrl.text, imageUrlCtrl.text, widget.blogData.loves, sourceCtrl.text, widget.blogData.date);
    }
  }


  initBlogData (){
    Blog d = widget.blogData;
    titleCtrl.text = d.title;
    descriptionCtrl.text = d.description;
    imageUrlCtrl.text = d.thumbUrl;
    sourceCtrl.text = d.sourceUrl;
  }



  @override
  void initState() {
    super.initState();
    initBlogData();
  }




  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      key: scaffoldKey,
      backgroundColor: Colors.grey[200],
      body: CoverWidget(widget: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: h * 0.10,
                ),
                const Text(
                  'Cập nhật chi tiết Blog',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 50,),

                TextFormField(
                  decoration: inputDecoration('Nhập tiêu đề', 'Tiêu đề', titleCtrl),
                  controller: titleCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Không để trống';
                    return null;
                  },
                  
                ),
                const SizedBox(height: 20,),


                TextFormField(
                  decoration: inputDecoration('Nhập URL hình ảnh', 'Image', imageUrlCtrl),
                  controller: imageUrlCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Không để trống';
                    return null;
                  },
                  
                ),
                
                
                const SizedBox(height: 20,),


                TextFormField(
                  decoration: inputDecoration('Nhậo URL nguồn', 'URL nguồn', sourceCtrl),
                  controller: sourceCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Value is empty';
                    return null;
                  },
                ),
                
                
                const SizedBox(height: 20,),


                TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Nhập mô tả (Html hoặc Văn bản thường)',
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
                  minLines: 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: descriptionCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return 'Value is empty';
                    return null;
                  },
                  
                ),

                const SizedBox(height: 100,),


                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        
                        TextButton.icon(
                          
                          icon: const Icon(Icons.remove_red_eye, size: 25, color: Colors.blueAccent,),
                          label: const Text('Preview', style: TextStyle(
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
                          'Update Blog',
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
              ],
            )),)
      
    );
  }








}
