import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_game/game_square.dart';
import 'package:flutter_game/game_level.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'date_format.dart';
import 'game_document.dart';

// Types of images available
enum ImageType {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
  facingDown,
  flagged,
  tools,
}

class GameMainPage extends StatefulWidget {
  final String uaid;
  GameMainPage({Key key,this.uaid}):super(key:key);
  @override
  _GameMainPageState createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  // Row and column count of the board
  int _rowCount = 4;
  int _columnCount = 4;
  int _minRowCount = 3;
  int _minColumnCount = 3;

  int _baseRowCount = 1;
  int _baseColumnCount = 1;
  // The grid of squares
  List<List<GameSquare>> board;
  static const platform = const MethodChannel('flutter.io/ad_game');
  static const BasicMessageChannel<String> platformMessage = BasicMessageChannel<String>('flutter.io/ad_game', StringCodec());

  // "Opened" refers to being clicked already
  List<bool> openedSquares;
  List<bool> useTools;

  // A flagged square is a square a user has added a flag on by long pressing
  List<bool> flaggedSquares;

  // Probability that a square will be a bomb
  int bombProbability = 3;
  int maxProbability = 15;
  int squareCount = 16;
  int bombCount = 0;
  int squaresLeft;
  int _state = 0;//0loading,1play,2fail,3success
//  Map<int,Image>  successImages;
//  Map<int,Image>  failImages;

  UserGameLevel _userGameLevel;
  SharedPreferences prefs;

  Future<Null> _refreshAd() async {
    new Future.delayed(const Duration(seconds: 1),(){platform.invokeMethod('refreshAd');});
  }

  Future<Null> _toShare(int level) async {
    print("syfleveltoast$level");
    final int result = await platform.invokeMethod("toShare$level");
    print("syfshareresult$result");
    if(result==200){
      _handleShareSuccess();
    }
    _refreshAd();
  }

  void _handleShareSuccess() {
    setState(() {
      if(_userGameLevel.shareCount<_userGameLevel.mostshareCount&&(_userGameLevel.leftCount<=0||_userGameLevel.shareCount>0)) {
        _userGameLevel.setShareCountUp();
        print("sharecount${_userGameLevel.shareCount}:leftcount${_userGameLevel.leftCount}");
        _userGameLevel.setLeftCountUp();
      }
    });
  }

  void _initUserLevel(int level,int leftcount,int shareCount,int adClickCount,String lastDate,int reward,int tools){
    print("uaid${widget.uaid}");
    _userGameLevel = new UserGameLevel(user:widget.uaid,level:level,
        leftCount: leftcount,shareCount: shareCount,
        adClickCount: adClickCount,lastDate: lastDate,reward: reward,tools: tools);
    print("syf${_userGameLevel.level}");
    _columnCount = _minColumnCount + _userGameLevel.level*_baseColumnCount;
    _rowCount = _minRowCount + _userGameLevel.level*_baseRowCount;
  }
  void _initData(){
    _state =0;
    _getPrefs();
    List temp = new List();
    for(int i = 0;i<9;i++){
      temp.add(i);
    }
//    successImages = {0:Image.asset('images/0.png'),
//      1:Image.asset('images/1.png'),
//      2:Image.asset('images/2.png'),
//      3:Image.asset('images/3.png'),
//      4:Image.asset('images/4.png'),
//      5:Image.asset('images/5.png')};
//
//    failImages = {0:Image.asset('images/0.png'),
//      1:Image.asset('images/6.png'),
//      2:Image.asset('images/1.png'),
//      3:Image.asset('images/2.png'),
//      4:Image.asset('images/3.png'),
//      5:Image.asset('images/4.png'),
//      6:Image.asset('images/5.png')};
  }

