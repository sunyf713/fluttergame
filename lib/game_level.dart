import 'package:shared_preferences/shared_preferences.dart';


class UserGameLevel {
  String user = "";
  int level = 1;
  int mostLevel = 7;
  int shareCount = 0;
  int mostshareCount = 3;
  int adClickCount = 0;
  int mostAdClickCount = 7;
  int leftCount = 6;
  int reward = 0;
  String lastDate = "";
  int tools = 1;
  UserGameLevel({String user,int level,int leftCount,int shareCount,int adClickCount,String lastDate,int reward,int tools}) {
    if(user.isNotEmpty)this.user = user;
    if(level!=null&&level!=0)this.level = level;
    if(leftCount!=null)this.leftCount = leftCount;
    if(shareCount!=null)this.shareCount = shareCount;
    if(adClickCount!=null)this.adClickCount = adClickCount;
    if(lastDate!=null){this.lastDate = lastDate;setLastDate(lastDate);}
    if(reward!=null)this.reward = reward;
    if(tools!=null)this.tools = tools;
  }

  void setLevel(int level){
    if(level==null||level==0)return;
    this.level = level;
    _syncPrefLevel(level);

  }

  Future _syncPrefLevel(int templevel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("level$user", templevel);
    }
  }

  Future _syncPrefLeftCount(int tempLeftCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("leftCount$user", tempLeftCount);
    }
  }
  void setLeftCount(int leftCount){
    if(leftCount==null)return;
    this.leftCount = leftCount;
    _syncPrefLeftCount(leftCount);
  }


  void setLevelUp(){
    if(level==7)return;
    level++;
    _syncPrefLevel(level);
  }

  void setLeftCountUp(){
    leftCount++;
    _syncPrefLeftCount(leftCount);
  }

  void setLeftCountDown(){
    if(leftCount==0)return;
    leftCount--;
    _syncPrefLeftCount(leftCount);
  }

  void setShareCount(int shareCount){
    if(shareCount==null||shareCount==0)return;
    this.shareCount = shareCount;
    _syncPrefShareCount(shareCount);

  }

  void setShareCountUp(){
    if(shareCount==3)return;
    shareCount++;
    _syncPrefShareCount(shareCount);
  }

  Future _syncPrefShareCount(int tempShareCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("shareCount$user", tempShareCount);
    }
  }

  void setAdClickCount(int adClickCount){
    if(adClickCount==null||adClickCount==0)return;
    this.adClickCount = adClickCount;
    _syncPrefAdClickCount(adClickCount);

  }

  void setAdClickCountUp(){
    if(adClickCount==7)return;
    adClickCount++;
    _syncPrefAdClickCount(adClickCount);
  }

  Future _syncPrefAdClickCount(int tempAdClickCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("adClickCount$user", tempAdClickCount);
    }
  }

  void setLastDate(String lastDate){
    if(lastDate==null||lastDate.isEmpty)return;
    this.lastDate = lastDate;
    _syncPrefLastDate(lastDate);

  }


  Future _syncPrefLastDate(String tempLastDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setString("lastDate$user", tempLastDate);
    }
  }


  void setReward(int reward){
    if(reward==null||reward==0)return;
    this.reward = reward;
    _syncPrefReward(reward);

  }

  Future _syncPrefReward(int tempreward) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("reward$user", tempreward);
    }
  }

  void setRewardAddCount(int addCount ){
    reward+=addCount;
    _syncPrefReward(reward);
  }


  void setTools(int tools){
    if(tools==null||tools==0)return;
    this.tools = tools;
    _syncPrefReward(tools);

  }

  Future _syncPrefTools(int temptools) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs!=null) {
      prefs.setInt("tools$user", temptools);
    }
  }

  void setToolsAddCount(int addCount ){
    tools+=addCount;
    _syncPrefTools(tools);
  }

  void setToolsDown(){
    if(tools==0)return;
    tools--;
    _syncPrefTools(tools);
  }

}
