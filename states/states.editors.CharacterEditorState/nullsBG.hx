//package states.states.editors.StageEditorState;


import backend.Mods;
import backend.ui.PsychUIButton;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUINumericStepper;
import tjson.TJSON;
import flixel.FlxG;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.group.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import flixel.addons.display.FlxBackdrop;
import openfl.geom.Rectangle;
import Reflect;
import Type;
//import flixel.util.FlxAxes;

function parseJson(file) {
    s = NativeFileSystem.getContent(file);
    return TJSON.parse(s);
}

var lofyList = [""=>""];
var lofyM:FlxSound;
var lofyControl:Bool = true;
var curlofy:String = "chartEditorLoop";
var lofyrandom:PsychUINumericStepper;
var lofyvolume:PsychUINumericStepper;
var lofyCheckBox:PsychUICheckBox;

function scanlofy() {
    //var list = Mods.parseList();
    lofyList.clear();
	for (i in Mods.getModDirectories()) {
	//for (i in list.enabled) {
		var path = "mods/" + i + "/music/chartEditorLoop";
        //if (NativeFileSystem.exists(path))
        for (n in NativeFileSystem.readDirectory(path)){
            if (n.indexOf("-metadata.json")>0){
                //trace(path+"/"+n);
                var data = parseJson(path+"/"+n);
                //trace(data);
                //Reflect.setField(data,"mod",i);
                if (getSong(n.split("-metadata.json")[0])!=null)
                    lofyList.set(n.split("-metadata.json")[0],data);
                else
                    trace("not found "+n.split("-metadata.json")[0]);
            }
        }
    }
    //trace(lofyList);
    
}
function playlofy() {
    if (!lofyControl){
        stoplofy();
        return;
    }
    if (lofyM.length<1)
        chuselofy(curlofy);
    if (lofyM.playing) 
        return;

    if (lofyM.time>1)
        lofyM.resume();
    else
        lofyM.play();
    var data = lofyList.get(curlofy);
    //trace(lofyM.time);
    lofyM.fadeIn((60*80)/data.timeChanges[0].bpm,0,lofyvolume.value);
    
}
function getArrKeysMap(map) {
    var arr = [];
    for (i in map.keys()){
        arr.push(i);
    }
    return arr;
}
function chuselofy(?name) {
    if (name==null||!lofyList.exists(name)||FlxG.random.bool(lofyrandom.value)){
        var keys = getArrKeysMap(lofyList);
        curlofy = keys[FlxG.random.int(0,keys.length-1)];
    }
    if (curlofy == name&&lofyM.length>1) return;
    curlofy ??= name;
    trace(curlofy);
    var data = lofyList.get(curlofy);
    var sound = CacheSystem.loadSound(getSong(curlofy),false,"nice Try");
    if (sound==null){
        chuselofy();
        return;
    }
    lofyM.loadEmbedded(sound,true,false,()->{chuselofy(curlofy);});
    lofyM.stop();
    lofyM.volume = 0;
    addOutText("playing "+data.songName+" by "+data.artist);

}
function stoplofy() {
    //FlxTween.cancelTweensOf(lofyM);
    //FlxG.sound.list.forEachAlive((snd)->
    //{
    //    if (snd.length==144){//hitsound
    //        snd.stop();
    //        snd.kill();
    //    }
    //});
    if (!lofyM.playing) return;
    if (lofyM.fadeTween!=null)
        lofyM.fadeTween.cancel();
    lofyM.pause();
}

function getSong(song) {
    if (song == null) return;
    for (p in ["/music/chartEditorLoop/","/mus/","/music/"]){
        var name = p+song+".ogg";
        for (i in Mods.getModDirectories()){
            if (NativeFileSystem.exists("mods/"+i+name))
                return "mods/"+i+name;
        }
        if (NativeFileSystem.exists("assets/shared"+name))
            return "assets/shared"+name;
        
    }
}

var outTextGroup:FlxSpriteGroup;
var border = Type.createEnum(FlxTextBorderStyle,"OUTLINE"); 

/**
 * [Description]
 * @param text message
 * @param err=false turn message to RED
 * @param used=false off notify sound
 */
function addOutText(text,?err=false,?used=false) {
    //if (!ChartLoaded) return;
    if (outTextGroup==null) return;
    var newText = new FlxText(45,FlxG.height - 50,0,text,20);
    newText.borderStyle = border;
    newText.borderSize = 2;
    if(err)
    {
        if (!used)
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
        newText.color = 0xFFFF0000;
    }
    else
    {
        if (!used)
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
        newText.color = 0xFFFFFFFF;
    }
    FlxTween.tween(newText,{alpha:0},3,{
        startDelay: 3,
        onComplete: (_) -> {outTextGroup.remove(newText,true);newText.destroy();}
    });
    newText.alpha = 0;
    FlxTween.tween(newText,{alpha:1},0.2);
    outTextGroup.add(newText);
    var lols = FlxG.height - 90 - (outTextGroup.length * 30);
    outTextGroup.forEachAlive((spr)->
    {
        FlxTween.tween(spr,{y:lols},0.2);
        lols += 20 + 10;
        //spr.y -= 20 + 10;
    });
    if (!used){
        trace(text);
    }
}