  void _getPrefs() async{
    prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      if (_needRefresh) {
        _needRefresh = false;
        setState(() {
          print("syf11111111");
          _state = 1;
          _handleUser();
          _initialiseGame();
        });
      } else {
        _state = 1;
        _handleUser();
        _initialiseGame();
      }
    }else{
      _state = 1;
      _initUserLevel(1,
          6,0,0,DateFormat.formatDate(new DateTime.now(), [DateFormat.yyyy, '-', DateFormat.mm, '-', DateFormat.dd]),0,1);
      _initialiseGame();
    }
  }

  _handleUser(){
    String old = prefs.getString("lastDate${widget.uaid}");
    String today = DateFormat.formatDate(new DateTime.now(), [DateFormat.yyyy, '-', DateFormat.mm, '-', DateFormat.dd]);
    if(old==today) {
      _initUserLevel(prefs.getInt("level${widget.uaid}"),
          prefs.getInt("leftCount${widget.uaid}"), prefs.getInt("shareCount${widget.uaid}"), prefs.getInt("adClickCount${widget.uaid}"), today,prefs.getInt("reward${widget.uaid}"), prefs.getInt("tools${widget.uaid}"));
    }else{
      _initUserLevel(prefs.getInt("level${widget.uaid}"),
          6, 0, 0, today,prefs.getInt("reward${widget.uaid}"),prefs.getInt("tools${widget.uaid}"));
    }
  }
  @override
  void initState() {
    super.initState();
//    init((value){
//      print("syfmessage$value");
//      if("ad_click"==value){
//        setState(() {
//          _handleAdClick();
//        });
//      }
//    }, (){
//
//    });
    platformMessage.setMessageHandler((message){
      print("syfmessage$message");
      if("ad_click"==message){
        setState(() {
          _handleAdClick();
        });
      }else if("document_back"==message){
        Navigator.of(context).pop();
      }else if("share_success"==message){
        _handleShareSuccess();
      }else if("game_destroy" == message){
        _handleDistroy();
      }
    });
    _initData();
  }

  void _handleAdClick() {
    if(_userGameLevel.adClickCount<_userGameLevel.mostAdClickCount&&((_userGameLevel.leftCount<=0&&_userGameLevel.shareCount==3)||_userGameLevel.adClickCount>0)) {
      _userGameLevel.setAdClickCountUp();
      _userGameLevel.setLeftCountUp();
    }
  }

  void _changeLevel(){
    _userGameLevel.setLevelUp();
    _columnCount = _minColumnCount + _userGameLevel.level * _baseColumnCount;
    _rowCount = _minRowCount + _userGameLevel.level * _baseRowCount;
  }

  void _changeCount(){
    if(squareCount-squaresLeft>3){
      print("syfsquareleftcout$squaresLeft");
      if(_userGameLevel.leftCount>0)_userGameLevel.setLeftCountDown();
    }
    _tapCount = 0;
  }
  void _changeState(bool success){
    _refreshAd();
    setState(() {
      if(success) {
        _changeLevel();
      }
      _changeCount();
    });
  }


  void _backward(){
    _refreshAd();
    setState(() {
      _userGameLevel.setLevel(1);
      _columnCount = _minColumnCount + _userGameLevel.level * _baseColumnCount;
      _rowCount = _minRowCount + _userGameLevel.level * _baseRowCount;
      _changeCount();
    });
  }


