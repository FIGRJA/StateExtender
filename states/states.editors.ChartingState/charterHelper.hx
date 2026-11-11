//return; LoadingScreen work only in this mod
import Type;
import Reflect;
import Array;
import flixel.FlxG;
import flixel.group.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

//import sys.thread.EventLoop.NextEventTime;
import psychlua.HScript;
import crowplexus.iris.Iris;

//this.set("Rectangle",Type.typeof("openfl.geom.Rectangle"));
//debugPrint(Rectangle);
import openfl.geom.Rectangle;
//import openfl.display.BitmapData;

import backend.Mods;
//import backend.CacheSystem;
import backend.ui.PsychUIBox;
import backend.ui.PsychUIButton;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUINumericStepper;
//import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
//import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import states.editors.ChartingState;
import tjson.TJSON;
import psychlua.LuaUtils;
var fakeLib = false;
//try{
//    if (NativeFileSystem==null){}
//    if (CacheSystem==null){}
//}catch(e:Dynamic){
//    import sys.FileSystem as FileSystem;
//    //import cutscenes.DialogueBoxPsych;
//    
//    function getPathLike(path:String)
//	{
//		if (FileSystem.exists(path))
//			return path;
//		return null;
//	}
//    var fakeNativeFileSystem = {
//        "exists":(p)->{return getPathLike(p)!=null;},
//        "readDirectory":(p)->{
//            if (getPathLike(p)!=null)
//                return FileSystem.readDirectory(p);
//            return [];
//        }
//    };
//    this.set("NativeFileSystem",fakeNativeFileSystem);
//    var fakeCacheSystem = {
//        "loadSound":(p,b,t)->{
//            p = p.split(".ogg")[0];
//            var a = p.split("/");
//            var k = [];
//            k.push(a[0]);
//            k.push(a[1]);
//            var mp = [];
//            for (i in 2...a.length){
//                mp.push(a[i]);
//            }
//            //addOutText(mp);
//            return Paths.returnSound(mp.join("/"));
//        }
//    };
//    this.set("CacheSystem",fakeCacheSystem);
//    fakeLib = true;
//}
/**
 * [Description] 
 * HScript importer
 * @param Var name var of HScript
 * @param Fun name function to import 
 */
function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}
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
var stretchVortex:PsychUICheckBox;
var menuY = 0;
var HXmodules = [];

var Helper:Dynamic ;
var lastTime:Int = 0;
var section:Int = -1;
var curZ = -1;
var beat:Int = -1;
var ChartLoaded:Bool = false;
var previewCharaters:FlxSpriteGroup ;
var hitsoundSign:PsychUINumericStepper ;
var hitsoundPlayerStepper:PsychUINumericStepper;
var hitsoundOpponentStepper:PsychUINumericStepper ;
var hitsoundMetronomeStepper:PsychUINumericStepper ;
var PlWave:PsychUICheckBox;
var OppWave:PsychUICheckBox;
var SimpleWave:PsychUICheckBox;

var healthColorsArray:Array = [0xFF00FF00,0xFFFFFF00];
var wavesTyped = ["null"=>null];

//var animations:Array = [ "singLEFT","singDOWN","singUP","singRIGHT"];
var animations:Array = game.singAnimations ?? [ "singLEFT","singDOWN","singUP","singRIGHT"];
var pitchmap:Array = [1,0.9,1.2,1.1];
//var wavData = [[[0], [0]], [[0], [0]]];

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
    var newText = new FlxText(25,FlxG.height - 30,0,text,20);
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
    var lols = FlxG.height - 30 - (outTextGroup.length * 30);
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

