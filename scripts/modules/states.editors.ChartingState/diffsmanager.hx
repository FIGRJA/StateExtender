//package scripts.modules.states.editors.ChartingState;

import haxe.ds.GenericStack.GenericCell;
import haxe.zip.Reader;
import backend.Difficulty;
import backend.Highscore;
import backend.Song;
import states.editors.content.BasePrompt;
import backend.ui.PsychUIDropDownMenu;
import backend.ui.PsychUIInputText;
import mikolka.funkin.custom.FreeplayMeta;
import haxe.Unserializer;
import haxe.Serializer;
import Reflect;
import haxe.io.Path;
import haxe.Log;

    var clickStyle:UIStyleData = {
    bgColor: FlxColor.BLACK,
    textColor: FlxColor.WHITE,
    bgAlpha: 1
};
    var hoverStyle:UIStyleData = {
    bgColor: FlxColor.WHITE,
    textColor: FlxColor.BLACK,
    bgAlpha: 1
};
    var normalStyle:UIStyleData = {
    bgColor: 0xFFAAAAAA,
    textColor: FlxColor.BLACK,
    bgAlpha: 1
};
    var dangerStyle:UIStyleData = {
	bgColor: FlxColor.RED,
	textColor: FlxColor.WHITE,
    bgAlpha: 1
};
    var disabledStyle:UIStyleData = {
	bgColor: 0xFF3B3B3B,
	textColor: FlxColor.WHITE,
    bgAlpha: 1
};
    var invisibleStyle:UIStyleData = {
	bgColor: 0xC300FF,
	textColor: FlxColor.WHITE,
    bgAlpha: 0
};
var diffCHbtn;
var unSafeCharts = [""=>null];
var GEvents = ["this"=>null];
function onCreateTrue() {
setVar("unSafeCharts",unSafeCharts);
setVar("GEvents",GEvents);
    //for (i in ["fileDialog","loadChart","reloadNotesDropdowns","prepareReload","upperBox","saveChart"])
    //    this.set(i,Reflect.field(FlxG.state,i));
    mainBox.getTab('Song').menu.add(new PsychUIButton(20 + 130,210,"Manage Difficulties",()->{
        openSubState(new BasePrompt(420,160,'Manage Difficulties.',manageSubState));
        //addOutText("hii");
    },120,20));
    diffCHbtn = new PsychUIButton(20 + 130,210+20,"cur: "+Difficulty.getString(),()->{
        nextChart(-1);
    },120,20);
    diffCHbtn.normalStyle = invisibleStyle;
    diffCHbtn.hoverStyle  = invisibleStyle;
    diffCHbtn.clickStyle  = invisibleStyle;
    mainBox.getTab('Song').menu.add(diffCHbtn);


    mainBox.getTab('Song').menu.add(new PsychUIButton(20 + 290,25,"load GEvents",()->{
        loadEv();
        getVar("reloadNotesPreview")();
    },90,20));
    setVarH("menuY",getVarH("menuY")+30);
    //trace(["a","b"].concat(['b','c']));
}
var cliced = false;
function onUpdate(e) {
    if (FlxG.mouse.justPressedRight){
        var overlapped:Bool = (FlxG.mouse.overlaps(diffCHbtn.bg, diffCHbtn.camera));
        if (overlapped&&!cliced){
            cliced = true;
            nextChart(1);
        }
    }else{
        cliced = false;
    }
    
}
function nextChart(vec) {
    trace(vec);
    var cur = Difficulty.list[bound(Difficulty.list.indexOf(Difficulty.getString())+(vec),Difficulty.list.length)];
    //addOutText(Difficulty.list.indexOf(Difficulty.getString())+(1));
    updateChartData();
    var copy:SwagSong = Unserializer.run(Serializer.run(PlayState.SONG));//deepseak ))
    unSafeCharts.set(Difficulty.getString(),{chart: copy,chartPath:Song.chartPath});
    loadS(cur,true);
    
}
function bound(i,max) {
    //addOutText(i%max);
    return (max+i)%max;
}
function manageSubState(state) {
    var btnY = 360;
    var selected = Difficulty.getString();//"--None--";
    var selId = Difficulty.getString();
    var btn0:PsychUIButton = new PsychUIButton(0, btnY+30, 'cancel', ()->{
        //if (selected==null)return;
        //saveAs(pack, metadata);
        state.close();
    });
    btn0.screenCenter(0x01);
    btn0.x += 125;
    btn0.cameras = state.cameras;
    btn0.normalStyle = dangerStyle;
    state.add(btn0);
    var btn1:PsychUIButton = new PsychUIButton(0, btnY, 'new', ()->{
        //if (selected==null)return;
        //saveAs(pack, metadata);
        openSubState(new BasePrompt(420,160,'Choose an action.',(s)->{saveAs(s,createNewDiff);}));
        state.close();
    });
    btn1.screenCenter(0x01);
    btn1.x -= 125;
    btn1.cameras = state.cameras;
    state.add(btn1);
    var btn2:PsychUIButton = new PsychUIButton(0, btnY, 'load', ()->{
        if (selected=="--None--")return;
        openSubState(new BasePrompt(420,160,'Choose an action.',(s)->{saveAs(s,()->{loadS(selected);});}));

        //saveAs(pack, metadata);
        state.close();
    });
    btn2.screenCenter(0x01);
    btn2.x += 125;
    btn2.cameras = state.cameras;
    state.add(btn2);
    function changeStyle() {
        for (i in [btn2]){
            i.normalStyle = selected=="--None--"?disabledStyle:normalStyle;
            i.hoverStyle = selected=="--None--"?disabledStyle:hoverStyle;
            i.clickStyle = selected=="--None--"?disabledStyle:clickStyle;
        }
    }
    var test = new PsychUIDropDownMenu(FlxG.width/2-50,btnY,["--None--"].concat(Difficulty.list),(a,b)->{
        //trace(a);
        //trace(b);
        selected = b;
        changeStyle();
        //btn1.normalStyle = dangerStyle;
    });
    test.selectedLabel = selected;
    test.screenCenter(0x01);
    test.cameras = state.cameras;
    state.add(test);
    changeStyle();
}
function createNewDiff() {
    openSubState(new BasePrompt(420,160,'name new Diff.',(state)->{

        var btnY = 360;
        var canW = false;
        var diffInputText = new PsychUIInputText(FlxG.width/2-100-30, btnY, 200, " ", 8);
        diffInputText.onChange = (l,s)->{canW = true;};
        diffInputText.cameras = state.cameras;
        state.add(diffInputText);
        var btn2:PsychUIButton = new PsychUIButton(0, btnY, 'add', ()->{
            if (!canW) return;
            Difficulty.list.push(diffInputText.text);
            PlayState.storyDifficulty = Difficulty.list.length-1;
            var arr = Song.chartPath.split("/");
            arr.pop();
            var song = arr.pop();
            var songLowercase:String = Paths.formatToSongPath(song.split(".")[0]);
            Song.chartPath = arr.concat([song,song+Paths.formatToSongPath(diffInputText.text)+".json"]).join("/");

            state.close();
            //action();
        });
        btn2.screenCenter(0x01);
        btn2.x += 125;
        btn2.cameras = state.cameras;
        btn2.normalStyle = disabledStyle;
        btn2.hoverStyle = disabledStyle;
        btn2.clickStyle = disabledStyle;
        state.add(btn2);
        var btn3:PsychUIButton = new PsychUIButton(0, btnY+30, 'cancel', ()->{
            state.close();
        });
        btn3.screenCenter(0x01);
        btn3.x += 125;
        btn3.cameras = state.cameras;
        btn3.normalStyle = dangerStyle;
        state.add(btn3);
        //addOutText("NO FUNCTION");
    }));
    
}
function loadS(diff,?unsafe=false) {
    try{
        trace(Song.chartPath);
        
        //Log.trace(#if linux "hi"#else"hello"#end);
        var olds = false;
        var PathS = Song.chartPath;
        var reloadedChart:SwagSong ;
        if (unsafe&&unSafeCharts.exists(diff)){
            addOutText("unSafe");
            //diff = Difficulty.list[bound(Difficulty.list.indexOf(diff)+(1),Difficulty.list.length)];
            reloadedChart = unSafeCharts.get(diff).chart;
            PathS = unSafeCharts.get(diff).chartPath;
            //var PathS = reloadedChart.chartPath;
        }
        else{
            //addOutText("Safe");
            var arr = Path.normalize(Song.chartPath).split("/");
            trace(arr);
            //addOutText("/",true);
            //addOutText(Song.chartPath,true);
            arr.pop();
            var songLowercase = arr.pop();
            //var songLowercase:String = Paths.formatToSongPath(song.split(".")[0]);
            try{
                var useErect = FreeplayMeta.getMeta(songLowercase).allowErectVariants;
                if(useErect){
                    var curDiffText = diff;
                    //trace(songLowercase.indexOf("-erect"));
                    if(songLowercase.indexOf("-erect")==(songLowercase.length-6) && curDiffText != "Erect" && curDiffText != "Nightmare"){
                        //not nightmare anymore
                        songLowercase = songLowercase.substring(0,songLowercase.length-"-erect".length);
                        olds = true;
                    }
                    else if(songLowercase.indexOf("-erect")==-1 && (curDiffText == "Erect" || curDiffText == "Nightmare")){
                        //now it's nightmare
                        songLowercase = songLowercase+"-erect";
                        olds = true;
                    }
                }
                }catch(e:Dynamic){trace(e);}
            var poop:String = Highscore.formatSong(songLowercase, Difficulty.list.indexOf(diff));
            //var reloadedChart:SwagSong = Song.getChart(poop);
            PathS = Paths.getPath(Path.join(["data",songLowercase,poop+".json"]));
            reloadedChart =  Song.parseJSON(NativeFileSystem.getContent(PathS));
            trace(poop);
        }
        //trace(reloadedChart);
        var Sev = Unserializer.run(Serializer.run(PlayState.SONG.events));
        //trace(Sev);
        //reloadedChart.events ??= Sev;
        loadChart(reloadedChart);
        //super.events = Sev;
        //trace(events.length);
        //reloadNotesDropdowns();
        prepareReloadW(olds);
        if (events.length==0){
            //trace(GEvents.get("this"));
            //for (event in GEvents.get("this"))
            //trace(Sev);
            for (event in Sev){
               // trace(event);
                super.events.push(createEvent(event));
            }
        }
        Song.chartPath = PathS;
        addOutText("loaded "+diff+" chart!");
        CharterHelper.upgradeCW(super.curSec,2);
        PlayState.storyDifficulty = Difficulty.list.indexOf(diff);
        diffCHbtn.text.text = "cur: "+Difficulty.getString();
        getVar("reloadNotesPreview")();
    }catch(e:Dynamic){
                trace(e);
                e = Std.string(e).split(":").join(":\n\t\t");
                addOutText("err "+e,true,true);
                addOutText("",false,true);
    }
}
function saveAs(state,action) {
    var btnY = 360;
    var btn0:PsychUIButton = new PsychUIButton(0, btnY, 'save', ()->{
        if(!fileDialog.completed) return;
        upperBox.isMinimized = true;
        upperBox.bg.visible = false;

		saveChart();
        state.close();
        if (Song.chartPath != null)
            action();
        else{
            fileDialog.onComplete = ()->{
                action();
            };
            fileDialog.onCancel = ()->{
                addOutText("NOT COUNTINUED");
            };
            fileDialog.onError = ()->{
                addOutText("NOT COUNTINUED",true);
            };
        }
    });
    btn0.screenCenter(0x01);
    btn0.x -= 125;
    btn0.cameras = state.cameras;
    state.add(btn0);
    var btn1:PsychUIButton = new PsychUIButton(0, btnY+30, 'saveAs', ()->{
        if(!fileDialog.completed) return;
        upperBox.isMinimized = true;
        upperBox.bg.visible = false;

		saveChart(false);
        state.close();
        
        fileDialog.onComplete = ()->{
            action();
        };
        fileDialog.onCancel = ()->{
            addOutText("NOT COUNTINUED");
        };
        fileDialog.onError = ()->{
            addOutText("NOT COUNTINUED",true);
        };
    });
    btn1.screenCenter(0x01);
    btn1.x -= 125;
    btn1.cameras = state.cameras;
    state.add(btn1);
    var btn2:PsychUIButton = new PsychUIButton(0, btnY, 'proced', ()->{
        state.close();
        action();
    });
    btn2.screenCenter(0x01);
    btn2.cameras = state.cameras;
    btn2.normalStyle = dangerStyle;
    state.add(btn2);
    var btn3:PsychUIButton = new PsychUIButton(0, btnY, 'cancel', ()->{
        state.close();
    });
    btn3.screenCenter(0x01);
    btn3.x += 125;
    btn3.cameras = state.cameras;
    btn3.normalStyle = dangerStyle;
    state.add(btn3);
}
function prepareReloadW(?force)
	{
        //updateChartData();
		updateJsonData();
        var plaing = FlxG.sound.music.playing;
        var len = FlxG.sound.music.lenght;
		loadMusic();
		reloadNotes();
		onChartLoaded();
		updateHeads(true);
        setSongPlaying(plaing);
		
		autoSaveTime = 0;
        if (force||len != FlxG.sound.music.lenght){
		    Conductor.songPosition = 0;
		    if(FlxG.sound.music != null) FlxG.sound.music.time = 0;
		    curSec = 0;
        }
        else 
            {if
                (FlxG.sound.music != null) vocals.time = opponentVocals.time = FlxG.sound.music.time = Conductor.songPosition - Conductor.offset;
            }
		loadSection();
		forceDataUpdate = true;
	}

    
