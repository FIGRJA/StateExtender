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

function onCreatePost() {
    nullsProp = new FlxBackdrop(null,0x11);
    nullsProp.makeGraphic(50,50,0xFFA0A0A0);
    nullsProp.pixels.fillRect(new Rectangle(0, 0,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    nullsProp.pixels.fillRect(new Rectangle(nullsProp.width/2, nullsProp.height/2,nullsProp.width/2, nullsProp.height/2), 0xFFFFFFFF);
    //nullsProp.camera = camNulls;
    nullsProp.velocity.set(15,15);
    add(nullsProp);
    var TempText = new FlxText(FlxG.width/2-125,FlxG.height/2-20,250,"not Now\npress [7](debug1)",20);
    TempText.color = 0xFF3A3A3A;
    add(TempText);
}
var Control = Controls.instance;
function onUpdate(e) {
	if (Control.justPressed('debug_1')){
		//playSnd("splat");
		//MusicBeatState.resetState();
        MusicBeatState.switchState(new MasterEditorMenu());
    }
	
}