function onCreatePost() {

}
function createModules() {
    
    for (m in StateHelper.getLV("HXmodules")){
        if (m == this ) continue;
        scriptsDefaults(m);
    }
    //var mods = Mods.globalMods;
    //if (mods.contains(Mods.currentModDirectory))
    //    mods.remove(Mods.currentModDirectory);
    //mods = mods.concat([Mods.currentModDirectory]);
    ////debugPrint(mods);
	//for (i in mods) {
    //    for (m in ["scripts","custom_events","custom_notetypes","characters"])
    //    {
    //        var path = "mods/" + i + "/" + m + "/CEmodules";
    //        for (n in NativeFileSystem.readDirectory(path)){
    //            trace(n);
    //            if (n.indexOf(".hx")>0)
    //                StartHXModule(n.split(".hx")[0],m);
    //        }
    //    }
    //}
}
function getIdle(fun,?idleSuffix) { 
    var idle;
    idleSuffix ??= "";
    if(fun("idle"+idleSuffix))
        idle = "idle"+idleSuffix;
    if(fun("danceRight"+idleSuffix))
        idle = "danceRight"+idleSuffix;
    if(fun("danceLeft"+idleSuffix))
        idle = "danceLeft"+idleSuffix;
    //addOutText(idle);
    //addOutText("idleSuffix:"+idleSuffix);
    return idle ?? (idleSuffix.lenght>0?getIdle(fun):idle);
}
var TBoxs:Array=[];
function changeCharacter(who,to) {
    var intC = ["BF","DAD","GF"].indexOf(who.toUpperCase());
    var char = previewCharaters.members[intC];
    var tab = TBoxs[intC];
    char.changeCharacter(to);
    var scale = char.jsonScale*Math.min(300/char.height,600/char.width);
    char.scale.set(scale,scale);
    char.updateHitbox();
    if (tab.selectedTab == null&&tab._lastTab==null){
        char.x = -(char.width-100)/2;
        char.y = -char.height;
    }else{
        char.x = tab.tabs[0].x-(char.width-100)/2;
        char.y = tab.tabs[0].y-char.height;
    }
    char.x -= char.offset.x;//*char.height/300; 
    char.y -= char.offset.y;//*char.width/300;
    //addOutText(tab);
    var daOff = [0,0];
    idle = getIdle(char.hasAnimation);
    if (char.hasAnimation(idle))
        daOff = char.animOffsets.get(idle);
    //addOutText(char.offset);
    char.offset.set(daOff[0],daOff[1]);
    //char.offset(0,0);
    //char.flipX = (char.flipX != char.editorIsPlayer);
    char.visible = to != "null";
    if (icons[intC]!=null)
        icons[intC].changeIcon(char.healthIcon);
    var realN = to.split("/");realN.reverse();
    tab.tabs[0].text.text = "("+["Pl","Opp","GF"][intC]+") "+realN[0];
    healthColorsArray[intC] = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
    //char.update();
    callHX("changeCharacter",[who,to]);
}
function setPrewChars(?charakters) {
    tab_group = mainBox.getTab('Charting').menu;

    charakters ??= [PlayState.SONG.player1,PlayState.SONG.player2,PlayState.SONG.gfVersion];
    for (i in 0...charakters.length){
        var char = new Character(-75 ,-300,charakters[i],i==0);
        //var scale = 300/(1/char.jsonScale*char.height);
        //char.scale.set(scale,scale);
        //char.updateHitbox();
        ////char.flipX = char.isPlayer;
		//char.flipX = (char.flipX != char.editorIsPlayer);
        healthColorsArray[i] = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
        previewCharaters.add(char);
        var TBox = new PsychUIBox((i * 120 - 360),(-20), 120, 10, [charakters[i]]);
        TBox.tabHeight = 0;
        TBox._lastClick = 1;
        TBox.selectedTab = null;
        TBox.getTab(charakters[i]).menu.insert(0,char);
        TBox.getTab(charakters[i]).menu.insert(1,TBox.getTab(charakters[i]).text);
        TBox.getTab(charakters[i]).text.borderStyle = border;
        TBox.getTab(charakters[i]).text.borderColor = 0xFF929292;
        TBox.getTab(charakters[i]).text.borderSize = 0.25;
        TBox.unselectedStyle.bgAlpha = 0.2;
        TBox.bg.visible = false;
        //TBox.getTab(charakters[i]).text.blend = LuaUtils.blendModeFromString("overlay");
        //char.blend = "erase";
        TBoxs.push(TBox);
        tab_group.insert(0,TBox);
        tab_group.add(TBox.getTab(charakters[i]).text);
        
        //changeCharacter(["BF","DAD","GF"][i],charakters[i]);
        char.x = -75 -char.offset.x*char.height/300;
        char.y = -300-char.offset.y*char.height/300; 
    }
}
function notDance() {
    var idle = beat%2==0?"danceLeft":"danceRight";
    for (ch in previewCharaters.members){
        if ((
                ch.animation.finished
                ||ch.animation.curAnim.name.indexOf("-loop")>0
                ||ch.animation.curAnim.name.indexOf("-hold")>0
                ||getIdle((a)->{return ch.animation.curAnim.name==a;},ch.idleSuffix)!=null
            )/*&&!ch.specialAnim*/){
            var cur = ((!ch.hasAnimation(idle))&&(beat%2==1))?"idle":idle;
            if (ch.hasAnimation(cur)) 
                leDance(ch,cur);
        }
    }
    //need ralsei only
}

