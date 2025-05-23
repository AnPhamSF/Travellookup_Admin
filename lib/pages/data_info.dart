import '/blocs/admin_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataInfoPage extends StatefulWidget {
  const DataInfoPage({Key? key}) : super(key: key);

  @override
  _DataInfoPageState createState() => _DataInfoPageState();
}

class _DataInfoPageState extends State<DataInfoPage> {

  late Future users;
  late Future places;
  late Future blogs;
  late Future notifications;
  late Future states;

  @override
  void initState() {
    super.initState();
    users = context.read<AdminBloc>().getTotalDocuments('users_count');
    places = context.read<AdminBloc>().getTotalDocuments('places_count');
    blogs = context.read<AdminBloc>().getTotalDocuments('blogs_count');
    notifications = context.read<AdminBloc>().getTotalDocuments('notifications_count');
    states = context.read<AdminBloc>().getTotalDocuments('states_count');
  }



  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05, top: w * 0.05),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              FutureBuilder(
                future: users,
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('TỔNG USERS', 0);
                  if (snap.hasError) return card('TỔNG USERS', 0);
                  return card('TỔNG USERS', snap.data);
                },
              ),
              const SizedBox(
                width: 20,
              ),
              FutureBuilder(
                future: places,
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('TỔNG ĐỊA ĐIỂM', 0);
                  if (snap.hasError) return card('TỔNG ĐỊA ĐIỂM', 0);
                  return card('TỔNG ĐỊA ĐIỂM', snap.data);
                },
              ),
              const SizedBox(
                width: 20,
              ),
              FutureBuilder(
                future: blogs,
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('TỔNG BLOGS', 0);
                  if (snap.hasError) return card('TỔNG BLOGS', 0);
                  return card('TỔNG BLOGS', snap.data);
                },
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: notifications,
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('TỔNG THÔNG BÁO', 0);
                  if (snap.hasError) return card('TỔNG THÔNG BÁO', 0);
                  return card('TỔNG THÔNG BÁO', snap.data);
                },
              ),

              const SizedBox(
                width: 20,
              ),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('featured').doc('featured_list').snapshots(),
                builder: (context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('ĐỊA ĐIỂM NỔI BẬT', 0);
                  if (snap.hasError) return card('ĐỊA ĐIỂM NỔI BẬT', 0);
                  return card(
                      'ĐỊA ĐIỂM NỔI BẬT', snap.data['places'].length);
                },
              ),


              const SizedBox(
                width: 20,
              ),
              FutureBuilder(
                future: states,
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (!snap.hasData) return card('TỔNG TỈNH/THÀNH PHỐ', 0);
                  if (snap.hasError) return card('TỔNG TỈNH/THÀNH PHỐ', 0);
                  return card('TỔNG TỈNH/THÀNH PHỐ', snap.data);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget card(String title, int number) {
    return Container(
      padding: const EdgeInsets.all(30),
      height: 180,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Colors.grey, blurRadius: 10, offset: Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            height: 2,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(15)),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              const Icon(
                Icons.trending_up,
                size: 40,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                number.toString(),
                style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              )
            ],
          )
        ],
      ),
    );
  }
}
