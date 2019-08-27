// 工单验收
import 'package:flutter/material.dart';
import '../../services/pageHttpInterface/MyTask.dart';
import '../../utils/util.dart';

// 组件
import './view/ListBarComponents.dart';
import './view/ButtonsComponents.dart';
import './view/MultipleRowTexts.dart';
import './view/ImageList.dart';
import './view/SplitLine.dart';

class WorkOrderAccept extends StatefulWidget {
  WorkOrderAccept({Key key}) : super(key: key);
  @override
  _WorkOrderAccept createState() => _WorkOrderAccept();
}
class _WorkOrderAccept extends State<WorkOrderAccept> {
  int userId = 5; //用户id
  int taskId = 16; //工单id
  List pictureList = []; //图片列表
  Map pageData = {//页面数据
    'areaName': '', //地点
    'taskContent': '', // 内容
    'addTime': '', //时间
    'priority': 0, // 优先级
    'sendUserName': '', // 报修人 名字
    'sendUserPhone':'', // 保修人电话号码
    'handleUserPhone': '', //处理人电话
    'sendUserId': 0, // 报修人id
    'ID': -1, // 工单id
    'copyUserList': []
  };
  @override
  void initState(){
    super.initState();
    getInitData();
  }
  // 初始化 获取数据
  void getInitData(){
    var data = {
      'userId': userId, //用户id
      'taskId': taskId, //工单id
    };
    // 工单信息
    getWorkOrderDetail(data).then((data){
      if(data is Map){
        setState(() {
          pageData = data['mainInfo'];
          pictureList = data['taskPictureInfo'];
          // pictureList.add('https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566874617&di=77c418982a0db28f45ad9ace05aaaf02&imgtype=jpg&er=1&src=http%3A%2F%2Fimages6.fanpop.com%2Fimage%2Fphotos%2F32600000%2FFluttershy-my-little-pony-friendship-is-magic-32605128-993-805.jpg');
          // pictureList.add('https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566874617&di=77c418982a0db28f45ad9ace05aaaf02&imgtype=jpg&er=1&src=http%3A%2F%2Fimages6.fanpop.com%2Fimage%2Fphotos%2F32600000%2FFluttershy-my-little-pony-friendship-is-magic-32605128-993-805.jpg');
          // pictureList.add('https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566874617&di=77c418982a0db28f45ad9ace05aaaf02&imgtype=jpg&er=1&src=http%3A%2F%2Fimages6.fanpop.com%2Fimage%2Fphotos%2F32600000%2FFluttershy-my-little-pony-friendship-is-magic-32605128-993-805.jpg');
          // pictureList.add('https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566874617&di=77c418982a0db28f45ad9ace05aaaf02&imgtype=jpg&er=1&src=http%3A%2F%2Fimages6.fanpop.com%2Fimage%2Fphotos%2F32600000%2FFluttershy-my-little-pony-friendship-is-magic-32605128-993-805.jpg');
        });
      }
    });
  }
  /* 处理
   * @param optionType: 工单处理类型 0 指派给自己 1 指派给别人 2处理完成 3申请退单 4 同意退单 5 拒绝退单 6 验收通过 7 验收不通过 8无法处理 9挂起
   */
  void dispatchSheet({ optionType: int}){
    int taskId = pageData['ID'];
    Map params = {
      'now_userId': userId, //用户id
      'id': taskId, //工单id
    };
    params['optionType'] = optionType;
    // 处理
    getdispatchSheet(params).then((data){
       Navigator.pop(context);
      // if (optionType == 0) {  //派给自己
      //     // Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context){
      //     //   return MyOrder();
      //     // }));
      //     Navigator.pop(context);
      // }
      // if (optionType == 1) { // 指派给别人
      //     Navigator.pop(context);
      //     // Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context){
      //     //   return NewWorkOrder();
      //     // }));
      // }
    });
  }
  @override
  Widget build(BuildContext context) {
    var _adapt =  SelfAdapt.init(context);
    // 判断 优先级
    int priority = pageData['priority'];
    String priorityName =  priority == 3 ? '优先级高' : priority == 2 ? '优先级中' : priority == 1 ? '优先级低' : '';
    // 工单号-- 工单id
    int taskId = pageData['ID'];
    return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover
              )
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('工单内容',style: TextStyle(fontSize: _adapt.setFontSize(18))),
                centerTitle: true,
                backgroundColor: Colors.transparent
              ),
              body: SingleChildScrollView(
                      // padding: EdgeInsets.ronly(bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, //居左
                        children: <Widget>[
                          Container( //标签按钮
                            child: Container(
                              child:Center(
                                child:Text( priorityName, style:TextStyle(color: white_color))
                              ),
                              width: _adapt.setWidth(96),
                              height: _adapt.setHeight(30),
                              decoration: new BoxDecoration(
                                border: new Border.all(width: _adapt.setWidth(1), color: Color.fromRGBO(239, 111, 111, 1)),
                                color: Color.fromRGBO(239, 111, 111, 0.18),
                                borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                              )
                            ),
                            margin: EdgeInsets.only(left: _adapt.setWidth(15), right: _adapt.setWidth(15), top: _adapt.setHeight(15), bottom: _adapt.setHeight(15)),
                          ),
                          Container( //地点/时间
                            child: Column(children: <Widget>[
                              ListBarComponents(name:'地点', value: pageData['areaName']),
                              SplitLine(), 
                              ListBarComponents(name:'时间', value: pageData['addTime']),
                            ]),
                            height: _adapt.setHeight(91),
                            width: double.infinity,
                            color: module_background_color,
                            padding: EdgeInsets.only(left: _adapt.setWidth(15)),
                          ),
                          Container( //报修人/抄送人/处理岗位/处理人
                            child: Column(children: <Widget>[
                              ListBarComponents(name:'报修人', value: pageData['sendUserName'], ishidePhone: false, tel: pageData['sendUserPhone']),
                              SplitLine(),
                              ListBarComponents(name:'抄送人', value: pageData['copyUserList'].join(',')),
                              SplitLine(), 
                              ListBarComponents(name:'处理岗位', value: pageData['handleRoleName']),
                              SplitLine(), 
                              ListBarComponents(name:'处理人', value: pageData['handleUserName'], ishidePhone: false, tel: pageData['handleUserPhone']),
                            ]),
                            height: _adapt.setHeight(183),
                            width: double.infinity,
                            color: module_background_color,
                            padding: EdgeInsets.only(left: _adapt.setWidth(15.0)),
                            margin: EdgeInsets.only(top: _adapt.setHeight(8.0)),
                          ),
                          MultipleRowTexts(name:'内容', value: pageData['taskContent']),
                          // Container(
                          //   child: Row(children: <Widget>[
                          //     Expanded(
                          //       child: Text('完成时限', textAlign: TextAlign.left, style: TextStyle(color: Color.fromRGBO(8, 219, 202, 1))),
                          //       flex: 1,
                          //     ),
                          //     Expanded(
                          //       child: Text('5日',  textAlign: TextAlign.right, style: TextStyle(color: Color.fromRGBO(8, 219, 202, 1))),
                          //       flex: 1,
                          //     ),
                          //   ]),
                          //   padding: EdgeInsets.only(left: _adapt.setWidth(15), right: _adapt.setWidth(15)),
                          //   margin: EdgeInsets.only(top: _adapt.setHeight(8)),
                          //   color: _Module_background_color,
                          //   width: double.infinity,
                          //   height: _adapt.setHeight(45),
                          // ),
                          Offstage(
                            offstage:  pictureList.length > 0 ? false : true,
                            child: ImageList(data: pictureList),
                          ),
                          Container(
                            child: Text('工单号: $taskId', style: TextStyle(color: white_name_color)),
                            margin: EdgeInsets.only(top: _adapt.setHeight(19)),
                            padding: EdgeInsets.only(left: _adapt.setWidth(15)),
                          ),
                          ButtonsComponents(leftName: '重修',rightName: '通过', cbackLeft: (){dispatchSheet(optionType: 7);}, cbackRight: (){dispatchSheet(optionType: 6);},)
                      ]
                    )
                  )
          )
        );
  }
}