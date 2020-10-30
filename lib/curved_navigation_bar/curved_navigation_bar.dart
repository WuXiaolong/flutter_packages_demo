import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CurvedNavigationBarPage extends StatefulWidget {
  @override
  CurvedNavigationBarState createState() => new CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBarPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List colors = [Colors.blueAccent, Colors.pinkAccent, Colors.orangeAccent];

  int currentIndex = 0;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(() {
        setState(() {
          currentIndex = _tabController.index;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: colors[currentIndex],
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
        ],
        onTap: (index) {
          //Handle button tap
          print("index==" + index.toString());
          setState(() {
            currentIndex = index;
          });
          _tabController.animateTo(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Container(
            color: colors[0],
          ),
          Container(
            color: colors[1],
          ),
          Container(
            color: colors[2],
          )
        ],
      ),
    );
  }
}
