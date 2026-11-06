//if (PlayState.SONG.stage!="D3Main") return;
return;// global custom sub state not work corect!
import backend.Controls;
import backend.MusicBeatState;
import psychlua.CustomSubstate;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.StickerSubState;
import mikolka.vslice.freeplay.FreeplayState;
import states.editors.ResultPreviewMenu;

import mobile.objects.TouchZone;
if (Controls.instance.mobileC)
	import mobile.objects.ScrollableObject;

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

var pauseBG:FlxCamera = new FlxCamera(-700, -100, 700, 1500, 1);
var stunAction = false;
var isPause:Bool = false;
var Control = Controls.instance;
//var CurChar = VsliceOptions.LAST_MOD.char_name;//from lua calls;EventLoader:32 getFreeplayCharacter ))
var backed:FlxBackdrop;
var backTimer:FlxText;
var timer:Float;
var freeAction:Array = [];
var inst:FlxSound;
var back:TouchZone;

function onCreatePost() {

//setVF("endScreen","//playSnd");
	pauseBG.angle = -10;
	// pauseBG.visible =false;
	// pauseBG.x = -400;
}

function onUpdate(e) {
	//game.canPause = false;
	if (SuperControls.pressed("ALT")&&SuperControls.pressed("CONTROL")&&SuperControls.pressed("M"))
		StateHelper.openCustomSubstate('GlobalPause', true);
	//if (Control.CHAR_SELECT && PlayState.SONG.song == "songChart"){
	//	//playSnd("splat");
	//	MusicBeatState.resetState();}
	//if (Control.FAVORITE && PlayState.SONG.song != "songChart"){
	//	//playSnd("crowd_cheer_single");
	//	CustomSubstate.openCustomSubstate('END', true);}
}
var curAction:Int = 0;
var pausedSongs = [];
function onCustomSubstateCreate(customSubstate,name) {
	isPause = name == "GlobalPause";
	if (!isPause)
		return;
	FlxG.cameras.add(pauseBG, false);
	timer = 0.2;
	stunAction = false;
	pausedSongs = [];
	for (s in FlxG.sound.list.members.concat([FlxG.sound.music])){
        //if (!s.playing)continue;
        s.pause();
		pausedSongs.push(s);
    }

	backTimer = new FlxText(0, 0, 350, "3", 250, true);
	backTimer.font = Paths.font("fnt_main.ttf");
	//backTimer.cameras = [customSubstate.camera];
	backTimer.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
	backTimer.camera = FlxG.cameras.list[FlxG.cameras.list.length-1];
	// susiCombo.scale.y = 4;
	backTimer.screenCenter(0x11); // XY
	backTimer.antialiasing = false;
	backTimer.alignment = "center";
	backTimer.visible = false;
	customSubstate.add(backTimer);

	// pauseBG.visible =true;
	backed = new FlxBackdrop();

	backed.antialiasing = false;
	//backed.angle = 10;
	// backed.loadGraphic(Paths.image("anim/tv"));
	backed.frames = Paths.getSparrowAtlas("anim/tv");
	backed.velocity.set(-100 * 35 / 36, 100 * 37 / 36);
	backed.scale.set(3, 3);
	//backed.drawBlit = false;
	//backed.spacing.set(backed.height*5/360,-backed.height*7/36);
	backed.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
	backed.animation.play('pog', true);
	backed.camera = pauseBG;
	customSubstate.add(backed);
	var listAct = ["continue", "reset"];
	//if (Control.mobileC) listAct.insert(1,"toCE");
	//if (PlayState.SONG.format != "psych_v1_convert"&&CurChar!="Kris") listAct.insert(1,"toMenu");
	for (act in listAct) {
		var action = new FlxText(0, 0, 500, act, 130, true);
		action.font = Paths.font("fnt_main.ttf");
		action.cameras = [pauseBG];
		action.angle = 10;
		// action.screenCenter(0x11);//XY
		action.x = 200;
		action.y = action.y + freeAction.length * 100 + 600;
		action.antialiasing = false;
		action.alignment = "left";
		customSubstate.add(action);
		freeAction.push(action);
	}
	try {
		// debugPrint(FlxG.sound.list);
		if (inst == null) {
			inst = new FlxSound();
			inst.loadEmbedded(Paths.returnSound("greenroom_detune", "mus"), true);
			inst.volume = 0;
			inst.play();
			FlxG.sound.list.add(inst);
		}
		inst.fadeIn(2);
	} catch (e:Dynamic) {}
	if (Control.mobileC){
		back = new TouchZone( 525, -110,  FlxG.width, FlxG.height*1.5,0xFFFF0000);
		//back.alpha = 0.3;
		back.angle = -10;
		back.camera = game.camOther;
		customSubstate.add(back);

		var button = new TouchZone( 40, (FlxG.height/2)+100,  (FlxG.width/2),  100);
		button.cameras = [pauseBG];
		button.alpha = 0.03;
		button.angle = 10;

		var scroll = new ScrollableObject(0.02, 40, 100, (FlxG.width/2), FlxG.height, button);
		//scroll.alpha = 0.3;
		scroll.angle = 10;
		scroll.cameras = [pauseBG];
		scroll.onPartialScroll.add(delta ->
		{
			curAction -= delta;
			updateText(true);
		});
		scroll.onFullScrollSnap.add(() -> {curAction = Std.int(curAction);updateText();});
		//scroll.onFullScroll.add(delta ->
		//{
		//	if (diffAction == null)
		//		curAction -= delta;
		//	else
		//		curDiffAction -= delta;
		//	timer = 0.001;
		//});
		scroll.onTap.add(() ->
		{
			pressAccept();
		});
		customSubstate.add(scroll);
		customSubstate.add(button);
	}
}