//  Map<int,Image> _getAnimationImages(){
//    if(_state==2){
//      return failImages;
//    }else{
//      return successImages;
//    }
//  }
  int _tapCount = 0;
  Widget _handleTimes(){
    return new GridView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount,
      ),
      itemCount: squareCount,
      itemBuilder: (context, position) {
        // Get row and column number of square
        int rowNumber = (position / _columnCount).floor();
        int columnNumber = (position % _columnCount);

        Image image;
//        if( _state==3&&bombCount==0&&squaresLeft>0){
//          if (!flaggedSquares[position]&&!openedSquares[position]) {
//            if (board[rowNumber][columnNumber].hasBomb) {
//              image = getImage(ImageType.bomb);
//            } else {
//              image = getImage(getImageTypeFromNumber(
//                  board[rowNumber][columnNumber].bombsAround
//              ),);
//            }
//          }
//        }
          if (openedSquares[position] == false) {
            if(useTools[position] == true){
              image = getImage(ImageType.tools);
            }else if (flaggedSquares[position] == true) {
              image = getImage(ImageType.flagged);
            } else if(_state==3){
              image = getImage(getImageTypeFromNumber(
                  board[rowNumber][columnNumber].bombsAround
              ),);
            }else{
              image = getImage(ImageType.facingDown);
            }
          } else {
            if (board[rowNumber][columnNumber].hasBomb) {
              image = getImage(ImageType.bomb);
            } else {
              image = getImage(
                getImageTypeFromNumber(
                    board[rowNumber][columnNumber].bombsAround
                ),
              );
            }
          }
//        }
        return new InkWell(
          // Opens square
          onTap: () {
            if(_state==2){
              _handleFailTools();
            }else if(_state==3){
              _showWinDialog();
            }else if(_userGameLevel.leftCount<=0){
              _handleShare();
            }else if(_state!=1){
              return;
            }else {
              if(flaggedSquares[position]) {
                setState(() {
                    if (board[rowNumber][columnNumber].hasBomb) {
                      bombCount++;
                    }
                    flaggedSquares[position] = false;
                });
              }else if(!useTools[position]){
                _tapCount++;
                if (board[rowNumber][columnNumber].hasBomb) {
                  print("syfbombsquarelfet$squaresLeft");
                  _failPosition = position;
                  failColumn = columnNumber;
                  failRow = rowNumber;
                  _handleGameOver();
                  setState(() {
                    openedSquares[position] = true;
                    squaresLeft = squaresLeft - 1;
                  });
                }else if (board[rowNumber][columnNumber].bombsAround == 0) {
                  _handleTap(rowNumber, columnNumber);
                } else {
                  setState(() {
                    openedSquares[position] = true;
                    squaresLeft = squaresLeft - 1;
                  });
                }
                print("syfbombcountout$bombCount squaresleft$squaresLeft");

                if (bombCount==0) {
                  print("syfbombcountin$bombCount");
                  _handleWin();
                }
              }
            }

          },
          // Flags square
          onLongPress: () {
            if(_state==2){
              _handleFailTools();
            }else if(_state==3){
              _showWinDialog();
            } else if(_userGameLevel.leftCount<=0){
              _handleShare();
            }else if(_state!=1){
              return;
            }else {
              if (openedSquares[position] == false&&!useTools[position]) {
                setState(() {
                  if(!flaggedSquares[position]) {
                    squaresLeft--;
                    if (board[rowNumber][columnNumber].hasBomb) {
                      bombCount--;
                    }
                    flaggedSquares[position] = true;
                  }else{
                    squaresLeft++;
                    if (board[rowNumber][columnNumber].hasBomb) {
                      bombCount++;
                    }
                    flaggedSquares[position] = false;
                  }
                });
                if (bombCount==0) {
                  print("syfbombcountin$bombCount");
                  _handleWin();
                }
              }
            }
          },
          splashColor: Color(0xFFEFF6FC),
          child: new Container(
            color: Color(0xFFEFF6FC),
            child: image,
          ),
        );
      },
    );
  }
  // Initialises all lists
  void _initialiseGame() {
    _state = 1;
    // Initialise all squares to having no bombs
    board = List.generate(_rowCount, (i) {
      return List.generate(_columnCount, (j) {
        return new GameSquare();
      });
    });

    squareCount = _rowCount * _columnCount;
    // Initialise list to store which squares have been opened
    openedSquares = List.generate(squareCount, (i) {
      return false;
    });

    flaggedSquares = List.generate(squareCount, (i) {
      return false;
    });

    useTools = List.generate(squareCount, (i) {
      return false;
    });


    // Resets bomb count
    squaresLeft = squareCount;
    
    _initBomb();

    // Check bombs around and assign numbers
    for (int i = 0; i < _rowCount; i++) {
      for (int j = 0; j < _columnCount; j++) {
        if (i > 0 && j > 0) {
          if (board[i - 1][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0) {
          if (board[i - 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0 && j < _columnCount - 1) {
          if (board[i - 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j > 0) {
          if (board[i][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j < _columnCount - 1) {
          if (board[i][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < _rowCount - 1 && j > 0) {
          if (board[i + 1][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < _rowCount - 1) {
          if (board[i + 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < _rowCount - 1 && j < _columnCount - 1) {
          if (board[i + 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }
      }
    }

    setState(() {});
  }

  void _initBomb() {
    maxProbability = squareCount;

    int maxBombCount = (maxProbability/5).ceil();
    int minBombCount = (maxProbability/8).ceil();;
    bombCount = 0;
    Random random = new Random();

    bombProbability = minBombCount-1+random.nextInt(maxBombCount-minBombCount+1);
    // Randomly generate bombs
    for (int i = 0; i < _rowCount; i++) {
      for (int j = 0; j < _columnCount; j++) {
        int randomNumber = random.nextInt(maxProbability);
        if (randomNumber < bombProbability) {
          board[i][j].hasBomb = true;
          bombCount++;
          if(bombCount>=maxBombCount)return;
        }
      }
    }
    if (bombCount < minBombCount) {
      for(int i = 0;i<=minBombCount;i++) {
        int row = random.nextInt(_rowCount);
        int column = random.nextInt(_rowCount);
        if(!board[row][column].hasBomb){
          board[row][column].hasBomb = true;
          bombCount++;
          if(bombCount>=maxBombCount)return;
        }
      }
    }
  }

  // This function opens other squares around the target square which don't have any bombs around them.
  // We use a recursive function which stops at squares which have a non zero number of bombs around them.
  void _handleTap(int i, int j) {

    int position = (i * _columnCount) + j;
    openedSquares[position] = true;
    squaresLeft = squaresLeft - 1;

    if (i > 0) {
      if (!board[i - 1][j].hasBomb &&
          openedSquares[((i - 1) * _columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i - 1, j);
        }
      }
    }

    if (j > 0) {
      if (!board[i][j - 1].hasBomb &&
          openedSquares[(i * _columnCount) + j - 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j - 1);
        }
      }
    }

    if (j < _columnCount - 1) {
      if (!board[i][j + 1].hasBomb &&
          openedSquares[(i * _columnCount) + j + 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j + 1);
        }
      }
    }

    if (i < _rowCount - 1) {
      if (!board[i + 1][j].hasBomb &&
          openedSquares[((i + 1) * _columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i + 1, j);
        }
      }
    }

    setState(() {});
  }
  Text _handleFailMessage(){
    String plus;
    print("syfsquareleft$squaresLeft");
    if(squareCount-squaresLeft<=3) {
      plus = "三格以内，不扣体力~";
    }else{
      plus = "";
    }
    if(_userGameLevel.level<2){
      return new Text("哎呀，你被淅沥沥的小雨淋到啦！$plus",style: _getBlueCommonTextStyle(16),);
    }else if(_userGameLevel.level<5){
      return new Text("哎呀，连绵细雨落到了你身上！$plus",style: _getBlueCommonTextStyle(16));
    }else {
      return new Text("哎呀，你被倾盆大雨淋个正着！$plus",style: _getBlueCommonTextStyle(16));
    }
//    return new Text("哎呀，你被淋到啦！$plus",style: _getBlueCommonTextStyle(16));
    }
    int _failPosition;
  int failColumn;
  int failRow;
  // Function to handle when a bomb is clicked.
  void _handleGameOver() {
    print("syfhandlegameover");
    setState(() {
      _state = 2;
    });
    _handleFailTools();
  }

  void _handleFailTools(){
    if(_userGameLevel.tools>0) {
      _showToolsDialog();
    }else {
      _showFailDialog();
    }
  }
  void _showToolsDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(

          title: Text("下雨啦!",style: _getBlueCommonTextStyle(22),),
          content: new Text("是否要使用道具伞复活？tips:若翻开三格以内，重新玩也不消耗体力",style: _getBlueCommonTextStyle(16),),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                _refreshAd();
                Navigator.pop(context);
                setState(() {
                  _userGameLevel.setToolsDown();
                  _state = 1;
                  bombCount--;
                  if(bombCount==0)_handleWin();
                  openedSquares[_failPosition] = false;
                  useTools[_failPosition] = true;
                });
              },
              child: new Text("撑伞！",style: _getBlueCommonTextStyle(16),),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.pop(context);
                _showFailDialog();
              },
              child: new Text("留待下次！",style: _getBlueCommonTextStyle(16),),
            ),
          ],
        );
      },
    ).then((value){

    });
  }

void _showFailDialog(){
  showDialog(
    context: context,
    builder: (context) {
      return new AlertDialog(

        title: Text("下雨啦!",style: _getBlueCommonTextStyle(22),),
        content: _handleFailMessage(),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _changeState(false);
              _initialiseGame();
              Navigator.pop(context);
            },
            child: new Text("衣服拧干，再来一次！",style: _getBlueCommonTextStyle(16),),
          ),
        ],
      );
    },
  ).then((value){

  });
}

TextStyle _getBlueCommonTextStyle(double textSize){
  return TextStyle(
    color: Color(0xFF1565C0),
    fontSize:textSize,
  );
}

  TextStyle _geTextStyle(double textSize,Color color){
    return TextStyle(
      color: color,
      fontSize:textSize,
    );
  }
  void _handleWin() {
    print("syfhandlewin");
    setState(() {
      _userGameLevel.setToolsAddCount(1);
      _userGameLevel.setRewardAddCount(_userGameLevel.level);
      _state = 3;
    });
    _showWinDialog();
  }
  void _showWinDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("晴天啦!",style: _getBlueCommonTextStyle(22)),
          content: new Text("实力运气兼备，前方晴空万里~tips:送你一把小伞，以备不时之需",style: _getBlueCommonTextStyle(16)),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                _changeState(true);
                _initialiseGame();
                Navigator.pop(context);
              },
              child: new Text(_userGameLevel.level==7?"重玩本关":"升级啦",style: _getBlueCommonTextStyle(16)),
            ),
            new Visibility(
              visible: _userGameLevel.level==7,
                child: new FlatButton(
                  onPressed: () {
                    _backward();
                    _initialiseGame();
                    Navigator.pop(context);
                  },
                  child: new Text("退回第一关",style: _getBlueCommonTextStyle(16)),
                ),)
          ],
        );
      },
    ).then((value){
    });
  }
  void _handleShare() {
    showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("体力耗尽了呢!",style: _getBlueCommonTextStyle(22)),
          content: new Text(_userGameLevel.shareCount<3?"体力已耗尽，分享可以获得额外体力呦~":_userGameLevel.adClickCount<7?"""体力已耗尽，点击广告可以获得额外体力呦~tips:如果已经关闭了广告，就只能等到等到明天啦。""":"体力已耗尽，明天再来玩吧~",style: _getBlueCommonTextStyle(16)),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                print("syfinsharecont${_userGameLevel.shareCount}");
                if(_userGameLevel.shareCount<3){
                  _toShare(_userGameLevel.level);
                }
                Navigator.pop(context);
              },
              child: new Text(_userGameLevel.shareCount<3?"去分享":"确定",style: _getBlueCommonTextStyle(16)),
            ),
          ],
        );
      },
    );
  }
  Image getImage(ImageType type) {
    switch (type) {
      case ImageType.zero:
        return Image.asset('images/0.png');
      case ImageType.one:
        return Image.asset('images/1.png');
      case ImageType.two:
        return Image.asset('images/2.png');
      case ImageType.three:
        return Image.asset('images/3.png');
      case ImageType.four:
        return Image.asset('images/4.png');
      case ImageType.five:
        return Image.asset('images/5.png');
      case ImageType.six:
        return Image.asset('images/6.png');
      case ImageType.seven:
        return Image.asset('images/7.png');
      case ImageType.eight:
        return Image.asset('images/8.png');
      case ImageType.bomb:
        return Image.asset('images/bomb.png');
      case ImageType.facingDown:
        return Image.asset('images/facingDown.png');
      case ImageType.flagged:
        return Image.asset('images/flagged.png');
      case ImageType.tools:
        return Image.asset('images/flaggedold.png');
      default:
        return null;
    }
  }

  ImageType getImageTypeFromNumber(int number) {
    switch (number) {
      case 0:
        return ImageType.zero;
      case 1:
        return ImageType.one;
      case 2:
        return ImageType.two;
      case 3:
        return ImageType.three;
      case 4:
        return ImageType.four;
      case 5:
        return ImageType.five;
      case 6:
        return ImageType.six;
      case 7:
        return ImageType.seven;
      case 8:
        return ImageType.eight;
      default:
        return null;
    }
  }
    bool _needRefresh = false;
    Widget _getMainWidget(){
      if(_state==0){
        _needRefresh =true;
        return new Container(
          decoration: new BoxDecoration(color:Color(0xFF1976D2)),
          alignment: Alignment.center,
          child: new Text("游戏马上开始~",style:_geTextStyle(26,Colors.white)),
        );
      }else{
        _needRefresh = false;
        return new Scaffold(
          backgroundColor: Color(0xFF1976D2),
          body: new Stack(
            children: <Widget>[
              new ListView(
                children: <Widget>[
                  new Container(
                    color: Colors.transparent,
                    height: 60.0,
                    width: double.infinity,
                    margin: new EdgeInsets.only(left:10,right: 10),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(child: new Text(
                            "关卡 ${_userGameLevel.level}  ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:22,
                            )
                        )),
                        new Container(
                          width: 26,
                          height: 26,
                          child: new Image.asset('images/w1.png'),
                        ),


                        new Text("体力:${_userGameLevel.leftCount}  ",style: _geTextStyle(16, Colors.white)),

                         new Container(
                                width: 26,
                                height: 26,
                                child: new Image.asset('images/w0.png'),
                              ),

                           new Text("奖励:${_userGameLevel.reward}  ",style: _geTextStyle(16, Colors.white),),
                          new Container(
                          width: 26,
                          height: 26,
                          child: new Image.asset('images/tools.png'),
                        ),

                        new Text("道具:${_userGameLevel.tools}",style: _geTextStyle(16, Colors.white),)
                      ],
                    ),
//                    new Row(
//                      //              mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        new IconButton(icon:new Icon(Icons.receipt,color: Colors.white,semanticLabel: "游戏规则"), onPressed:(){
//                          _pushSaved();
//                        }),
////                        new Icon(Icons.receipt,color: Colors.white,semanticLabel: "规则说明",),
//                        new Expanded(
//                          child: new Center(
//                            child: new InkWell(
//                              onTap: () {
//                                _changeState(false);
//                                _initialiseGame();
//                              },
//                              child:new Container(
//                                margin: new EdgeInsets.only(left:20),
//                                child:new Text("")
//                              ),
//                          )
//                        ),
//                        ),
//                        new Text("还有${_userGameLevel.leftCount}次机会",style: TextStyle(
//                          color: Colors.white,
//                          fontSize:12,
//                        )),
//                      ],
//                    ),
                  ),
                  // The grid of squares
                  _handleTimes(),

                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
//                      new InkWell(
//                        onTap: (){
//                          _refreshAd();
//                          _initialiseGame();
//                        },
//                        child: new Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            new Icon(Icons.refresh,color: Colors.white,semanticLabel: "重玩"),
//                            new Text("重玩",style: _geTextStyle(18, Colors.white),)
//                          ],
//                        ),
//                      ),
                      new InkWell(
                        onTap: (){
                          _refreshAd();
                          _initialiseGame();
                        },
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              width: 26,
                              height: 26,
                              child: new Image.asset('images/refresh1.png'),
                            ),
//                            new Icon(Icons.question_answer,color: Colors.white,semanticLabel: "重玩"),
                            new Text("重玩  ",style: _geTextStyle(18, Colors.white),)
                          ],
                        ),
                      ),
                      new InkWell(
                        onTap: (){
                          _pushSaved();
                        },
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              width: 26,
                              height: 26,
                              child: new Image.asset('images/idea1.png'),
                            ),
//                            new Icon(Icons.receipt,color: Colors.white,semanticLabel: "帮助"),
                            new Text("帮助",style: _geTextStyle(18, Colors.white),)
                          ],
                        ),
                      ),
                    ],
