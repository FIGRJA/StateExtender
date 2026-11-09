//package scripts.modules.states.editors.ChartingState;
import Reflect;
import tjson.TJSON;
import backend.Difficulty;
import states.editors.content.BasePrompt;
import states.editors.content.VSlice;
import states.editors.content.PsychJsonPrinter;
import backend.ui.PsychUIDropDownMenu;
import flixel.util.FlxSort;
import haxe.format.JsonPrinter;
import haxe.Unserializer;
import haxe.Serializer;

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

function onCreatePost() {
    for (b in upperBox.getTab('File').menu){
        if (b.label == "  V-Slice to Psych..."){
            //for (i in ["fileDialog","upperBox","fileDialog","overwriteCheck","overwriteSavedSomething","openSubState","selectedNotes","PsychUIButton","createEvent","events","undoActions","softReloadNotes","Difficulty","loadChart","reloadNotesDropdowns","prepareReload"])
            //    this.set(i,Reflect.field(FlxG.state,i));
            b.normalStyle.bgColor = 0xFFADA0B1;
            b.onClick = ()->{
                addOutText("hi",false,true);
                if(!fileDialog.completed) return;
                upperBox.isMinimized = true;
                upperBox.bg.visible = false;

                fileDialog.open('chart.json', 'Open a V-Slice Chart file',null, ()->
                {
                    //var chart = cast Json.parse(fileDialog.data);
                    //addOutText("hi2");
                    var chart = TJSON.parse(fileDialog.data);
                    if(chart == null || chart.version == null || chart.notes == null || chart.scrollSpeed == null)
                    {
                        addOutText('Error: File loaded is not a valid FNF V-Slice chart.', true);
                        return;
                    }
                    var fEx = false;
                    function nextMeta() {
                        //var metadata = cast Json.parse(fileDialog.data);
                        var metadata = TJSON.parse(fEx?NativeFileSystem.getContent(fileDialog.path.split("-chart.json")[0]+"-metadata.json"):fileDialog.data);
                        if(metadata == null || metadata.version == null || metadata.playData == null || metadata.songName == null ||
                            metadata.playData.difficulties == null || metadata.timeChanges == null || metadata.timeChanges.length < 1)
                        {
                            addOutText('Error: File loaded is not a valid FNF V-Slice metadata.', true);
                            return;
                        }
                        //addOutText("hi3");
                        
                        try
                        {
                            
                            var pack:PsychPackage = convert(chart, metadata);
                            choseAA(pack, metadata);
                           
                        }
                        catch(e:Exception)
                        {
                            addOutText('Error: '+e.message, true);
                            trace(e.stack);
                        }
                    }
                    //fEx = NativeFileSystem.exists(fileDialog.path.split("-chart.json")[0]+"-metadata.json");
                    //trace(fileDialog.path.split("-chart.json")[0]+"-metadata.json");
                    //trace(NativeFileSystem.exists(fileDialog.path));
                    //trace(fEx);
                    //never true
                    if (fEx)
                        nextMeta();
                    else
                        fileDialog.open(fileDialog.path.split("-chart.json").join("-metadata.json"), 'Open a V-Slice Metadata file',null, nextMeta);                        
                });
            }
        }
    }
}
function choseAA(pack, metadata) {
    openSubState(new BasePrompt(420,160,'Choose an action.',
    (state:BasePrompt)->
    {
    //addOutText("hi3");
        var btnY = 390;
        var selected ;
        var btn1:PsychUIButton = new PsychUIButton(0, btnY, 'Replace All', ()->
        {
            if (selected==null)return;
            for (event in events)
            {
            	if(event != null)
            	{
            		event.destroy();
            		selectedNotes.remove(event);
            	}
            }
            super.undoActions = [];
            super.events = [];
            loadChart(pack.difficulties.get(selected));
            reloadNotesDropdowns();
            prepareReload();
            var extraEv = [];
            for (event in pack.events.events){
                //trace(event);
                super.events.push(createEvent(event));
                for(e in event[1])
                    if (!extraEv.contains(e[0])) extraEv.push(e[0]);
            }
            trace(super.events.length);
            //if (getVar("GEvents")!=null)
            //    getVar("GEvents").set("this",Unserializer.run(Serializer.run(pack.events.events)));


            if(eventDropDown != null) {
                for (e in extraEv){
                    var ex = false;
                    //trace(e);
                    for (en in eventsList)
                        if (en[0]==e){ex = true;}
                    if (ex) continue;
                    eventsList.push([e,"auto Genereted\nvalue 1 is json of everything as v-slice\nvalue 2 not used\ntemple by FIGRJA in vsliceEventsImporter"]);
                    eventDropDown.list.push((eventDropDown.list.length)+".* "+e);
                }
                eventDropDown.set_list(eventDropDown.list);    //trace(eventDropDown.list);
            }
            var exN = [];
            for (n in pack.difficulties.get(selected).notes){
                for (nn in n.sectionNotes){
                    if (nn[3]!=null&&!exN.contains(nn))exN.push(nn[3]);
                }
            }
            if(noteTypeDropDown != null){
                for (e in exN){
                    var ex = false;
                    //trace(e);
                    for (en in noteTypes)
                        if (en==e){ex = true;}
                    if (ex) continue;
                    noteTypes.push(e);
                    noteTypeDropDown.list.push((noteTypeDropDown.list.length)+".* "+e);
                }
                noteTypeDropDown.set_list(noteTypeDropDown.list);

            }
            softReloadNotes();
            if (getVar("unSafeCharts")!=null){
                Difficulty.list = [];
                for (d in pack.difficulties.keys()){
                    Difficulty.list.push(d);
                    getVar("unSafeCharts").set(d,{chart: pack.difficulties.get(d),chartPath:null});
                }
                PlayState.storyDifficulty = Difficulty.list.indexOf(selected);
                //trace(getVar("unSafeCharts"));
            }
            state.close();

            getVar("reloadNotesPreview")();
            addOutText('V-Slice chart loaded successfully!');
        });
        btn1.screenCenter(0x01);
        btn1.x -= 125;
        btn1.cameras = state.cameras;
        state.add(btn1);
        //var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Add', function()
        //{
        //	for (event in loadedEvents)
        //		events.push(createEvent(event));

        //	softReloadNotes();
        //	state.close();
        //	showOutput('Chart added successfully!');
        //});
        //btn.screenCenter(X);
        //btn.cameras = state.cameras;
        //state.add(btn);

        var btn2:PsychUIButton = new PsychUIButton(0, btnY, 'saveAs', ()->{
            //if (selected==null)return;
            saveAs(pack, metadata);
            state.close();
        });
        btn2.screenCenter(0x01);
        btn2.x += 125;
        btn2.cameras = state.cameras;
        state.add(btn2);
        var test = new PsychUIDropDownMenu(FlxG.width/2-50,btnY,getArrKeysMap(pack.difficulties),(a,b)->{
            //trace(a);
            //trace(b);
            selected = b;
            for (i in [btn1]){
                i.normalStyle = normalStyle;
                i.hoverStyle = hoverStyle;
                i.clickStyle = clickStyle;
            }
            btn1.normalStyle = dangerStyle;
        });
        selected = test.selected;
        test.screenCenter(0x01);
        test.cameras = state.cameras;
        state.add(test);
        for (i in [btn1]){
            i.normalStyle = disabledStyle;
            i.hoverStyle = disabledStyle;
            i.clickStyle = disabledStyle;
        }
    }
));
}
function saveAs(pack, metadata) {
    if(pack.difficulties != null)
    {
        fileDialog.openDirectory('Save Converted Psych JSONs', ()->
        {
            try{
            var path:String = fileDialog.path.split('\\').join('/');
            if(!path.charAt(path.length-1)=='/') path += '/';

            var diffs:Array<String> = metadata.playData.difficulties.copy();
            var defaultDiff:String = Paths.formatToSongPath(Difficulty.getDefault());
            function nextChart()
            {
                while(diffs.length > 0)
                {
                    var diffName:String = diffs[0];
                    diffs.remove(diffName);
                    if(!pack.difficulties.exists(diffName)) continue;

                    var diffPostfix:String = (diffName != defaultDiff) ? '-$diffName' : '';
                    var chartData:SwagSong = pack.difficulties.get(diffName);
                    var chartName:String = Paths.formatToSongPath(chartData.song) + diffPostfix + '.json';
                    overwriteCheck(path + chartName, chartName, PsychJsonPrinter.print(chartData, ['sectionNotes', 'events']), nextChart, true);
                    return;
                }

                if(pack.events != null)
                {
                    overwriteCheck(path + 'events.json', 'events.json', PsychJsonPrinter.print(pack.events, ['events']), ()->
                    {
                        if(overwriteSavedSomething)
                            addOutText('Files saved successfully to: ${fileDialog.path}!');
                    }, true);
                }
                else if(overwriteSavedSomething)
                    addOutText('Files saved successfully to: ${fileDialog.path}!');
            }
            
            overwriteSavedSomething = false;
            nextChart();
            choseAA(pack, metadata);
        }catch(e:Dynamic){
            addOutText(e,true);
        }
        });
    }
    else addOutText('Error: No difficulties found.');
}
function convert(chart, metadata) {
    var Pchart = VSlice.convertToPsych(chart, metadata);
    var Pevent = Pchart.events;
    Pevent.format = "VEI-v1-EC-figrja";
    //Pevent.events = [];
    var newEvents = [];
    var allEvents = chart.events;
    if (allEvents!=null){
        allEvents.sort(sortByTime);
        for (e in allEvents){
            var vals = ['',''];
            var eName = e.e;
            switch(e.e){
                case "ZoomCamera":// v-slice format by P-Slice
                    eName = "Zoom Camera";
                    vals[0] = [e.v.duration , e.v.zoom].join(",");
                    vals[1] = e.v.ease+(e.v.easeDir ?? "");
                case "FocusCamera":// v-slice format by P-Slice
                    eName = "Target Camera";
                    vals[1] = [e.v.x , e.v.y , e.v.duration , e.v.ease+(e.v.easeDir ?? "")].join(",");
                    vals[0] = Std.string(e.v.char);
                case "SetCameraBop":// v-slice format by P-Slice
                    eName = "Set Camera Bopping";
                    vals[1] = Std.string(e.v.rate);
                    vals[0] = Std.string(e.v.intensity);
                case "PlayAnimation":// need force option !!!
                    eName = "Play Animation";
                    vals[1] = Std.string(e.v.anim);
                    vals[0] = Std.string(e.v.target);
                case "ScrollSpeed":// when e.v.strumline & e.v.absolute we should use?
                    eName = "Change Scroll Speed";
                    vals[1] = Std.string(e.v.scroll);
                    vals[0] = Std.string(e.v.duration);
                //case "SetHealthIcon":// idk .where is use?
                //case "SetTargetBopSpeed":// idk .where is use?
                default:
                    // RETURN ALL FIELDS IN v1 AS JSON

                    //var l = [];
                    //for (i in Reflect.fields(e.v))
                    //    l.push(i+":"+Reflect.field(e.v,i));
                    //vals[0] = l.join(",");
                    vals[0] = PsychJsonPrinter.print(e.v);
                    //vals[0] = JsonPrinter.print(e.v,null," ");
            }
            var Finded = false;
            var i = 0;
            //trace(event);
            while (i<newEvents.length&&!Finded){
                var E = newEvents[i];
                if (Math.abs(E[0]-e.t)<1){
                    E[1].push([eName,vals[0],vals[1]]);
                    Finded=true;
                }
                i += 1;
            }
            if (!Finded){
                newEvents.push([e.t,[[eName,vals[0],vals[1]]]]);
            }
        }
    }
    trace(newEvents.length);
    Pevent.events = newEvents;
    return Pchart;
}
function getArrKeysMap(map) {
    var arr = [];
    for (i in map.keys()){
        arr.push(i);
    }
    return arr;
}
function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.t, Obj2.t);
    }
