import '/blocs/admin_bloc.dart';
import '/models/blog.dart';
import '/pages/comments.dart';
import '/pages/update_blog.dart';
import '/utils/cached_image.dart';
import '/utils/dialog.dart';
import '/utils/next_screen.dart';
import '/utils/toast.dart';
import '/widgets/blog_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = List<DocumentSnapshot>.empty(growable: true);
  List<Blog> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String collectionName = 'blogs';

  @override
  void initState() {
    controller = ScrollController()..addListener(_scrollListener);
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
      _lastVisible = data.docs.last;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Blog.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'No more content available');
    }
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

  navigateToCommentsPage(timestamp) {
    nextScreen(
      context,
      CommentsPage(
        collectionName: collectionName,
        timestamp: timestamp,
        title: 'Blog',
      ),
    );
  }

  handlePreview(Blog d) async {
    await showBlogPreview(
      context,
      d.title,
      d.description,
      d.thumbUrl, // FIXED: dùng thumbUrl đúng với model
      d.loves,
      d.sourceUrl,
      d.date,
    );
  }

  reloadData() {
    setState(() {
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
  }

  Future handleDelete(timestamp) async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          elevation: 0,
          children: <Widget>[
            Text(
              'Delete?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Want to delete this item from the database?',
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Row(
                children: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await ab
                          .deleteContent(timestamp, 'blogs')
                          .then((value) => ab.decreaseCount('blogs_count'));
                      reloadData();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Blogs',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 10),
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.indigoAccent,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => reloadData(),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _data.length + 1,
              itemBuilder: (_, int index) {
                if (index < _data.length) {
                  return dataList(_data[index]);
                }
                return Center(
                  child: Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget dataList(Blog d) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomCacheImage(imageUrl: d.thumbUrl, radius: 10),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    d.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Icon(Icons.access_time, size: 15, color: Colors.grey),
                      SizedBox(width: 3),
                      Text(
                        d.date,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      _iconWithCount(Icons.favorite, d.loves.toString()),
                      SizedBox(width: 10),
                      _iconButton(Icons.comment, () => navigateToCommentsPage(d.timestamp)),
                      SizedBox(width: 10),
                      _iconButton(Icons.remove_red_eye, () => handlePreview(d)),
                      SizedBox(width: 10),
                      _iconButton(Icons.edit, () {
                         nextScreen(context, UpdateBlog(blogData: d));
                      }),
                      SizedBox(width: 10),
                      _iconButton(Icons.delete, () => handleDelete(d.timestamp)),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconWithCount(IconData icon, String count) {
    return Container(
      height: 35,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          Text(count, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      child: Container(
        height: 35,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[800]),
      ),
      onTap: onTap,
    );
  }
}
