import 'package:flutter/material.dart';

class Document extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Color(0xFFEFF6FC),
      body: new ListView(

        children: <Widget>[
          new Text("""1、游戏玩法
点击一个方格，方格即被打开并显示出方格中的数字。
方格中数字则表示其周围的8个方格隐藏了几个雷雨。
长按格子是标记雨，找出所有有雨格子，即可过关；若踩到一个雨格子即全盘皆输。  

2、游戏等级
游戏共有7关，难度由简单到困难。
   Level 1  由4*4的格子组成，过关获得：小太阳+1;
   Level 2  由5*5的格子组成，过关奖励：小太阳+2;
   Level 3  由6*6的格子组成，过关奖励：小太阳+3;
   Level 4  由7*7的格子组成，过关奖励：小太阳+4;
   Level 5  由8*8的格子组成，过关奖励：小太阳+5;
   Level 6  由9*9的格子组成，过关奖励：小太阳+6; 
   Level 7  由10*10的格子组成，过关奖励：小太阳+7。

3、操作说明
翻格子：单击格子即被打开。
标记：长按格子，格子上会出现小旗icon，即为标记成功。
取消标记：单击或长按已标记的小旗格子，即可取消标记。

4、道具说明
"""),
new Row(children: <Widget>[
  new Container(
        width: 26,
        height: 26,
        child: new Image.asset('images/w1.png'),

    ),new Text("体力:")
],),
          new Text("每人每天默认拥有7个体力。每玩一局，消耗一个体力。重玩，不消耗体力。当体力用尽时，可通过分享游戏（上限3次）、点击广告（上限7次）的方式获得额外体力。当天所有体力耗尽后，需要第二天才能重新获得满格体力。"),

          new Row(children: <Widget>[
            new Container(
                width: 26,
                height: 26,
                child: new Image.asset('images/w0.png'),
              ),new Text("奖励小太阳:")
          ],),

new Text("游戏过关奖励。后期小太阳可兑换墨贝。兑换比例：1个太阳=10个墨贝。"),
          new Row(children: <Widget>[
            new Container(
              width: 26,
              height: 26,
              child: new Image.asset('images/tools.png'),

            ),new Text("道具小雨伞:")
          ],),
          new Text("""踩中下雨方块，道具伞可以复活，复活后可继续闯当前关卡
          
          
             
       """),

//体力：每人每天默认拥有7个体力。每玩一局，消耗一个体力。当体力用尽时，可通过分享游戏、观看广告的方式获得额外体力。当天所有体力耗尽后，需要第二天才能重新获得满格体力。
//小太阳：游戏过关奖励。后期小太阳可兑换墨贝。兑换比例：1个太阳=10个墨贝。
//
//
//
//
//
//      """),
        ],
      ),
    );
  }



}