function leDance(char,anim) {
    if (!char.hasAnimation(anim)) {
        addOutText(char.curCharacter+" not have "+ anim,true,true);
        return;
    }
    var daOffset = char.animOffsets.get(anim);
    //addOutText(anim);
    char.animation.play(anim,true);
    //char.playAnim(anim,true);
    char.offset.set(daOffset[0]*1/char.jsonScale*char.scale.x, daOffset[1]*1/char.jsonScale*char.scale.y);
	char.holdTimer = 0;
    
}
var hitColw = 0;
var holdSounds = [];
function dance(note,newN:Bool) {
    //if (newN){
    //    addOutText("not now",true);
    //}
    var curSec = PlayState.SONG.notes[section];
    var noteData:Int = note.songData[1];
    var noteType:String = note.songData[3];
    if (noteData>ChartingState.GRID_COLUMNS_PER_PLAYER*ChartingState.GRID_PLAYERS) {addOutText("GO OUT WITH note:"+note.songData+" !!!",true,true);return;}
    //ChartingState.GRID_PLAYERS
    //ChartingState.GRID_COLUMNS_PER_PLAYER
    var indexChar = Std.int(noteData/ChartingState.GRID_COLUMNS_PER_PLAYER);
    var localnoteData:Int = noteData%ChartingState.GRID_COLUMNS_PER_PLAYER;
    var HitData = Std.int(noteData/ChartingState.GRID_COLUMNS_PER_PLAYER)==0?
        ['hitNotePlayer',hitsoundPlayerStepper.value]:
        ['hitNoteOpponent',hitsoundOpponentStepper.value];
    var danceN = animations[localnoteData];
    var character:Dynamic = previewCharaters.members[indexChar];
    if (curSec.gfSection) character = (indexChar!=curSec.mustHitSection)?previewCharaters.members[2]:character;
    var canDance = true;
    if (!newN){
        if (character.hasAnimation(danceN+"-hold")){
            danceN += "-hold";
            if (character._lastPlayedAnimation == danceN)
                canDance = false;
        }
        else if (character.hasAnimation(danceN+"-loop")){
            danceN += "-loop";
            if (character._lastPlayedAnimation == danceN)
                canDance = false;
        }
        //if ( character.holdTimer < Conductor.stepCrochet * (0.0011) * character.singDuration ) canDance = false;
    }
    var CustomData = {
        "noteType":noteType,
        "noteData":noteData,
        "note":note,
        "curSec":curSec,
        "character":character,
        "animName":danceN,
        "indexChar":indexChar,
        "localnoteData":localnoteData,
        "inSustain":!newN,
        "canDance":canDance,
        "canHitSounds":true
    };
    callHX("onDance",[CustomData]);
    if ((newN?HitData[1]:hitsoundSign.value)>0&&CustomData.canHitSounds){
        //hitColw -=1;
        if (hitColw<=0||newN) {
            //hitColw = 2;
            if (holdSounds[noteData] !=null) holdSounds[noteData].stop();
            var soundP = FlxG.sound.play(Paths.sound('chartingSounds/'+HitData[0]), HitData[1]*(newN?1:hitsoundSign.value));
            soundP.pitch = 0.95+(localnoteData/20);
            if (!newN) holdSounds[noteData] = soundP;
            //soundP.pitch = pitchmap[localnoteData];//не нравится звучание
            soundP.pan = HitData[0]=="hitNotePlayer"?1:-1;//not work ((
        }
    }
    if (!CustomData.canDance) return;
    leDance(CustomData.character,CustomData.animName);
}
function checkEvent(note) {
    for (ev in note.events){
        callHX("onCheckEvent",[ev]);
        //try{
        //}catch (e:Dynamic){
        //    trace(e);
        //    e = Std.string(e).split(":")[2];
        //    addOutText("err "+e,true,true);
        //    //lyricText.applyMarkup(e,[]);
        //}
    }
}

function checkNotes(notes) {
    for (note in notes)
        {
            if(note == null) continue;
            if(Conductor.songPosition > note.strumTime && lastTime <= note.strumTime+note.sustainLength){
                //addOutText(Type.getClassName(Type.getClass(note)),false,false);
                if (note.isEvent){
                    //some events
                    checkEvent(note);
                }
                else {
                    dance(note,Conductor.songPosition > note.strumTime && lastTime <= note.strumTime);
                    
                }
            }
        }
}
var stretchNote;
var stretchNotes:Array = [];
var deltaMouseY = 0;
var lastUndoID = "";
function checkUndo() {
    var action = undoActions[0];
    if (action!=null){
        var ndata = action.data.notes ?? action.data.events;
        if (ndata!=null){
            if (lastUndoID!=Std.string(ndata[0].ID)+action.action){
                lastUndoID=Std.string(ndata[0].ID)+action.action;
                //addOutText(lastUndoID,false,true);
                if (action.action == "Add Note"){
                    FlxG.sound.play(Paths.sound('chartingSounds/noteLay'), 1);
                    for (n in ndata){
                        while (stretchNotes.length<n.songData[1])
                            stretchNotes.push(null);
                        stretchNotes[n.songData[1]] = n;
                    }
                    stretchNote = ndata[0];
                    deltaMouseY = FlxG.mouse.y-stretchNote.y;
                    //notesPrew.addAllNotes(ndata);
                }
                if (action.action == "Delete Note"){
                    FlxG.sound.play(Paths.sound('chartingSounds/noteErase'), 1);
                    //notesPrew.dellAllNotes(ndata);
                }

            callHX("onUndo",[action,ndata]);
            }
            callHX("onCheckUndo",[action,ndata]);
        }
    }
    for (b in TBoxs.concat([infoBox,mainBox])){
        if (b._lastClick!=0) continue;
        //addOutText(b.selectedTab.name);
        //addOutText(b._lastTab.name);
        if (b.selectedTab==null){
            FlxG.sound.play(Paths.sound('chartingSounds/exitWindow'), 1);
        }else if (b._lastTab==null){
            FlxG.sound.play(Paths.sound('chartingSounds/openWindow'), 1);
        }
    }
}
var firstUpdateChars = false;
function updateCharacters(){
    for (i in [["BF",PlayState.SONG.player1],["DAD",PlayState.SONG.player2],["GF",PlayState.SONG.gfVersion]]){
        changeCharacter(i[0],i[1]);
    }
    firstUpdateChars = true;
}

