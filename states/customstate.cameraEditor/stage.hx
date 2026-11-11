package states.customstage.cameraEditor;

import backend.ui.PsychUIBox;
import backend.ui.PsychUIButton;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUINumericStepper;
import states.editors.MasterEditorMenu;
import backend.MusicBeatState;
import openfl.geom.Rectangle;
import backend.Controls;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMatrix;
//maybe extend playstate
var camGame = new FlxCamera();
var camHUD = new FlxCamera();
var camOther = new FlxCamera();
var camEditor = new FlxCamera();
var gameZoom = 1;
var gameScroll = {x:0, y:0};
var gameCanvas = new FlxSprite();
var gameBD = gameCanvas.bitmapData;
var gameM = new FlxMatrix();

function onCreatePost() {
    FlxG.cameras.add(camGame);
    //FlxG.cameras.add(camHUD,false);
    //FlxG.cameras.add(camOther,false);
    super.camera = camGame;
    FlxG.cameras.add(camEditor,false);
    nullsProp = new FlxBackdrop(null,0x11);
    nullsProp.makeGraphic(50,50,0xFFA0A0A0);
    nullsProp.pixels.fillRect(new Rectangle(0, 0,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    nullsProp.pixels.fillRect(new Rectangle(nullsProp.width/2, nullsProp.height/2,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    nullsProp.camera = camEditor;
    nullsProp.velocity.set(15,15);
    add(nullsProp);
    var TempText = new FlxText(FlxG.width/2-125,FlxG.height/2-20,250,"not Now\npress [7](debug1)",20);
    TempText.camera = camEditor;
    TempText.color = 0xFF3A3A3A;
    add(TempText);
}
var Control = Controls.instance;
function onUpdate(e) {
    camGame.x = FlxG.width;
    camGame.y = FlxG.height;
	if (Control.justPressed('debug_1')){
		//playSnd("splat");
		//MusicBeatState.resetState();
        MusicBeatState.switchState(new MasterEditorMenu());
    }
	
}
function onDraw() {
    
}