var camNulls:FlxCamera;
var nullsProp:FlxBackdrop;

function onCreate() {
    camNulls = new FlxCamera(0,0,FlxG.width,FlxG.height,1);
    //camNulls.bgColor = 0x00FF0000;
    //camNulls.useBgAlphaBlending = true;
    scanlofy();
    lofyM = new FlxSound();
    FlxG.sound.list.add(lofyM);
    //FlxG.sound.list.memberAdded.add(removeHitEVER);
    outTextGroup = new FlxTypedSpriteGroup();
}
function onCreatePost() {
    //var bbProp = new FlxSprite();
    nullsProp = new FlxBackdrop(null,0x11);
    nullsProp.makeGraphic(50,50,0xFFA0A0A0);
    nullsProp.pixels.fillRect(new Rectangle(0, 0,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    nullsProp.pixels.fillRect(new Rectangle(nullsProp.width/2, nullsProp.height/2,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    nullsProp.camera = camNulls;
    nullsProp.velocity.set(15,15);
    add(nullsProp);
    insrtCam(camNulls,0,false);
    //FlxG.camera.visible = false;
    //FlxG.cameras.add(camNulls,false);
    //super.camGame.bgColor = 0xF5000000;
    FlxG.camera.bgColor = 0x00000000;
    //camGame.alpha = 0.5;
    //FlxG.camera.useBgAlphaBlending = true;
    add(outTextGroup);
    outTextGroup.cameras = [camHUD];
   // addOutText(FlxG.cameras.list.length);
   // addOutText(Type.getInstanceFields(Type.getClass(FlxG.cameras)));
   // for (s in Type.getInstanceFields(Type.getClass(FlxG.cameras)))
   // addOutText(s);
    //state.outputTxt.visible = false;

    var tab_group = UI_box.getTab('Settings').menu;
    var menuY = 0;
    var menuX = 250;

    lofyCheckBox = new PsychUICheckBox(menuX, menuY+5, 'lo-fy', 30, () ->{lofyControl = lofyCheckBox.checked;});
    lofyCheckBox.checked = lofyControl;
    lofyrandom = new PsychUINumericStepper(menuX + 53, menuY+23, 5, 25, 0, 100, 0,55);
    lofyvolume = new PsychUINumericStepper(menuX + 53, menuY+7, 0.05, 1, 0, 1, 2,55,true);
    tab_group.add(lofyCheckBox);
    tab_group.add(lofyvolume);
    
    lofyvolume.onValueChange=()->{
        if (lofyM.fadeTween!=null)
            if (lofyM.fadeTween.active){
                var ti = (1-lofyM.fadeTween.percent)*lofyM.fadeTween.duration;
                lofyM.fadeTween.cancel();
                lofyM.fadeIn(ti,lofyM.volume,lofyvolume.value);
                return;
            }
        lofyM.volume=lofyvolume.value;
    };
    tab_group.add(lofyrandom);
    tab_group.add(new FlxText(lofyrandom.x-7, lofyrandom.y + 15, 130, '% random next'));
    tab_group.add(new PsychUIButton(menuX ,menuY+25,"reroll",chuselofy,40,20));
    playlofy();

    // end music //

}
function insrtCam(newCamera:T, position:Int, ?defaultDrawTarget = true) {//psych not have it(
    if (position < 0)
	        position += FlxG.cameras.list.length;
	    
	    // invalid ranges are added (match Array.insert's behavior)
        if (position >= FlxG.cameras.list.length)
            return FlxG.cameras.add(newCamera, defaultDrawTarget);
        
        final childIndex = FlxG.game.getChildIndex(FlxG.cameras.list[position].flashSprite);
        FlxG.game.addChildAt(newCamera.flashSprite, childIndex);
		
		 FlxG.cameras.list.insert(position, newCamera);
		if (defaultDrawTarget)
			 FlxG.cameras.defaults.push(newCamera);
		
		for (i in position...FlxG.cameras.list.length)
			 FlxG.cameras.list[i].ID = i;
		
		 FlxG.cameras.cameraAdded.dispatch(newCamera);
		return newCamera;
}
function onUpdate() {
    
}
function onDestroy() {
    nullsProp.destroy();
    outTextGroup.destroy();
    lofyM.destroy();
    lofyCheckBox.destroy();
    lofyrandom.destroy();
    lofyvolume.destroy();
}   
