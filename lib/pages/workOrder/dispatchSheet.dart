// 工单派单
import 'package:flutter/material.dart';
import '../../services/pageHttpInterface/MyTask.dart';
import '../../utils/util.dart';
// 组件
import '../../components/ListBarComponents.dart';
import '../../components/ButtonsComponents.dart';
import './view/MultipleRowTexts.dart';
import '../../components/SplitLine.dart';
import '../../components/NoteEntry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

// eventBus 
import '../../utils/eventBus.dart';
import '../../config/serviceUrl.dart';

// 列表页的页面
import 'package:app_tims_hotel/pages/workOrder/workOrderList.dart';

// 退单原因、挂起原因
import './view/repairReason.dart';
// 抄送人
import 'view/copierItem.dart';

class DispatchSheet extends StatefulWidget {
  DispatchSheet({
    Key key, 
    this.orderID,
    this.isJPush = false
  }) : super(key: key);

  final orderID;
  final bool isJPush;
  @override
  _DispatchSheet createState() => _DispatchSheet();
}

class _DispatchSheet extends State<DispatchSheet> {
  List roleData = []; //角色列表
  var userId; //用户id
  int taskId; //工单id
  Map pageData = {//页面数据
    'areaName': '', //地点
    'taskContent': '', // 内容
    'addTime': '', //时间
    'priority': 0, // 优先级
    'taskPhotograph': -1, // 拍照需求
    'sendUserName': '', // 报修人 名字
    'sendUserPhone':'', // 电话号码
    'sendUserId': 0, // 报修人id
    'ID': 0, // 工单id
    'hangInfo': ""   // 挂起原因
  };
  // 处理后照片
  dynamic picList = [];
  // 处理前照片
  dynamic picListBefore = [];

  String info; // 备注

    // 默认 无权限
  bool admin = false; //管理员
  bool repair = true; // 报修
  bool keepInRepair = false; //维修
  List copierList = []; // 抄送人员列表
  @override
  void initState(){
    super.initState();
    initAuth();
    taskId = (widget.orderID is int) ? widget.orderID : int.parse(widget.orderID);
    getLocalStorage('userId').then((data){
      userId = (data is int) ? data : int.parse(data);
      getInitData();
    });
  }

