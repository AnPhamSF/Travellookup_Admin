import '/blocs/admin_bloc.dart';
import '/models/place.dart';
import '/pages/comments.dart';
import '/pages/update_place.dart'; // Bật lại import UpdatePlace
import '/utils/cached_image.dart';
import '/utils/dialog.dart';
import '/utils/next_screen.dart';
import '/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = List<DocumentSnapshot>.empty(growable: true);
  List<Place> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String collectionName = 'places';

  @override
  void initState() {
    controller = ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
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
          _data = _snap.map((e) => Place.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'No more contents available!');
    }
    return null;
  }

  refreshData() {
    setState(() {
      _isLoading = true;
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading &&
        controller.position.pixels == controller.position.maxScrollExtent) {
      setState(() => _isLoading = true);
      _getData();
    }
  }

  navigateToReviewPage(context, timestamp, name) {
    nextScreenPopuup(
      context,
      CommentsPage(
        collectionName: collectionName,
        timestamp: timestamp,
        title: name,
      ),
    );
  }

  handleDelete(timestamp) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          elevation: 0,
          children: <Widget>[
            Text('Delete?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Want to delete this item from the database?',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('Yes', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await ab.deleteContent(timestamp, collectionName);
                    ab.decreaseCount('places_count');
                    refreshData();
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('No', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  openFeaturedDialog(String timestamp) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          elevation: 0,
          children: <Widget>[
            Text('Add to Featured',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Do you want to add this item to the featured list?',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('Yes', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await ab.addToFeaturedList(context, timestamp);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('No', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
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
        Text('Places',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
            onRefresh: () async => refreshData(),
            child: ListView.builder(
              controller: controller,
              padding: EdgeInsets.symmetric(vertical: 20),
              itemCount: _data.length + 1,
              itemBuilder: (context, index) {
                if (index < _data.length) {
                  return dataList(_data[index]);
                }
                return Center(
                  child: Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget dataList(Place d) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      height: 165,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomCacheImage(imageUrl: d.imageUrl1, radius: 10),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(LineIcons.mapMarker, size: 15, color: Colors.grey),
                    SizedBox(width: 3),
                    Text(d.location, style: TextStyle(fontSize: 12)),
                    SizedBox(width: 10),
                    Icon(Icons.access_time, size: 15, color: Colors.grey),
                    SizedBox(width: 3),
                    Text(d.date, style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      height: 35,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.grey),
                          Text('${d.loves}',
                              style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Colors.grey[800]),
                      onPressed: () => nextScreen(context, UpdatePlace(placeData: d)),
                    ),
                    IconButton(
                      icon: Icon(Icons.comment, size: 20, color: Colors.grey),
                      onPressed: () => navigateToReviewPage(context, d.timestamp, d.name),
                    ),
                    IconButton(
                      icon: Icon(Icons.featured_play_list_outlined,
                          size: 20, color: Colors.purple),
                      onPressed: () => openFeaturedDialog(d.timestamp),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => handleDelete(d.timestamp),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