function onCustomSubstateCreatePost(customSubstate,name) {
	if (!isPause)
		return;
	FlxTween.tween(pauseBG, {x: -120, alpha: 1}, 0.2, {ease: FlxEase.circOut});
	updateText();
}

function pressAccept() {
	//playSnd("coin");
	switch (freeAction[Std.int(curAction)].text) {
		case "continue":
			continuem();
		case "restart":
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;
			MusicBeatState.startTransition();
		case "reset":
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;
			//MusicBeatState.startTransition();
			FlxG.resetGame();
        	//MusicBeatState.switchState(new ResultPreviewMenu());
		// PlayState.nextReloadAll = true;
		case "toMenu":
			PlayState.SONG.song = "songChart";
			// FlxG.sound.music.destroy();
			MusicBeatState.startTransition();
		// PlayState.nextReloadAll = true;
		case "toCE":
			game.openChartEditor();
		case "exit":
			CustomSubstate.closeCustomSubstate();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			PlayState.instance.canResync = false;
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			FlxG.camera.followLerp = 0;
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				PlayState.instance.vocals.pause();
			}
			openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker)));
	}
	inst.fadeOut(1);
}
function updateText(?Simply=false) {
	curAction = Math.abs(freeAction.length + curAction) % freeAction.length;
	if (Simply)
		for (i in 0...freeAction.length) {
			freeAction[i].y = 450 + i * 100 - curAction * 100;
			freeAction[i].alpha = 1 - (Math.abs(Std.int(curAction) - i) / 4);
		}
	else
		for (i in 0...freeAction.length) {
			FlxTween.tween(freeAction[i], {y: 450 + i * 100 - curAction * 100, alpha: 1 - (Math.abs(curAction - i) / 4)}, 0.2, {ease: FlxEase.circOut});
		}
	
}
function continuem() {
	
		//playSnd("splat");
		timer = 4;
		//FlxTween.tween(pauseBG, {x: -700, alpha: 0}, 60 / Conductor.bpm, {ease: FlxEase.circOut});
		FlxTween.tween(pauseBG, {x: -700, alpha: 0}, 0.5, {ease: FlxEase.circOut});
		//FlxTween.num(Conductor.songPosition,Conductor.songPosition+((-1*1000*60)/PlayState.SONG.bpm), 1.48, {ease: FlxEase.circOut,onUpdate: ()->{
		//	getVar("D3Main").call("onUpdate",[0]);
		//	FlxG.sound.music.time = Conductor.songPosition;
		//	game.vocals.time = Conductor.songPosition;
		//	game.opponentVocals.time = Conductor.songPosition;
		//	var fakeCrochet:Float = (60 / PlayState.SONG.bpm) * 1000;
		//	game.notes.forEachAlive(function(daNote:Note)
		//	{
		//		var strumGroup:FlxTypedGroup<StrumNote> = game.playerStrums;
		//		if (!daNote.mustPress)
		//			strumGroup = game.opponentStrums;
//
		//		var strum:StrumNote = strumGroup.members[daNote.noteData];
		//		daNote.followStrumNote(strum, fakeCrochet, game.songSpeed / game.playbackRate);
		//	});
		//}} ,num -> Conductor.songPosition = num );
		backTimer.visible = true;
		FlxTimer.loop(0.5, (tim) -> {
			//trace("hi");
			backTimer.text = 3 - tim;
			if (tim == 3){
				StateHelper.closeCustomSubstate('GlobalPause');
				for (s in pausedSongs){
					s.play();
				}
			}

				//CustomSubstate.closeCustomSubstate();
				//game.setSongTime(Conductor.songPosition);
		}, 4);

		inst.fadeOut(1.5, 0, () -> {
			inst.pause();
		});
		//trace("hi");
}
function onCustomSubstateUpdate(customSubstate,name, e) {
	if (!isPause)
		return;
	if (timer > 0) {
		timer -= e;
		return;
	}
	if ((Control.BACK||back?.justPressed)) {
		continuem();

	}
	if (Control.ACCEPT) {
		pressAccept();
		updateText();
	}
	if (Control.UI_UP) {
		curAction -= 1;
		timer = 0.15;
		updateText();
		//playSnd("bump");
	}
	if (Control.UI_DOWN) {
		curAction += 1;
		timer = 0.15;
		updateText();
		//playSnd("bump");
	}
	if (FlxG.mouse.wheel != 0){
		curAction -= FlxG.mouse.wheel;
		//timer = 0.04;
		updateText(true);
		//playSnd("bump");
	}
    if (Control.CHAR_SELECT ){
		//MusicBeatState.resetState();
		inst.pause();
				StateHelper.closeCustomSubstate('GlobalPause');
		//playSnd("splat");
    }
	// debugPrint("                                                           "+curAction);
	//if (timer > 0)
		
}

function onCustomSubstateDestroy(customSubstate,name) {
	if (!isPause)
		return;
	isPause = false;
	backTimer.destroy();
	backed.destroy();
	// pauseBG.visible =false;
	for (act in freeAction)
		act.destroy();
	freeAction = [];
	pauseBG.x = -700;
	curAction = 0;
}

function onDestroy() {}