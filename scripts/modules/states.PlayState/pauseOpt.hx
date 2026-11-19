//package scripts.modules.states.PlayState;
//return//soon...
import flixel.addons.transition.FlxTransitionableState;
import options.GameplayChangersSubstate;
import backend.ClientPrefs;
import backend.MusicBeatState;
import substates.PauseSubState;
import Reflect;

function onCreate() {
    PGlistAction.insert(PGlistAction.indexOf("Debug"),"Options");
    
}
function onCreatePost() {
    if(this.get("prewZoom")!=null){
        //var z = super.defaultCamZoom;
        //super.camZooming = true;
        super.defaultCamZoom = prewZoom;
        camGame.zoom = prewZoom;
        prewZoom = null;
        setGlobalVar("prewZoom",null);
    }
}
var data = {};
var zoom;
function PGpressAccept(c) {
    if (c == "Options"){
		for (key in ClientPrefs.data.gameplaySettings.keys()){
            //trace(key);
			Reflect.setField(data, key, ClientPrefs.data.gameplaySettings.get(key));
        }
        //trace(data);
		StateHelper.closeCustomSubstate('GlobalPause');
		StateHelper.openCustomSubstate('options.GameplayChangersSubstate',true,super);
        zoom = FlxG.camera.zoom;
        openSubState(new GameplayChangersSubstate());
        FlxG.camera.zoom = zoom;
    }
        //debugPrint("cool...");
}
function onSubstateDestroy(ss) {
    if (Type.getClassName(Type.getClass(ss))!="options.GameplayChangersSubstate")return;
    var newData = false;
   // trace(ClientPrefs.data.gameplaySettings);
    for (key in ClientPrefs.data.gameplaySettings.keys()){
        //trace(key);
        newData = newData || (ClientPrefs.data.gameplaySettings.get(key) != Reflect.field(data, key));
        //if(newData) trace(key);
    }
	StateHelper.closeCustomSubstate('options.GameplayChangersSubstate');
	//StateHelper.closeCustomSubstate('GlobalPause');
    if (newData){
        trace("new!!!");
        PauseSubState.restartSong(true);
        PlayState.prevCamFollow = camFollow;
        setGlobalVar("prewZoom",zoom);
    }
}