function loadEv() {
try{
    var filePath:String = Paths.getPath("data"+"/"+Paths.formatToSongPath(songNameInputText.text)+"/"+"events.json");
    var eventsFile:SwagSong = Song.parseJSON(NativeFileSystem.getContent(filePath), filePath.substr(filePath.lastIndexOf("/")));
    if(eventsFile == null || Reflect.hasField(eventsFile, 'scrollSpeed') || eventsFile.events == null)
    {
        addOutText('Error: File loaded is not a Psych Engine chart/events file.', true);
        return;
    }

    var loadedEvents:Array<Dynamic> = eventsFile.events;
    if(loadedEvents.length < 1)
    {
        addOutText('Events file loaded is empty.', true);
        return;
    }
    //for (event in events)
    //    {
    //        if(event != null)
    //        {
    //            event.destroy();
    //            selectedNotes.remove(event);
    //        }
    //    }
    //undoActions = [];
    //events = [];
//
    //for (event in loadedEvents)
    //    events.push(createEvent(event));
//
    //softReloadNotes();
    //state.close();
    //addOutText('Events replaced successfully!');
    openSubState(new BasePrompt(420,160,'Events Found! Choose an action.',
        (state:BasePrompt)->
        {
            //addOutText("open");
            var btnY = 390;
            var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Replace All', function()
            {
                for (event in events)
                {
                    if(event != null)
                    {
                        event.destroy();
                        selectedNotes.remove(event);
                    }
                }
                undoActions = [];
                events = [];
//
                for (event in loadedEvents)
                    events.push(createEvent(event));
                
                //GEvents.set("this",loadedEvents.copy());

                softReloadNotes();
                state.close();
                addOutText('Events loaded successfully!');
            });
            btn.normalStyle.bgColor = FlxColor.RED;
            btn.normalStyle.textColor = FlxColor.WHITE;
            btn.screenCenter(0x01);
            btn.x -= 125;
            btn.cameras = state.cameras;
            state.add(btn);
            
            var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Add', function()
            {
                for (event in loadedEvents)
                    events.push(createEvent(event));
                //GEvents.set("this",loadedEvents.copy());
//
                softReloadNotes();
                state.close();
                addOutText('Events added successfully!');
            });
            btn.screenCenter(0x01);
            btn.cameras = state.cameras;
            state.add(btn);
    
            var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Cancel', state.close);
            btn.screenCenter(0x01);
            btn.x += 125;
            btn.cameras = state.cameras;
            state.add(btn);
        }
    ));
}catch(e:Dynamic){
    addOutText(e,true);
}
}