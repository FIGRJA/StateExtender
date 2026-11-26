package substates.substates.PauseSubState;


import flixel.addons.transition.FlxTransitionableState;
import openfl.display.BitmapData;
function onUpdatePost(e) {
    if (controls.ACCEPT){
        //steps +=1;
        //close();
        if (PlayState.changedDifficulty||menuItems[curSelected] == "Restart Song"){
            trace("jii");
            PlayState.prevCamFollow = game.camFollow;
            //setGlobalVar("prewZoom",FlxG.camera.zoom)
            takeScreenHUD();
            //super.camera.visible = false;
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = false;
        }

    }
}
function takeScreenHUD() {
    var bit = new BitmapData(FlxG.width, FlxG.height, true, 0x00FFFFFF);
    for (i in 0...(FlxG.cameras.list.length-1)){
        if (i<=FlxG.cameras.list.indexOf(game.camGame)||FlxG.cameras.list[i]==super.camera) continue;
        bit.draw(FlxG.cameras.list[i].canvas);
    }
    //previousLoadingScreen = bit;
    setGlobalVar('previousLoadingScreen',bit);
    previousLoadingScreen = new FlxSprite(0, 0, bit.clone());
    previousLoadingScreen.setGraphicSize(FlxG.width,FlxG.height);
    previousLoadingScreen.updateHitbox();
    previousLoadingScreen.camera = game.camOther;
    game.add(previousLoadingScreen);
    takes=true;
}