function removeHitEVER(t) {
    
    FlxG.sound.list.forEachAlive((snd)->
    {
    addOutText(snd.length);
        if (snd.length==144){//hitsound
            snd.stop();
            snd.kill();
        }
    });
}
var p = false;
//var funnyOnec = true;
Helper = ()->{
    try{
        //e += _;
        //trace("hi");
        setVar("chartExtened",Helper);

        if (Type.getClassName(Type.getClass(FlxG.state))=="states.editors.ChartingState"){
            var state =  FlxG.state;
            if (!ChartLoaded){
                menuY = 0;
                scanlofy();
                lofyM = new FlxSound();
                FlxG.sound.list.add(lofyM);
                //FlxG.sound.list.memberAdded.add(removeHitEVER);
                outTextGroup = new FlxTypedSpriteGroup();
                state.insert(5,outTextGroup);
                outTextGroup.cameras = [state.camUI];
                state.outputTxt.visible = false;

                tab_group = state.mainBox.getTab('Charting').menu;
                previewCharaters = new FlxTypedSpriteGroup();
                TBoxs = [];
                setPrewChars();
                lofyCheckBox = new PsychUICheckBox(20 + 290, menuY+5, 'lo-fy', 30, () ->{lofyControl = lofyCheckBox.checked;});
                lofyCheckBox.checked = lofyControl;
                lofyrandom = new PsychUINumericStepper(10 + 353, menuY+23, 5, 25, 0, 100, 0,55);
                lofyvolume = new PsychUINumericStepper(10 + 353, menuY+7, 0.05, 1, 0, 1, 2,55,true);
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
		        tab_group.add(new PsychUIButton(20 + 290,menuY+25,"reroll",chuselofy,40,20));
		        //tab_group.add(new PsychUIButton(20 + 430,menuY+20,"reload Modules",()->{
                //    for (m in HXmodules){
                //        Iris.instances.remove(m.scriptName);
                //        m.destroy();
                //        HXmodules.remove(m);
                //    }
                //    createModules();
                //},100,20));

                menuY += 70;

                hitsoundSign = new PsychUINumericStepper(20 + 290, menuY, 0.1, 0.0, 0, 1, 1);
                tab_group.add(hitsoundSign);
		        tab_group.add(new FlxText(hitsoundSign.x, hitsoundSign.y - 15, 130, 'HitSign (for BIG fps):'));

                menuY += 30;
                
		        tab_group.add(new FlxText(350, menuY, 130, 'Waves'));
                PlWave = new PsychUICheckBox(20 + 290, menuY+10, 'player', 37, () ->{if (wavesTyped.exists("PLAYER")) wavesTyped.get("PLAYER").visible = PlWave.checked;});
                OppWave = new PsychUICheckBox(20 + 347, menuY+10, 'opponent',67, () ->{if (wavesTyped.exists("OPPONENT")) wavesTyped.get("OPPONENT").visible = OppWave.checked;});
                PlWave.checked = (state.vocals ?? {"length":0}).length>100;
                OppWave.checked = (state.opponentVocals ?? {"length":0}).length>100;
                OppWave.box.x += 51;
                OppWave.text.x -= 19;
                PlWave.text.borderStyle = border;
                PlWave.text.borderSize = 1;
                OppWave.text.borderStyle = border;
                OppWave.text.borderSize = 1;
		        tab_group.add(PlWave);
		        tab_group.add(OppWave);
                SimpleWave = new PsychUICheckBox(20 + 290, menuY+30, 'simple waves mode',100);
                //SimpleWave.checked = true;//ClientPrefs.data.lowQuality;//need rework//done
		        tab_group.add(SimpleWave);

                menuY += 50;

                stretchVortex = new PsychUICheckBox(20 + 290, menuY, 'long vortex',40);
		        tab_group.add(stretchVortex);

                menuY += 30;

                hitsoundPlayerStepper = new PsychUINumericStepper(10, 145, 0.2, 0, 0, 1, 1);
                hitsoundOpponentStepper = new PsychUINumericStepper(10+100, 145, 0.2, 0, 0, 1, 1);
                hitsoundMetronomeStepper = new PsychUINumericStepper(10+200, 145, 0.2, 0, 0, 1, 1);
                hitsoundPlayerStepper.behindText.color = 0xF7E3FF;
                hitsoundOpponentStepper.behindText.color = 0xF7E3FF;
                hitsoundMetronomeStepper.behindText.color = 0xF7E3FF;
                if (true){
                    tab_group.remove(state.hitsoundPlayerStepper);
                    tab_group.remove(state.hitsoundOpponentStepper);
                    tab_group.remove(state.metronomeStepper);
                    tab_group.add(hitsoundPlayerStepper);
                    tab_group.add(hitsoundOpponentStepper);
                    tab_group.add(hitsoundMetronomeStepper);
                    hitsoundPlayerStepper.value = 0.6;
                    hitsoundOpponentStepper.value = 0.6;
                }

                //state.mainBox.updateTabs();
                //var wid:Int = state.mainBox.bg.width / state.mainBox.tabs.length;
                var wid:Array = [];
                var pres=0;
                for (tab in state.mainBox.tabs)
                {
                    tab.text.fieldWidth = tab.text.textField.textWidth;
                    tab.text.textField.wordWrap = false;

                    //tab.text.updateHitbox();
                    //tab.text.fieldWidth = tab.text.textField.textWidth+5;
                    wid.push(tab.text.fieldWidth);
                    pres += tab.text.fieldWidth;
                    //tab.resize(wid, 20);
                    //tab.cameras = cameras;
                }
                pres = state.mainBox.bg.width/pres;
                //pres = 1;
                var lX=0;
                for (w in wid) lX += Std.int(w * pres);
                lX = (state.mainBox.bg.width-lX)/2;
                //var tY = lX;
                for (num in 0...state.mainBox.tabs.length)
                {
                    var tab = state.mainBox.tabs[num];
                    tab.x = state.mainBox.x + lX;
                    //tab.y = state.mainBox.y - tY;
                    lX += Std.int(wid[num]*pres);
                    tab.resize(wid[num]*pres, 20);
                    //tab.cameras = cameras;
                }
                createModules();
                callHX("onCreateTrue");

                var cursor = new FlxSprite();
                cursor.loadGraphic(Paths.image("spr_rhythmgame_editor_mouse_0"));
                //cursor.antialiasing = true;
                FlxG.mouse.load(cursor.pixels,2);

                for (i in state.icons){
                    //var scale = i.scale;
                    FlxTween.tween(i,{"x":i.x,"y":i.y,"scale.x":i.scale.x,"scale.y":i.scale.y,"alpha":i.alpha},1);
                    i.scale.set(i.scale.x*50,i.scale.y*50);
                    i.alpha = 1;
                    i.x += i.width*2.5;
                    i.y += i.height*2.5;
                }

                ChartLoaded = true;
                FlxG.sound.play(Paths.sound('snd_ominous'), 0.6);
                if (fakeLib)
                    addOutText("fake Lib's added",true,true);trace("work!!");
                //trace(objThis.interp.locals);
               // addOutText(test.test(),true,true);
                //addOutText(test.testVar,true,true);
            }
            //funnyOnec = !funnyOnec;
            //if (funnyOnec){
            //    return;
            //}
            var sectionChange = false;
            var sectionVec = 0;
            var subEditor = Type.getClassName(Type.getClass(state.subState))=="states.editors.content.EditorPlayState";
            if (subEditor?(state.subState.curSec!=section):(state.curSec!=section)){
                if (section!=-1&&state.curSec==0)//временно
                {
                    updateCharacters();
                   // var wid:Array = [];
                   // var pres=0;
                   // for (tab in state.mainBox.tabs)
                   // {
                   //     tab.text.fieldWidth = tab.text.textField.textWidth+10;
                   //     tab.text.textField.wordWrap = false;

                   //     //tab.text.updateHitbox();
                   //     //tab.text.fieldWidth = tab.text.textField.textWidth+5;
                   //     wid.push(tab.text.fieldWidth);
                   //     pres += tab.text.fieldWidth;
                   //     //tab.resize(wid, 20);
                   //     //tab.cameras = cameras;
                   // }
                   // pres = state.mainBox.bg.width/pres;
                   // //pres = 1;
                   // var lX=0;
                   // for (w in wid) lX += Std.int(w * pres);
                   // lX = (state.mainBox.bg.width-lX)/2;
                   // for (num in 0...state.mainBox.tabs.length)
                   // {
                   //     var tab = state.mainBox.tabs[num];
                   //     tab.x = state.mainBox.x + lX;
                   //     lX += Std.int(wid[num]*pres);
                   //     tab.resize(wid[num]*pres, 20);
                   //     //tab.cameras = cameras;
                   // }
                }
                sectionVec = subEditor?(state.subState.curSec):(state.curSec) - section;
                section = subEditor?(state.subState.curSec):(state.curSec);
                sectionChange = true;
                if (hitsoundMetronomeStepper.value>0)
                    FlxG.sound.play(Paths.sound('chartingSounds/metronome1'), hitsoundMetronomeStepper.value);
                //for (i in 0...ChartingState.GRID_PLAYERS){
                //    state.icons[i].antialiasing=false;
                //}
                if (ChartingState.GRID_PLAYERS==1){
                    //var kek = ChartingState.GRID_SIZE;
                    //ChartingState.GRID_SIZE = 20;
                    updateWaveform("INST");
                    //ChartingState.GRID_SIZE = kek;
                }
                
            }
            if (subEditor?(state.subState.curBeat!=beat):(state.curBeat!=beat)){
                beat = subEditor?(state.subState.curBeat):(state.curBeat);
                notDance();
                if (!sectionChange&&hitsoundMetronomeStepper.value>0)
                    FlxG.sound.play(Paths.sound('chartingSounds/metronome2'), hitsoundMetronomeStepper.value);

            }
            if ((FlxG.sound.music.playing||subEditor)&&(lastTime != Conductor.songPosition)){
                if (subEditor){
                    //state.mainBox.visible=true;
                    //addOutText("hi",false,true);
                    try{
                        checkNotes(state.notes.concat(state.events));
                        for (m in previewCharaters){
                            if(m!=null)
                                m.update((Conductor.songPosition-lastTime)/1000);
                        }
                    }catch(e:Dynamic){addOutText(e,true);}
                }
                else
                    checkNotes(state.curRenderedNotes.members.concat(state.behindRenderedNotes.members));

                
            }
            //lateDance();
            lastTime = Conductor.songPosition;
            //trace(Conductor.songPosition);
            if (FlxG.sound.music.playing||subEditor)
                stoplofy();
            else
                playlofy();
            if (state.outputAlpha == 4){
                addOutText(state.outputTxt.text,state.outputTxt.color==0xFFFF0000,true);
                state.outputAlpha = 0;//lol
               // trace("triger!!!");
            }
            var onTabs = ((state.subState!=null) || FlxG.mouse.overlaps(state.mainBox,state.camUI) || FlxG.mouse.overlaps(state.infoBox,state.camUI) || FlxG.mouse.overlaps(state.upperBox,state.camUI));
            if (!onTabs){
                for (i in TBoxs){
                    onTabs = onTabs || FlxG.mouse.overlaps(i,state.camUI);
                }
            }
            if (FlxG.mouse.justPressed){
                if (onTabs&&!p){
                    FlxG.sound.play(Paths.sound('chartingSounds/ClickDown'), 0.6);
                    p = true;
                }
                stretchNote = null;
                
            }
            if (FlxG.mouse.pressed){
                if (stretchNote!=null){
                    var susBase = (Conductor.stepCrochet / 2);
                    var sus = susBase*Std.int((FlxG.mouse.y-deltaMouseY-stretchNote.y)/(ChartingState.GRID_SIZE/2));
                    //addOutText(FlxG.mouse.y-stretchNote.y);
                    //addOutText(FlxG.mouse.y);
                    if (sus != stretchNote.sustainLength&&sus>=0){
                        stretchNote.setSustainLength(sus,state.cachedSectionCrochets[section] / 4, state.curZoom);
                        FlxG.sound.play(Paths.sound('chartingSounds/stretch'+Std.string(FlxG.random.int(1,2))+'_UI'), 0.6);
                    }
                }
                
            }
            if (stretchVortex.checked){
                var PressedVortexKeys = [];
            // trace("1");
                for (k in ChartingState.keysArray)
                    PressedVortexKeys.push(FlxG.keys.checkStatus(k, 1));//1 == PRESSED
                if (PressedVortexKeys.contains(true)){
                    var susBase = (Conductor.stepCrochet / 2);
                    for (i in 0...PressedVortexKeys.length){
                        if (!PressedVortexKeys[i]) stretchNotes[i] = null;
                        if (stretchNotes[i]==null) continue;
                        var sus = susBase*Std.int((Conductor.songPosition-stretchNotes[i].strumTime)/susBase);
                        if (sus < susBase*2) continue;
                        //trace(sus);
                        stretchNotes[i].setSustainLength(sus,state.cachedSectionCrochets[section] / 4, state.curZoom);
                    }
                }else
                    stretchNotes = [];
            }
            //trace("3");
            if (FlxG.mouse.justReleased ){
                if (onTabs&&p){
                    FlxG.sound.play(Paths.sound('chartingSounds/ClickUp'), 0.6);
                    p = false;
                }
                stretchNote = null;
            }
            checkUndo();
            //notesPrew.Update();
            if (sectionChange||curZ != curZoom){
                //if (section%2==0){
                PlWave.text.color = healthColorsArray[0];
                PlWave.text.borderColor = isLight(healthColorsArray[0])?0xFF000000:0xFFFFFFFF;
                OppWave.text.color = healthColorsArray[1];
                OppWave.text.borderColor = isLight(healthColorsArray[1])?0xFF000000:0xFFFFFFFF;
                upgradeCW(section,sectionVec);
                //if (PlWave.checked)
                //    updateWaveform("PLAYER"  ,healthColorsArray[0],state.gridBg.x - ChartingState.GRID_SIZE*(ChartingState.GRID_COLUMNS_PER_PLAYER-1));
                //if (OppWave.checked)
                //    updateWaveform("OPPONENT",healthColorsArray[1],state.gridBg.x + ChartingState.GRID_SIZE*(ChartingState.GRID_COLUMNS_PER_PLAYER+1));
                //}
                //state.updateWaveform();
                //addOutText("Update");
                }
            //callHX("onUpdate");
        }else{
            if(ChartLoaded){
                ChartLoaded = false;
                onRealDestroy();
               // FlxG.signals.postUpdate.remove(Helper);//how fix addOutText == null
            }
        }
        try{
        if (getVar("chartHelper2")!=null){
            FlxG.signals.postUpdate.remove(Helper);
            addOutText("sorry.",true,true);
            trace("panic unextended");  
            onRealDestroy();
            //this.destroy();
        }}catch (e:Dynamic) {}
    }catch (e:Dynamic) {
        trace(e);
        FlxG.signals.postUpdate.remove(Helper);
        addOutText("i'm dead",true);
        addOutText(e);
        onRealDestroy(true);

        Iris.instances.get(this.config.name).destroy();
        Iris.instances.remove(this.config.name);
        //this.destroy();
    }
}