//                    new IconButton(icon: Icons.refresh, onPressed: null)
                  )
                ],
              ),
//              new Center(
//                child: new Visibility(
//                  child: new ImagesAnim(
//                      _getAnimationImages(), 100, 150, Colors.transparent),
//                  visible: _state != 1,
//                ),
//              )
            ],
          ),
//      body: new ListView(
//        children: <Widget>[
//          new Container(
//            color: Colors.grey,
//            height: 60.0,
//            width: double.infinity,
//            child: new Row(
////              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                new Icon(Icons.receipt),
//                new Expanded(
//                  child: new InkWell(
//                    onTap: () {
//                      _changeState(false);
//                      _initialiseGame();
//                    },
//                    child: new Text(
//                      "Level $_userGameLevel.level",
//                      style: Theme.of(context).textTheme.title,
//                    ),
//                  ),
//                ),
//                new Text("剩余可玩次数：$_userGameLevel.leftCount"),
//              ],
//            ),
//          ),
//          // The grid of squares
//          _handleTimes(),
//        ],
//      ),
        );
      }
    }
    @override
    Widget build(BuildContext context) {

      return _getMainWidget();
    }
  void _pushSaved(){
      platform.invokeMethod("setTitleName","游戏规则");
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context){
        return new Document();
      },
      ),
    );
  }
//  static const channelName = 'flutter.io/ad_game';
//
//    static const EventChannel eventChannel = EventChannel(channelName);
//
//  StreamSubscription _subcription = null;
//
//  void init(void onEvent(String value),Function onError){
//    if(_subcription == null) {
//      _subcription = eventChannel.receiveBroadcastStream().listen(onEvent,onError: onError);
//    }
//  }
//

  void _handleDistroy(){
    print("syfdipose");
    if(_userGameLevel!=null) {
      print("syfnotnull$_state");
      if (_state == 3||(_state==2&&squareCount-squaresLeft>3)) {
        print("syfcountdown${_userGameLevel.leftCount}");
        _userGameLevel.setLeftCountDown();
      }
      if (_state == 3&&_userGameLevel.level<7) {
        print("syflevelup${_userGameLevel.level}");
        _userGameLevel.setLevelUp();
      }
    }
  }
  @override
  void dispose(){
    super.dispose();
  }
}
