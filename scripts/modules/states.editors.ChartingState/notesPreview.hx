//package scripts.modules;

//по хорошему всё это переработать зная всё сейчас но пока работает не трогаю. переписать нужно из-за костылей

import flixel.group.FlxTypedSpriteGroup;
import states.editors.content.BasePrompt;
import states.editors.ChartingState;
import backend.Song;
import openfl.geom.Rectangle;
import Reflect;
import Type;
import psychlua.LuaUtils;
//import flash.display.BlendMode;
//import openfl.display.BlendMode as BM;
//this.set("BlendMode",Type.resolveEnum("resolveClass"));
var Mainobj;
var sliderobj;
var obj;
function Create() {
    //destroy();
    //addOutText("try");
    Mainobj = new FlxSprite();
    sliderobj = new FlxSprite();
    for (f in Type.getInstanceFields(Type.getClass(Mainobj))){
        this.set(f,Reflect.field(Mainobj,f));
    }
    obj = {};
    for (f in this.interp.locals.keys()){
        if (f=="f"||f=="obj"||f=="Mainobj") continue;
        Reflect.setField(obj,f,this.interp.locals.get(f).r);
    }
    for (f in this.interp.variables.keys()){
        Reflect.setField(obj,f,this.get(f));
    }
    var g = new FlxTypedSpriteGroup();
    g.add(Mainobj);
    g.add(sliderobj);
    Reflect.setField(obj,"obj",g);
    //updateG(1);
    Mainobj.scrollFactor.set(0,0);
    sliderobj.scrollFactor.set(0,0);
    //sliderobj.blend = LuaUtils.blendModeFromString("invert");//BM.OVERLAY;//BM.fromString("overlay");
    //trace(LuaUtils.blendModeFromString("add"));
    sliderobj.makeGraphic(5*(ChartingState.GRID_COLUMNS_PER_PLAYER*ChartingState.GRID_PLAYERS+1),4*4,0x59FDB838);
    sliderobj.pixels.fillRect(new Rectangle(0,4*2,sliderobj.width,1), 0x94FF0000);
}
var standartColor = 0xB0444141;
var lenSon = 0;
var stepCrochet = 0;
function setStepCrochet(s) {
    stepCrochet = s;
}
function updateG(l) {
    lenSon = l;
    //setStepCrochet(720/l);
    var h = l/stepCrochet;
    makeGraphic(5*(ChartingState.GRID_COLUMNS_PER_PLAYER*ChartingState.GRID_PLAYERS+1),h,standartColor,true);
    Mainobj.y = 0;
    sliderobj.y = -3;
    //if (h<=720){
    //    Mainobj.y = (720-h)/2;
    //    sliderobj.y = Mainobj.y-7;
    //}
    //else{
    //    Mainobj.y = 0;
    //    sliderobj.y = 0;
    //}
    //sliderobj.scrollFactor.y = -(720)/(curZoom*ChartingState.GRID_SIZE*(lenSon/Conductor.stepCrochet));
        
       
}
var mover = false;
//function get_mover() {
//    return mover;
//}
function onUpdatePost(e) {
    //if (Mainobj.height>720)
   //     Mainobj.scrollFactor.y = (Mainobj.height-720)/(curZoom*ChartingState.GRID_SIZE*(lenSon/Conductor.stepCrochet));
   // sliderobj.scrollFactor.y = -Math.min(720,Mainobj.height)/(curZoom*ChartingState.GRID_SIZE*(lenSon/Conductor.stepCrochet));
    if (FlxG.mouse.justPressed&&FlxG.mouse.overlaps(sliderobj)){
        mover = true;
    }else if (FlxG.mouse.justReleased&&mover){
        mover = false;
    }
    if (FlxG.mouse.pressed&&mover){
        searchTime();
    }
    if (FlxG.mouse.justPressed&&FlxG.mouse.overlaps(Mainobj)&&!mover){
        searchTime();
    }
    sliderobj.y = Conductor.songPosition*720/lenSon-9;
    //stepCrochet = Conductor.stepCrochet;    
}
function searchTime() {
    var time = FlxG.sound.music.time;
    if (!mover){
        time = (FlxG.mouse.y-FlxG.camera.scroll.y)*(lenSon/FlxG.camera.height);
    }
    else
        time += FlxG.mouse.deltaScreenY*(lenSon/FlxG.camera.height);//must use FlxG.mouse.deltaViewY but... psych 1.+ dont know it
    mover = true;
    //addOutText(time);
    for (t in cachedSectionTimes){
        if (t>=time){
            var _curSec = cachedSectionTimes.indexOf(t)-1;
            //curSec = cachedSectionTimes[curSec]-time>time-t?curSec+1:curSec;
            FlxG.sound.music.time = time;
            vocals.time = time;
            opponentVocals.time = time;
            if (_curSec!=curSec)
                loadSection();
            return;
        }
    }
    //var curSec = cachedSectionTimes.lenght-1;
    //FlxG.sound.music.time = time;
    //vocals.time = time;
    //opponentVocals.time = time;
    //if (curSec!=curSec)
    //    loadSection();
    
}
function dellNote(note) {
    var color = standartColor;
    var Y = 0;
    var X = 0;
    if (!note.isEvent){
        Y = Std.int(note.songData[0]/stepCrochet);
        X = (note.songData[1]+1)*5;
    }else{
        Y = Std.int(note.strumTime/stepCrochet);
    }
    Mainobj.pixels.fillRect(new Rectangle(X,Y,5,1), color);
    
}
function addNote(note) {
    var color = 0xFF252525;
    var Y = 0;
    var X = 0;
    var sus = 0;
    if (!note.isEvent){
        var colors = ClientPrefs.data.arrowRGB[note.songData[1]%4];
        //color = FlxColor.fromRGB(colors[0],colors[1],colors[2]);
        color = colors[0];
        Y = Std.int(note.songData[0]/stepCrochet);
        sus = note.songData[2]/stepCrochet;
        X = (note.songData[1]+1)*5;
    }else{
        Y = Std.int(note.strumTime/stepCrochet);
    }
    Mainobj.pixels.fillRect(new Rectangle(X,Y,5,1), color);
    //if (sus>0)
    //    Mainobj.pixels.fillRect(new Rectangle(X+2,Y,1,sus), color);
    
}
function addAllNotes(notes) {
    for (n in notes)
        addNote(n);
}
function dellAllNotes(notes) {
    for (n in notes)
        dellNote(n);
}

