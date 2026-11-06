package substates.backend.CustomFadeTransition;
var Ftext;
if (this.get("previousLoadingScreen")==null) var previousLoadingScreen;
function onSubstateCreate(ss) {
    if (previousLoadingScreen!=null&&Type.getClassName(Type.getClass(FlxG.state))!="states.LoadingState"){

        previousLoadingScreen = new FlxSprite(0, 0, previousLoadingScreen);
        previousLoadingScreen.setGraphicSize(FlxG.width,FlxG.height);
        previousLoadingScreen.updateHitbox();
        ss.add(previousLoadingScreen);
        FlxTween.tween(previousLoadingScreen,{alpha:0},duration);
        transGradient.visible = false;
        transBlack.visible = false;
        //FlxG.sound.play(Paths.sound('snd_ominous'), 1);
    }else if(!isTransIn){
        Ftext = new FlxText(20,FlxG.height-30,80,"Loading...");
        Ftext.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]]; 
        Ftext.camera = FlxG.cameras.list[FlxG.cameras.list.length-1]; 
        ss.add(Ftext);
    }
    
}
function onSubstateDestroy(ss) {
    if (previousLoadingScreen!=null&&Type.getClassName(Type.getClass(FlxG.state))!="states.LoadingState"){
        previousLoadingScreen.destroy();
        previousLoadingScreen = null;
        setGlobalVar('previousLoadingScreen',null);
        //FlxG.sound.play(Paths.sound('snd_ominoushell'), 1);
    }
    //Ftext?.destoy();
}
function onDestroy() {
    onSubstateDestroy(null);
}