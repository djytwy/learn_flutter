import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/workOrder/detailWorkOrder.dart';  // 工单详情页面
import '../pages/workOrder/dispatchSheet.dart';
import '../pages/workOrder/workOrderContent.dart';
import '../pages/workOrder/workOrderAccept.dart';
import '../pages/workOrder/chargeback.dart';
import '../utils/util.dart';
import '../services/pageHttpInterface/comWorkOrder.dart';      // 红点未读相关

/*
  列表页跳转详情对应关系：
  '0' (新工单) : DispatchSheet(orderID:widget.orderID) 
  '1' (我的工单):(context) => WorkOrderContent(orderID:widget.orderID) 
  '2' (我的报修): (context) => WorkOrderAccept(orderID:widget.orderID) 
  '3' (退单处理): (context) => Chargeback(orderID: widget.orderID)
  '4' (挂起): (context) => DispatchSheet(orderID:widget.orderID) 
*/

class WorkOrderItem extends StatefulWidget {
  WorkOrderItem({
    Key key, 
    this.waringMsg, 
    this.content,
    this.fontSize,
    this.status,
    this.time,
    this.place,
    this.orderID,
    this.workOrderType,
    this.statusCallBack,
    this.msgID,
    this.redPoint=false,
    this.isSkip=true,
    this.showExtime=true
    }) : super(key: key);

  String waringMsg;         // 传入组件的紧急程度（高、中、低）
  String time;              // 传入组件的时间
  String status;            // 传入组件的状态信息（工单列表相关界面用：处理中、挂起、已完成等状态字）
  String content;           // 传入组件的文本内容
  String place;             // 传入组件的地点信息
  double fontSize;          // 传入组件的字体大小
  final orderID;           // 工单的ID
  bool redPoint;           // 是否红点推送
  final workOrderType;      // 工单类型： 0 新工单 1 我的工单 2 我的报修 3退单处理 4 挂起 其他的：进入工单详情
  final statusCallBack;     // 组件的回调函数，返回？信息
  final msgID;              // 消息的ID
  final showExtime;          // 工单详情页是否显示完成时限

  final bool isSkip;        // 是否跳转页面，默认跳转
  _WorkOrderItemState createState() => _WorkOrderItemState();
}

class _WorkOrderItemState extends State<WorkOrderItem> {

  bool _redPoint = true;
  @override
  void initState() {
    _redPoint = widget.redPoint;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.workOrderType);
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
    return Container(
      margin: EdgeInsets.fromLTRB(
        ScreenUtil.getInstance().setHeight(16),
        ScreenUtil.getInstance().setHeight(16),
        ScreenUtil.getInstance().setHeight(16),
        ScreenUtil.getInstance().setHeight(16)
      ),
      padding:EdgeInsets.all(ScreenUtil.getInstance().setHeight(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: Color.fromARGB(100, 12, 33, 53),
        boxShadow: [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 5.0
          )
        ]
      ),
      width: ScreenUtil.getInstance().setWidth(690),
      height: ScreenUtil.getInstance().setHeight(274),
      child: GestureDetector(
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(30)),
                    alignment: Alignment.topLeft,
                    child: widget.waringMsg == '高'? Text(widget.waringMsg, style: TextStyle(color: Colors.redAccent)) : 
                      widget.waringMsg == '中'? Text(widget.waringMsg, style: TextStyle(color: Colors.yellowAccent)):
                      Text(widget.waringMsg, style: TextStyle(color: Colors.greenAccent)),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Offstage(
                        // offstage: !widget.redPoint,
                        offstage: !_redPoint,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ) 
                    ),
                  )
                ],
              )
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(15)), 
                    alignment: Alignment.centerLeft,
                    child: Text(widget.time, textAlign: TextAlign.left ,style: TextStyle(color: Colors.white70, fontSize: widget.fontSize)),
                  ),
                  Expanded(
                    child: Text(widget.status, textAlign: TextAlign.right,style: TextStyle(color: Colors.greenAccent,fontSize: widget.fontSize))  
                  )
                ] 
              )
            ),
            Container(
              margin: EdgeInsets.only(right: ScreenUtil.getInstance().setWidth(14)),
              child: Center(
                child: Text(widget.content, style: TextStyle(color: Colors.white70,fontSize: widget.fontSize)),
              )
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(24)),
              alignment: Alignment.centerLeft,
              child: Text(widget.place, style: TextStyle(color: Colors.white,fontSize: widget.fontSize)),
            ),
          ],
        ),
        onTap: () async {
          if(widget.redPoint && _redPoint) {
            setState(() {
              _redPoint = false;
            });
            await _changeMsgStatus();
          }
          if (widget.isSkip) {
            Navigator.push(context, MaterialPageRoute(
              builder: 
                widget.workOrderType.toString() == '0' ? (context) => DispatchSheet(orderID:widget.orderID) :
                widget.workOrderType.toString() == '1' ? (context) => WorkOrderContent(orderID:widget.orderID) : 
                widget.workOrderType.toString() == '2' ? (context) => WorkOrderAccept(orderID:widget.orderID) : 
                widget.workOrderType.toString() == '3' ? (context) => Chargeback(orderID: widget.orderID):
                widget.workOrderType.toString() == '4' ? (context) => DispatchSheet(orderID:widget.orderID) : 
                // 是否显示时限
                (context) => DetailWordOrder(orderID:widget.orderID, showExtime: widget.showExtime,)
            ));
          }
        },
      )
    );
  }

  void _statusCallBack() {
    widget.statusCallBack();
  }

  Future _changeMsgStatus() async {
    Map params = {
      "operFlag": "3",
      "msgId": widget.msgID 
    };
    if(widget.msgID != "" && widget.msgID != null ) 
      changeMsgStatus(params).then((val) {
        return true;
      });
    else
      return false;
  }

  // Future _changeMsgStatus() async {
  //   Map params = {
  //     "operFlag": "3",
  //     "msgId": widget.msgID
  //   };
  //   final reData = await changeMsgStatus(params);
  //   setState(() {
      
  //   });
  // }
}