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
            //setGlobalVar("prewZoom",FlxG.camera.zoom);
            takeScreenHUD();
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = false;
        }

    }
}
function takeScreenHUD() {
    var bit = new BitmapData(FlxG.width, FlxG.height, true, 0x00FFFFFF);
    for (i in 0...(FlxG.cameras.list.length-1)){
        if (i<=FlxG.cameras.list.indexOf(game.camGame)) continue;
        bit.draw(FlxG.cameras.list[i].canvas);
    }
    previousLoadingScreen = bit;
    //previousLoadingScreen = new FlxSprite(0, 0, BitmapData.fromImage(FlxG.stage.window.readPixels()));
    //previousLoadingScreen.setGraphicSize(FlxG.width,FlxG.height);
    //previousLoadingScreen.updateHitbox();
    setGlobalVar('previousLoadingScreen',previousLoadingScreen);
    takes=true;
}