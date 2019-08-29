import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pageHttpInterface/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/util.dart';
import '../utils/jPush.dart';
import 'package:flutter/cupertino.dart';

class Test extends StatefulWidget {
  Test({Key key}) : super(key: key);

  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  var leftRightPadding = 30.0;
  var topBottomPadding = 4.0;
  var textTips = new TextStyle(fontSize: 16.0, color: Colors.white);
  var hintTips = new TextStyle(fontSize: 16.0, color: Colors.blue);
  static const LOGO = "assets/images/LOGO.png";

  var _userPassController = new TextEditingController();
  var _userNameController = new TextEditingController();
  var jpush = new Jpush.init();

  @override initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height; 
    Map userInfo = {
      'authMenus': [],
      'userName': '',
      'userId': '',
      'postId': '',
      'postName': '',
      'departmentId': '',
      'departmentName': '',
      'phoneNum': '',
    };
    print('width is $width; height is $height');
    void loginSubmit() async{
      var data = {
        "empAcct": _userNameController.text,
        "empPwd": _userPassController.text
      };
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userLogin(data).then((val) {   
        print('00000000000000000000000'); 
        print(val);
        print(val['code']);
        if (val['code'] == 2000) {
          preferences.setString('token', val['datas']['token'].toString()); // 把token存在本地
          getAuth(val['datas']['token'].toString(),val['datas']['details']['sessionId'].toString()).then((va) {
            // 设置别名
            jpush.setAlias(va['user']['user_id']);
            // 设置标签
            jpush.setTags(va['user']['post_id']);

            preferences.setString('authMenus', va['menus'].toString());
            preferences.setString('userName', va['user']['user_name'].toString());
            preferences.setString('userId', va['user']['user_id'].toString());
            preferences.setString('postName', va['user']['post_name'].toString());
            preferences.setString('departmentName', va['user']['department_name'].toString());
            preferences.setString('phoneNum', va['user']['phone_no'].toString());
            setState(() {
              userInfo['authMenus'] = va['menus'];
              userInfo['userName'] = va['user']['user_name'];
              userInfo['userId'] = va['user']['user_id'];
              userInfo['postId'] = va['user']['post_id'];
              userInfo['postName'] = va['user']['post_name'];
              userInfo['departmentId'] = va['user']['department_id'];
              userInfo['departmentName'] = va['user']['department_name'];
              userInfo['phoneNum'] = va['user']['phone_no'];
            });
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => new MyApp(
              )
            ));
          });
        } else {
          print('-------------');
          showTotast(val['error']);
        }
      });
    }
    return new Container(
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover
          )
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 50.0, leftRightPadding, 10.0),
                  child: new Image.asset(LOGO),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 50.0, leftRightPadding, topBottomPadding),
                  child: new TextField(
                    style: hintTips,
                    controller: _userNameController,
                    decoration: new InputDecoration(
                      hintText: "请输入用户名",
                      hintStyle: new TextStyle(fontSize: 16.0, color: Colors.white),
                      prefixIcon: new Icon(Icons.people,color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF637EA5), 
                          width: 1, 
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                        color: Color(0xFF637EA5), 
                        width: 1, 
                      )),
                    ),
                    obscureText: false,
                    // inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.phone
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(
                      leftRightPadding, 30.0, leftRightPadding, topBottomPadding),
                  child: new TextField(
                    style: hintTips,
                    controller: _userPassController,
                    decoration: new InputDecoration(
                      hintText: "请输入用户密码",
                      hintStyle: new TextStyle(fontSize: 16.0, color: Colors.white),
                      prefixIcon: new Icon(Icons.people,color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF637EA5), //边线颜色为黄色
                          width: 1, //边线宽度为2
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                        color: Color(0xFF637EA5), //边框颜色为绿色
                        width: 1, //宽度为2
                      )),
                    ),
                    obscureText: true,
                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))],
                  ),
                ),
                new Container(
                  width: width,
                  margin: new EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
                  padding: new EdgeInsets.fromLTRB(80.0,
                      topBottomPadding, leftRightPadding, topBottomPadding),
                  child: GestureDetector(
                    child: new Text(
                      '忘记密码?',
                      style: new TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    onTap: () {
                      // print('我太难了');
                      showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text('提示'),
                          content: Text('请联系物业管理员进行密码重置',style: TextStyle(fontSize: 14),),
                          actions: <Widget>[
                            CupertinoButton(
                              child: Text("取消"),
                              onPressed: () {
                                Navigator.pop(_);
                              },
                            ),
                            CupertinoButton(
                              child: Text("确定"),
                              onPressed: () {
                                Navigator.pop(_);
                              },
                            ),
                          ],
                        )
                      );
                    },
                  ),
                ),
                new Container(
                  width: width,
                  margin: new EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
                  padding: new EdgeInsets.fromLTRB(leftRightPadding,
                      topBottomPadding, leftRightPadding, topBottomPadding),
                  child: new Card(
                    color: Colors.blue,
                    elevation: 6.0,
                    child: new FlatButton(
                        onPressed: loginSubmit,
                        child: new Padding(
                          padding: new EdgeInsets.all(10.0),
                          child: new Text(
                            '登录',
                            style:
                                new TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        )),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))
                        )
                  ),
                )
              ],
            ),
          ),
          resizeToAvoidBottomPadding: false
        )
      );
  }
}