  // 初始化权限
  initAuth() async{
    Map auth = await getAllAuths();
    setState(() {
      admin = auth['admin'];
      repair = auth['repair'];
      keepInRepair = auth['keepInRepair'];
    });
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
        dynamic _TpicList = [];
        dynamic _TpicListBefore = [];
        if(data["mainInfo"]["taskPictureInfo"]["afterProcessing"] is List ) {
          _TpicList = data["mainInfo"]["taskPictureInfo"]["afterProcessing"].
          map((each) => serviceUrl+each['picUrl'].toString());
        }

        if(data["mainInfo"]["taskPictureInfo"]["beforeProcessing"] is List ) {
          _TpicListBefore = data["mainInfo"]["taskPictureInfo"]["beforeProcessing"].
          map((each) => serviceUrl+each['picUrl'].toString());
        }

        setState(() {
          picListBefore = _TpicListBefore.toList();
          pageData = data['mainInfo'];
        });
      }
    });
    // 角色列表
    getRoleList().then((data){
      if(data is List){
        setState(() {
          roleData = data;
        });
      }
    });
  }
  // 更多列表弹出
  void pageMoreModalList(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        var _adapt = SelfAdapt.init(context);
        return Container(
              height: _adapt.setHeight(220),
              child: Column(
                children: <Widget>[
                  Container(
                    height: _adapt.setHeight(46),
                    padding: EdgeInsets.only(left: _adapt.setWidth(0), right: _adapt.setWidth(40)),
                    color: Color.fromRGBO(0,20,37,1),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: _adapt.setWidth(40),
                          child: FlatButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text('更多', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: _adapt.setFontSize(16))),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: _adapt.setHeight(22)),
                      color: Color.fromRGBO(0, 20, 37, 1),
                      child: Column(
                        children: <Widget>[
                            Container(
                              height: _adapt.setHeight(44),
                              margin: EdgeInsets.only(top: _adapt.setHeight(8), bottom: _adapt.setHeight(8), left: _adapt.setWidth(15), right: _adapt.setWidth(15)),
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(113, 166, 241, 1),
                                borderRadius: new BorderRadius.all(new Radius.circular(5)),
                              ),
                              child: ListTile(
                                  title: Text( '无法处理', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>  RepairReason(
                                        orderID: taskId,
                                        optionType: 8,
                                      )
                                    ));
                                  }
                                )
                            ),
                            Container(
                              height: _adapt.setHeight(44),
                              margin: EdgeInsets.only(top: _adapt.setHeight(7), bottom: _adapt.setHeight(8), left: _adapt.setWidth(15), right: _adapt.setWidth(15)),
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(113, 166, 241, 1),
                                borderRadius: new BorderRadius.all(new Radius.circular(5)),
                              ),
                              child: ListTile(
                                  title: Text( '挂起', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>  RepairReason(
                                        orderID: taskId,
                                        optionType: 9,
                                      )
                                    ));
                                  }
                                )
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
          );
      }
    );
  }
  // 列表弹出组件方法
  void pageModalBottomSheet(){
    var _adapt = SelfAdapt.init(context);
    if (roleData.length  > 0) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: _adapt.setHeight(46),
                    padding: EdgeInsets.only(left: _adapt.setWidth(0), right: _adapt.setWidth(40)),
                    color: Color.fromRGBO(0,20,37,1),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: _adapt.setWidth(40),
                          child: FlatButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text('请选择派发岗位', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: _adapt.setFontSize(16)),),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: moreFillData(roleData, dispatchSheet, context)
                      ).toList()
                    ),
                  )
                ],
              ),
          );
        }
      );
    }else{
      showTotast('未获取到角色列表！');
    }
  }
  /* 派单
   * @param status: 1 指派给我， 2 指派给别人
   * @param optionType: 工单处理类型 0 指派给自己 1 指派给别人 2处理完成 3申请退单 4 同意退单 5 拒绝退单 6 验收通过 7 验收不通过 8无法处理 9挂起
   */
  void dispatchSheet({int roleId, optionType: int}){
    int taskId = pageData['ID'];
    Map params = {
      'now_userId': userId, //用户id
      'id': taskId, //工单id
      "info": info,
    };
    if (roleId != null && optionType != null) { // 指派给别人
      params['optionType'] = optionType;
      params['roleId'] = roleId; //新的处理角色
    } else if (roleId == null && optionType != null) { // 无法处理 - 挂起 - 指派给自己
      params['optionType'] = optionType;
    }
    // 抄送人
    params['copyUser'] = copierList;
    // 派单
    getdispatchSheet(params).then((data) async{
      if(data is bool && data == false){
        return;
      }
      bus.emit("refreshTask");
      if (optionType == 0) {  //派给自己
        if (!widget.isJPush) { //如果是推送进来的详情页，就不需要返回上一页
          Navigator.pop(context);
        }
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context){
          return WorkOrderList(workOrderType: '1', userID: userId);
        }));
      } else if (optionType == 1) { // 指派给别人
          Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    });
  }

  // 回调函数获得选中的抄送人ID
  void _getCopierID(List _copierList) {
    dynamic tempList = _copierList.map((e) => e["userID"]);
    setState(() {
      copierList = tempList.toList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 判断 优先级
    int priority = pageData['priority'];
    String priorityName = priority == 3 ? '高' : priority == 2 ? '中' : priority == 1 ? '低' : '';
    // 判断是否拍照
    int taskPhoto = pageData['taskPhotograph'];
    String taskPhotoName = taskPhoto == 1 ? '拍照' : taskPhoto == 0 ? '不拍照' : '';
    // 工单号-- 工单id
    int taskId = pageData['ID'];
    //报修人
    String reporter = pageData['sendUserName'];
    if(pageData['sendDepartment'] != null){
      String sendDepartment = pageData['sendDepartment'];
      reporter = reporter + ' ($sendDepartment)';
    } 
    // 设置 设计图和设备的 宽高比例
    var _adapt = SelfAdapt.init(context);
    
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
          actions: <Widget>[
            Offstage(
              offstage: !admin,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: _adapt.setWidth(15)),
                height: 30,
                child: Container(
                  child: GestureDetector(
                    onTap: (){
                      pageMoreModalList();
                    },
                    child: Text('更多',style: TextStyle(color: Color.fromRGBO(90, 166, 255, 1))),
                  )
                )
              )
            ),
          ],
          backgroundColor: Colors.transparent
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                  // padding: EdgeInsets.ronly(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, //居左
                  children: <Widget>[
                    Container( //报修人/抄送人/处理岗位/处理人
                      child: Column(children: <Widget>[
                        ListBarComponents(name: '地点', value: pageData['taskType'] == 3 ? "暂无" : pageData['areaName'] == "" || pageData['areaName'] == null ? "巡检工单" : pageData['areaName']),
                        SplitLine(),
                        ListBarComponents(name: '时间', value: pageData['addTime']),
                        SplitLine(),
                        Offstage(
                          offstage: reporter == '' || reporter == null,
                          child: ListBarComponents(name: '报修人', value: reporter, ishidePhone: false, tel: pageData['sendUserPhone']),
                        ),
                        SplitLine(),
                        ListBarComponents(name: '优先级', value: priorityName),
                        SplitLine(),
                      ]),
                      height: _adapt.setHeight(190),
                      width: double.infinity,
                      color: module_background_color,
                      padding: EdgeInsets.only(left: _adapt.setWidth(15.0)),
                      margin: EdgeInsets.only(top: _adapt.setHeight(8.0)),
                    ),
                    // 抄送人
                    CopierItem(clickCB: _getCopierID),
                    MultipleRowTexts(name:'内容', value: pageData['taskContent']),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text('拍照需求', textAlign: TextAlign.left, style: TextStyle(color: white_name_color)),
                            flex: 1,
                          ),
                          Expanded(
                            child: Text(taskPhotoName,  textAlign: TextAlign.right, style: TextStyle(color: white_color)),
                            flex: 1,
                          ),
                        ]
                      ),
                      padding: EdgeInsets.only(left: _adapt.setWidth(15), right: _adapt.setWidth(15)),
                      margin: EdgeInsets.only(top: _adapt.setHeight(8)),
                      color: module_background_color,
                      width: double.infinity,
                      height: _adapt.setHeight(45),
                    ),
                    Offstage(
                      offstage: picListBefore.length == 0,
                      child: Container(
                        padding: EdgeInsets.all(_adapt.setWidth(15)),
                        child: Text('现场照片', style: TextStyle(color:Colors.white)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: boxs(picListBefore ,picListBefore.length),
                      ),
                      margin: EdgeInsets.fromLTRB(
                        0.0,
                        ScreenUtil.getInstance().setHeight(20),
                        0.0,
                        ScreenUtil.getInstance().setHeight(20)
                      ),
                    ),
                    NoteEntry(change: (value){ //备注
                      setState(() {
                        info = value;
                      });
                    }),
                    // 重修(重修的时候才会有)
                    Offstage(
                      offstage: pageData["hangInfo"] == "" || pageData["hangInfo"] == null,
                      child: Container(
                        margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(22)),
                        color: Color.fromARGB(100, 12, 33, 53),
                        height: ScreenUtil.getInstance().setHeight(220),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(20)),
                              alignment: Alignment.centerLeft,
                              child: Text('挂起原因',style: TextStyle(fontSize: 15.0,color: Colors.white70)),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(20)),
                              width: ScreenUtil.getInstance().setWidth(690),
                              child: Text(pageData["hangInfo"] == null? "" : pageData['hangInfo'], maxLines: 5,style: TextStyle(fontSize: 15.0,color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Text('工单号: ' + (taskId > 0 ? taskId : '').toString(), style: TextStyle(color: white_name_color)),
                      margin: EdgeInsets.only(top: _adapt.setHeight(19), bottom: _adapt.setHeight(20)),
                      padding: EdgeInsets.only(left: _adapt.setWidth(15)),
                    )
                ]
              )
              )
            ),
            ButtonsComponents(leftShow: admin, rightShow: keepInRepair,  leftName: '派给别人', rightName: '派给我' ,cbackLeft: pageModalBottomSheet, cbackRight: (){dispatchSheet(optionType: 0);})
          ],
        )
      ),
    );
  }
}

