![](http://pic1.win4000.com/wallpaper/2020-07-30/5f2238e33e3c4.jpg)

在《[APP 开发从 0 到 1（三）布局与 ListView](https://mp.weixin.qq.com/s/Bia6VzhLJmOTq3qYDsX_Ag)》我们完成了 ListView，这篇文章将做 ListView 下拉加载和加载更多。

## ListView 下拉加载

Flutter 提供了 RefreshIndicator 下拉刷新组件，可以轻松让我们实现 Material Design 风格的下拉刷新效果。

### 参数详解

```dart
 //下拉刷新组件
 const RefreshIndicator
    ({
    Key key,
    @required this.child,
    this.displacement: 40.0, //触发下拉刷新的距离
    @required this.onRefresh, //下拉回调方法,方法需要有async和await关键字，没有await，刷新图标立马消失，没有async，刷新图标不会消失
    this.color, //进度指示器前景色，默认为系统主题色
    this.backgroundColor, //背景色
    this.notificationPredicate: defaultScrollNotificationPredicate,
    })
```

### 效果预览

![](https://mmbiz.qlogo.cn/mmbiz_gif/Jkr8IKxMfUdyyGDAR9gLuNNWwiblskILemuicvpIhZdX9jShMoibeLpticNGAFbe6JbEToibuJibptMxPJ8AqSbFleWw/0?wx_fmt=gif)

### 完整代码

废话不多说，直接上完整代码，你可细品下哦。

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListViewPage extends StatefulWidget {
  @override
  ListViewPageState createState() => new ListViewPageState();
}

class ListViewPageState extends State<ListViewPage> {
  List list = new List(); //列表要展示的数据

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AndBlog'),
      ),
      body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(list[index]),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.account_box),
        onPressed: () {
          print("FloatingActionButton");
        },
        elevation: 30,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        list = List.generate(20, (i) => '哈喽，我是下拉刷新的数据 $i');
      });
    });
  }

  Future getData() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        list = List.generate(30, (i) => '哈喽，我是原始数据 $i');
      });
    });
  }
}

```

## ListView 加载更多

Flutter 没有直接提供加载更多组件，但我们可以在 ListView 监听 ScrollController，判断是否滑到底，然后加载下一页。

### 效果预览

![](https://mmbiz.qpic.cn/mmbiz_gif/Jkr8IKxMfUdyyGDAR9gLuNNWwiblskILedlPvGVBX80uP9zfbXWHcflsTGFSKIfghkDVSwjbyGWmO0MD3zcGpibg/0?wx_fmt=gif)

### 完整代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_andblog/andblog/common/color_common.dart';
import 'package:flutter_andblog/andblog/common/http_common.dart';
import 'package:flutter_andblog/andblog/detail/blog_detail_page.dart';
import 'package:http/http.dart' as http;
import 'blog.dart';

class BlogListPage extends StatefulWidget {
  @override
  BlogListPageState createState() => new BlogListPageState();
}

class BlogListPageState extends State<BlogListPage> {
  List<Blog> _blogList = [];
  String loadMoreText = "正在加载中...";
  TextStyle loadMoreTextStyle =
      new TextStyle(color: const Color(0xFF4483f6), fontSize: 14.0);
  ScrollController scrollController = new ScrollController();
  var hasData = true;
  var page = 0;

  @override
  void initState() {
    super.initState();
    //一进页面就请求接口
    _getBlogListData();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        //已经滑到底了
        if (hasData) {
          //还有数据，加载下一页
          setState(() {
            loadMoreText = "正在加载中...";
            loadMoreTextStyle =
                new TextStyle(color: const Color(0xFF4483f6), fontSize: 14.0);
          });
          page++;
          print("page=" + page.toString());
          _getBlogListData();
        } else {
          setState(() {
            loadMoreText = "没有更多数据";
            loadMoreTextStyle =
                new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  //网络请求
  Future _getBlogListData() async {
    //一页加载8条数据，skip为跳过的数据，比如加载第二页（page=1），skip跳过前8条数据，即显示第9-16条数据
    var skip = page * 8;
    print("blog_list_url=" + HttpCommon.blog_list_url + skip.toString());
    var response = await http.get(HttpCommon.blog_list_url + skip.toString(),
        headers: HttpCommon.headers());
    if (response.statusCode == 200) {
      // setState 相当于 runOnUiThread
      setState(() {
        var data = Blog.decodeData(response.body);
        if (data.length < 8) {
          //某页数据小于8，表明没有下一页了
          hasData = false;
        } else {
          hasData = true;
        }
        _blogList.addAll(data);
        print("_blogList.length0=" + _blogList.length.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var content;

    if (_blogList.length == 0) {
      content = new Center(
        // 可选参数 child:
        child: new CircularProgressIndicator(),
      );
    } else {
      content = _contentList();
    }

    return Scaffold(
      backgroundColor: ColorCommon.backgroundColor,
      appBar: AppBar(
        title: Text('AndBlog'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.account_box),
        onPressed: () {
          print("FloatingActionButton");
        },
        elevation: 30,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _contentList() {
    print("_blogList.length=" + _blogList.length.toString());
    return new RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: _blogList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _blogList.length) {
              return _buildProgressMoreIndicator();
            } else {
              return _blogItem(index);
            }
          },
          controller: scrollController,
        ));
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      print('refresh');
      setState(() {
        page = 0;
        _blogList.clear();
        _getBlogListData();
      });
    });
  }

  Widget _buildProgressMoreIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(15.0),
      child: new Center(
        child: new Text(loadMoreText, style: loadMoreTextStyle),
      ),
    );
  }

  Widget _blogItem(int index) {
    Blog blog = _blogList[index];
    var date = new Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 10.0,
          right: 10.0,
        ),
        child: new Text(
          blog.date,
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorCommon.dateColor, fontSize: 18),
        ));

    var cover = new Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 10.0,
          right: 10.0,
        ),
        child: new ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
            child: new Image.network(
              'http://pic1.win4000.com/wallpaper/2020-04-21/5e9e676001e20.jpg',
            )));

    var title = new Text(
      blog.title,
      style: TextStyle(color: ColorCommon.titleColor, fontSize: 22),
    );

    var summary = new Padding(
        padding: const EdgeInsets.only(
          top: 5.0,
        ),
        child: new Text(blog.summary,
            textAlign: TextAlign.left,
            style: TextStyle(color: ColorCommon.summaryColor, fontSize: 18)));

    var titleSummary = new Container(
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.topLeft,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0)),
        shape: BoxShape.rectangle,
      ),
      margin: const EdgeInsets.only(left: 10, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[title, summary],
      ),
    );

    var blogItem = new GestureDetector(
      //点击事件
      onTap: () => navigateToMovieDetailPage(blog.objectId, index),

      child: new Column(
        children: <Widget>[
          date,
          cover,
          titleSummary,
        ],
      ),
    );

    return blogItem;
  }

  // 跳转页面
  navigateToMovieDetailPage(String blogId, Object imageTag) {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new BlogDetailPage(blogId, imageTag: imageTag);
    }));
  }
}

```