var ema:Float = 0;
var dis:Bool = false;
function onUpdatePost(e) {
    Helper();
    if (!firstUpdateChars)
        updateCharacters();
}
function onUpdates(e) {
    ema += e;
    if (ema>(e*5)&&!dis){
        if (getVar("chartHelper2")==null){//disable on other scripts
            if (getVar("chartExtened")!=null){
                trace("UnExtended Editor");
                FlxG.signals.postUpdate.remove(getVar("chartExtened"));
                setVar("chartExtened",null);
                
            }
            if (getVar("chartExtened")==null){
                trace("Extended Editor");
                FlxG.signals.postUpdate.add(Helper);
            }
        }
        dis = true;
        //trace(game.songName);
        //ema += e;
    }
}

var wavData = [[[0], [0]], [[0], [0]]];

function upgradeCW(cur,vec) {
    try{
    var reload = Math.abs(vec)>1||curZ != curZoom;
    vec = ((SimpleWave.checked||!FlxG.sound.music.playing)&&reload)?0:vec;
    reload = (SimpleWave.checked)?false:reload;
    curZ = curZoom;
    //trace(reload);
    for (i in ["PLAYER" ,"OPPONENT"])
        if ((i=="PLAYER"?PlWave.checked:OppWave.checked)){
            for (m in reload?(-1...2):([vec]))
                if (cur+m>=0){
                    var wave = updateCustomWaveform(wavesTyped.get(i+(cur+m)%3),cur+m,1,i=="PLAYER"?vocals:opponentVocals,healthColorsArray[i=="OPPONENT"]);
                    wave.y = switch(m)
                    {
                        case -1:
                            prevGridBg.y;
                        case 0:
                            gridBg.y;
                        case 1:
                            nextGridBg.y;
                        default:
                            trace(m);
                    };
                    wave.x = i=="PLAYER"?gridBg.x - ChartingState.GRID_SIZE*(ChartingState.GRID_COLUMNS_PER_PLAYER-1):gridBg.x + ChartingState.GRID_SIZE*(ChartingState.GRID_COLUMNS_PER_PLAYER+1);
                    wavesTyped.set(i+(cur+m)%3,wave);
                }
        }else{
            for (m in 0...3){
                if (wavesTyped.exists(i+m))
                    wavesTyped.get(i+m).visible = false;
            }
        }
    }catch(e:Dynamic){addOutText(e,true);}
}
function updateCustomWaveform(sameWave,_curSec,?_lenSec,?sound,?color) {
    try{
        _lenSec ??= 1;
        color ??= 0xFFFFFF;
        for (i in 0...2)
            for (ii in 0...2)
                wavData[i][ii] = [0];

		var width:Int = Std.int(ChartingState.GRID_SIZE * ChartingState.GRID_COLUMNS_PER_PLAYER * 2);
		var height:Int = Std.int(switch(_curSec-curSec)
                    {
                        case -1:
                            prevGridBg.height;
                        case 0:
                            gridBg.height;
                        case 1:
                            nextGridBg.height;
                        //default:
                            //trace(m);
                    });

        if (sameWave==null||(!sameWave.alive)){
            sameWave = new FlxSprite(0, 0);
            sameWave.makeGraphic(width, height, 0x00000000,true);
            sameWave.scrollFactor.x = 0;
            sameWave.alpha = 1;
            sameWave.visible = false;
            insert(5,sameWave);
        }
		if(_curSec < 0 || _curSec >= cachedSectionTimes.length /*|| !waveformEnabled*/)
		{
			sameWave.visible = false;
			return;
		}
		sameWave.visible = true;

		if(Std.int(sameWave.height) != height && sameWave.pixels != null)
		{
			sameWave.pixels.dispose();
			sameWave.pixels.disposeImage();
			sameWave.makeGraphic(width, height, 0x00000000,true);
		}
		sameWave.pixels.fillRect(new Rectangle(0, 0, width, height), 0x00000000);
        

		if (sound != null && sound._sound != null && sound._sound.__buffer != null)
		{
			var data = sound._sound.__buffer.data.buffer;
			wavData = waveformData(sound._sound.__buffer, data, cachedSectionTimes[_curSec] - Conductor.offset, cachedSectionTimes[_curSec+_lenSec] - Conductor.offset, 1 , wavData, height);
		}

		// Draws
		var gSize:Int = Std.int(ChartingState.GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize / 2);
		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);
		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;
        var someColor = isLight(color)?0xFF000000:0xFFFFFFFF;
		for (index in 0...length)
		{
			var lmin:Float = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var lmax:Float = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			var rmin:Float = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var rmax:Float = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

            if (!(ClientPrefs.data.lowQuality||SimpleWave.checked))
			    sameWave.pixels.fillRect(new Rectangle((hSize - (lmin + rmin)) , index, ((lmin + rmin) + (lmax + rmax)), 1), someColor);
			sameWave.pixels.fillRect(new Rectangle((hSize - (lmin + rmin)) +size, index, ((lmin + rmin) + (lmax + rmax)) -size*2, 1), color);
		}
        return sameWave;
	}catch(e:Dynamic){addOutText(e,true);}
}