List<Widget> boxs(_picList,length) => List.generate(length, (index) {
  return Container(
    width: ScreenUtil.getInstance().setWidth(180),
    height: ScreenUtil.getInstance().setHeight(135),
    alignment: Alignment.center,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        imageUrl: _picList[index],
        width: ScreenUtil.getInstance().setWidth(340),
        height: ScreenUtil.getInstance().setHeight(255),
        fit: BoxFit.cover,
      )
    )
  );
});

  // 遍历 数据，填充  --更多列表
List<Widget> moreFillData(data, cback, context){
    List<Widget> list = [];//先建一个数组用于存放循环生成的widget
    for(var item in data){
      String str = item['flag'] == 1 ? '（无人在岗）' : '';
      Color color = item['flag'] == 0 ? Color.fromRGBO(173, 216, 255, 1) : Color.fromRGBO(151, 151, 151, 1);
      list.add(
        Container(
          child: Container(
            child: ListTile(
              selected: true,
              enabled: item['flag'] == 0 ? true : false,
              title: Text( item['roleName'] + str, textAlign: TextAlign.center, style: TextStyle(color: color),),
              onTap: () async {
                cback(roleId: item['roleId'], optionType: 1 ); //指派方法
                Navigator.pop(context);
            })
          )
        ),
      );
    }
    return list;
}