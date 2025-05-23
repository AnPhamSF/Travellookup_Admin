import 'package:flutter/foundation.dart';

import '/blocs/admin_bloc.dart';
import '/config/config.dart';
import '/pages/admin.dart';
import '/pages/blogs.dart';
import '/pages/data_info.dart';
import '/pages/featured.dart';
import '/pages/notifications.dart';
import '/pages/places.dart';
//import '/pages/settings.dart';
import '/pages/sign_in.dart';
import '/pages/states.dart';
import '/pages/upload_blog.dart';
import '/pages/upload_place.dart';
import '/pages/users.dart';
import '/utils/next_screen.dart';
import '/widgets/cover_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vertical_tabs_flutter/vertical_tabs.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _pageIndex = 0;

  final List<String> titles = [
    'Tổng Quan',
    'Địa điểm',
    'Địa điểm nổi bật',
    'Tải lên địa điểm',
    'Blogs',
    'Tải lên Blog',
    'Tỉnh/Thành Phố',
    'Thông báo',
    'Users',
    'Admin',
    //'Settings'
  ];

  final List icons = [
    LineIcons.pieChart,
    LineIcons.mapMarker,
    LineIcons.bomb,
    LineIcons.arrowCircleUp,
    LineIcons.rocket,
    LineIcons.arrowCircleUp,
    LineIcons.mapPin,
    LineIcons.bell,
    LineIcons.users,
    LineIcons.userSecret,
    //LineIcons.chair
  ];

  Future handleLogOut() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp
        .clear()
        .then((value) => nextScreenCloseOthers(context, const SignInPage()));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      context.read<AdminBloc>().getStates();
      //context.read<AdminBloc>().getAdsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            height: 60,
            padding: const EdgeInsets.only(left: 20, right: 20),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey, blurRadius: 10, offset: Offset(0, 5))
                ]),
            child: Row(
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.deepPurpleAccent,
                            fontFamily: 'Muli'),
                        text: Config().appName,
                        children: <TextSpan>[
                      TextSpan(
                          text: ' - Admin Panel',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                              fontFamily: 'Muli'))
                    ])),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(2, 2))
                      ]),
                  child: TextButton.icon(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)))),
                    icon: const Icon(
                      LineIcons.alternateSignOut,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                    onPressed: () => handleLogOut(),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton.icon(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)))),
                    icon: Icon(
                      LineIcons.user,
                      color: Colors.grey[800],
                      size: 20,
                    ),
                    label: Text(
                      'Đăng nhập bằng ${ab.userType}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.deepPurpleAccent,
                          fontSize: 16),
                    ),
                    onPressed: () {

                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          )),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: VerticalTabs(
                  tabBackgroundColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  tabsElevation: 10,
                  tabsShadowColor: Colors.grey,
                  tabsWidth: 200,
                  indicatorColor: Colors.deepPurpleAccent,
                  selectedTabBackgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
                  indicatorWidth: 5,
                  disabledChangePageFromContentView: true,
                  initialIndex: _pageIndex,
                  
                  onSelect: (index){
                    _pageIndex = index;
                  },
                  tabs: <Tab>[
                    Tab(child: tab(titles[0], icons[0])),
                    Tab(child: tab(titles[1], icons[1])),
                    Tab(child: tab(titles[2], icons[2])),
                    Tab(child: tab(titles[3], icons[3])),
                    Tab(child: tab(titles[4], icons[4])),
                    Tab(child: tab(titles[5], icons[5])),
                    Tab(child: tab(titles[6], icons[6])),
                    Tab(child: tab(titles[7], icons[7])),
                    Tab(child: tab(titles[8], icons[8])),
                    Tab(child: tab(titles[9], icons[9])),
                    //Tab(child: tab(titles[10], icons[10])),
                  ],
                  contents: <Widget>[
                    const DataInfoPage(),
                    const CoverWidget(widget: PlacesPage()),
                    const CoverWidget(widget: FeaturedPlaces()),
                    CoverWidget(widget: UploadPlace()),
                    const CoverWidget(widget: BlogPage()),
                     CoverWidget(widget: UploadBlog()),
                     const CoverWidget(widget: States()),
                     const CoverWidget(widget: Notifications()),
                     const CoverWidget(widget: UsersPage()),
                    const CoverWidget(widget: AdminPage()),
                    //const CoverWidget(widget: Settings())
                    
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tab(title, icon) {
    return Tab(
        child: Container(
      padding: const EdgeInsets.only(
        left: 10,
      ),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 20,
            color: Colors.grey[800],
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[900],
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    ));
  }
}
