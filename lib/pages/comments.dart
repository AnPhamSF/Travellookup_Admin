import '/blocs/admin_bloc.dart';
import '/blocs/comment_bloc.dart';
import '/models/comment.dart';
import '/utils/dialog.dart';
import '/utils/toast.dart';
import '/widgets/cover_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatefulWidget {
  final String title;
  final String collectionName;
  final String timestamp;
  const CommentsPage(
      {Key? key,
      required this.collectionName,
      required this.timestamp,
      required this.title})
      : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = List<DocumentSnapshot>.empty(growable: true);
  List<Comment> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textFieldCtrl = TextEditingController();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }




  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection('${widget.collectionName}/${widget.timestamp}/comments')
          .orderBy('timestamp', descending: true)
          .limit(15)
          .get();
    } else {
      data = await firestore
          .collection('${widget.collectionName}/${widget.timestamp}/comments')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(15)
          .get();
    }

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Comment.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'Không còn nội dung nào nữa!');
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

  



  handleDelete(context, Comment d) {
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
              Text('Bạn muốn xóa mục này khỏi cơ sở dữ liệu?',
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
                            MaterialStateProperty.all(Colors.deepPurpleAccent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)))),
                    child: const Text(
                      'Có',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (ab.userType == 'tester') {
                        Navigator.pop(context);
                        openDialog(context, 'Bạn là Tester','Chỉ có Admin mới có thể tải lên, xóa và sửa đổi nội dung');
                      } else {
                        await context.read<CommentBloc>().deleteComment(widget.timestamp, d.uid, d.timestamp, widget.collectionName)
                        .then((value){
                          if(widget.collectionName == 'places'){
                            context.read<CommentBloc>().decreaseCommentsCount(widget.timestamp);
                          }
                        })
                        .then((value) => openToast1(context, 'Đã xóa bình luận thành công'));
                        reloadData();
                        Navigator.pop(context);
                      }
                      
                    },
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurpleAccent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
              ))
            ],
          );
        });
  }

  

  clearTextFields() {
    textFieldCtrl.clear();
  }

  reloadData() {
    setState(() {
      _snap.clear();
      _data.clear();
      _lastVisible = null;
      
    });
    _getData();
  }




  handleSubmit(value) async {
    final  ab = context.read<AdminBloc>();
    if(ab.userType == 'tester'){
      openDialog(context, 'Bạn là Tester','Chỉ có Admin mới có thể bình luận');
    }else{
      if (value.isEmpty) {
      openDialog(context, 'Viết bình luận!', '');
    } else {
      await context
          .read<CommentBloc>()
          .saveNewComment(widget.timestamp, textFieldCtrl.text, widget.collectionName)
          .then((value){
            if(widget.collectionName == 'places'){
              context.read<CommentBloc>().increaseCommmentsCount(widget.timestamp);
            }
          })
          .then((value) => openToast(context, 'Đã thêm bình luận thành công!'));
      clearTextFields();
      reloadData();
    }
    }
  }



  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: false,
          title: Text('${widget.title} Comments'),
          elevation: 1,
        ),
        body: CoverWidget(
          widget: Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    controller: controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _data.length + 1,
                    itemBuilder: (_, int index) {
                      if (index < _data.length) {
                        return reviewList(_data[index]);
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
                    reloadData();
                  },
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.black26,
              ),
              SafeArea(
                child: Container(
                  height: 65,
                  padding:
                      const EdgeInsets.only(top: 8, bottom: 10, right: 20, left: 20),
                  width: double.infinity,
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25)),
                    child: TextFormField(
                      decoration: InputDecoration(
                          errorStyle: const TextStyle(fontSize: 0),
                          contentPadding:
                              const EdgeInsets.only(left: 15, top: 10, right: 5),
                          border: InputBorder.none,
                          hintText: 'Write a comment',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.grey[700],
                              size: 20,
                            ),
                            //onPressed: null,
                            onPressed: () => handleSubmit(textFieldCtrl.text),
                          )),
                      controller: textFieldCtrl,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget reviewList(Comment d) {
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: CachedNetworkImageProvider(d.imageUrl),
          ),
          title: Row(
            children: <Widget>[
              Text(
                d.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(d.date,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          subtitle: Text(
                  d.comment,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
          trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                handleDelete(context, d);
              }),
        ));
  }




  
}