function realClear() {
    Mainobj.pixels.fillRect(new Rectangle(0,0,Mainobj.width,Mainobj.height), standartColor);
}
//function realNew() {
//    Create();
//    return obj;
//}
function destroy() {
    Mainobj?.kill();
    sliderobj?.kill();
    //obj?.kill();
    //Mainobj = null;
    //sliderobj = null;
}
var testVar = 666;
//realNew();
//create();

function onUndo(A,U) {
     if (A.action == "Add Note"){
        addAllNotes(U);
    }
    if (A.action == "Delete Note"){
        dellAllNotes(U);
    }
}

function onCreatePost() {
    Create();
    //notesPrew.stepCrochet = 100;
    //notesPrew.obj.cameras = [state.camUI];
    obj.obj.x = gridBg.x-45-(5*(ChartingState.GRID_COLUMNS_PER_PLAYER*ChartingState.GRID_PLAYERS+1));
    setStepCrochet(Std.int(FlxG.sound.music.length/720));
    updateG(FlxG.sound.music.length);
    addAllNotes(notes);
    addAllNotes(events);
    insert(5,obj.obj);
    mainBox.getTab('Charting').menu.add(new PsychUIButton(20 + 290,getVarH("menuY"),"reload NotesPreview",()->{
        realClear();
        setStepCrochet(FlxG.sound.music.length/720);
        updateG(FlxG.sound.music.length);
        addAllNotes(notes);
        addAllNotes(events);
    },120,20));
}
function reloadNP() {
    realClear();
    setStepCrochet(FlxG.sound.music.length/720);
    updateG(FlxG.sound.music.length);
    addAllNotes(notes);
    addAllNotes(events);
    
}
setVar("reloadNotesPreview",reloadNP);
setGlobalVar("reloadNotesPreview",reloadNP);