function onDestroy() {
    onRealDestroy();
}
function onRealDestroy(?panic=false) {
    for (m in wavesTyped){
        if(m!=null){
            m.kill();}
    }
    //for (m in outTextGroup){
    //    if(m!=null)
    //        m.kill();
    //}
    for (m in previewCharaters){
        if(m!=null)
            m.kill();
    }
    for (m in HXmodules){
        //m.get("destroy")();
        //callHX("onDestroy");
        //Iris.instances.remove(m.scriptName);
        //m.destroy();
    }
    if (fakeLib){
        NativeFileSystem?.destroy();
        CacheSystem?.destroy();
    }
    for (i in 0...2)
        for (ii in 0...2)
            wavData[i][ii] = [0];
    //lofyList?.clear();
    lofyM?.destroy();
    //lofyCheckBox?.destroy();
    //lofyvolume?.destroy();
    //lofyrandom?.destroy();
    //SimpleWave?.destroy();
    //OppWave?.destroy();
    //PlWave?.destroy();
    //hitsoundOpponentStepper?.destroy();
    //hitsoundPlayerStepper?.destroy();
    //hitsoundSign?.destroy();
    //healthColorsArray = null;
    //FlxG.sound.list.memberAdded.remove(removeHitEVER);
    if (panic)
        FlxG.sound.play(Paths.sound('snd_ominous_hell'), 1);
    else
        FlxG.sound.play(Paths.sound('snd_ominous_cancel'), 0.6);
}
function callHX(fun,?arrs){
    arrs ??= [];
    var r;
    for (hx in HXmodules)
        if (hx.exists(fun))
            try{
                hx.call(fun,arrs);
            }catch (e:Dynamic){
                trace(e);
                e = Std.string(e).split(":").join(":\n\t\t");
                addOutText("err "+e,true,true);
            }
}
var objThis;
var interp = this.interp;
function getLV(L) {
	return interp.locals.get(L).r;	
}
function setLV(L,r) {
	if (L.split(".").length==1){
		var V = interp.locals.get(L);
		if (V==null){
			debugPrint("err set like "+L);
			return;
		}
		V.r = r;
	}
}
function StartHXModule(module,?dir) {
    dir ??= "scripts";
    var scriptToLoad = Paths.modFolders(dir+"/CEmodules/"+module+".hx");
    //trace("try "+module);
    
	if (NativeFileSystem.exists(scriptToLoad)) {
		if (Iris.instances.exists(scriptToLoad)) {
            Iris.instances.get(scriptToLoad).destroy();
            Iris.instances.remove(scriptToLoad);
        }
        try {
            DeltaRuneCode = new HScript(null, scriptToLoad);
            //DeltaRuneCode.interp.showPosOnLog = true;
            //DeltaRuneCode.set("Mods",Mods);
            scriptsDefaults(DeltaRuneCode);
            DeltaRuneCode.set("CacheSystem",CacheSystem);//with fake
            DeltaRuneCode.set("NativeFileSystem",NativeFileSystem);//with fake
            HXmodules.push(DeltaRuneCode);
            //this.set("new_"+module,DeltaRuneCode.get("realNew"));
            //trace("loaded "+module);
        } catch (e:Dynamic) {
            trace(e);
            addOutText(e,true);
            var newScript:HScript = Iris.instances.get(dir+"/CEmodules/"+module+".hx");
            if (newScript != null)
                newScript?.destroy();
            return;
        }
		
	} else {
		debugPrint("hx file not found", 0xFF0000);
		return;
	}
}
function scriptsDefaults(Hs) {

    Hs.set("addOutText",addOutText);
    Hs.set("CharterHelper",objThis);
    Hs.set("setVarH",setLV);
    Hs.set("getVarH",getLV);
    
    Hs.set("PsychUIBox",PsychUIBox);
    Hs.set("PsychUIButton",PsychUIButton);
    Hs.set("PsychUICheckBox",PsychUICheckBox);
    Hs.set("PsychUINumericStepper",PsychUINumericStepper);
    Hs.set("FlxTypedSpriteGroup",FlxTypedSpriteGroup);
    HXmodules.push(Hs);
}

function isLight(color:Int):Bool {// from yandexChat
    var r = (color >> 16) & 0xFF;
    var g = (color >> 8)  & 0xFF;
    var b = color & 0xFF;

    var luminance = 0.299 * r + 0.587 * g + 0.114 * b;

    return luminance >= 128;
}
objThis = {};
for (f in this.interp.variables.keys()){
    Reflect.setField(objThis,f,this.get(f));
}
//for (f in this.interp.locals.keys()){
//    if (f=="f"||f=="objThis") continue;
//    Reflect.setField(objThis,f,this.interp.locals.get(f).r);
//}
