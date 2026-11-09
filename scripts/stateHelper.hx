package scripts;
import psychlua.LuaUtils;
import Type;
import Main;
import Reflect;
import flixel.FlxG;
import psychlua.HScript;
import crowplexus.iris.Iris;
import haxe.io.Path;
import openfl.Lib;

import backend.Mods;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import states.editors.MasterEditorMenu;
//import backend.ui.PsychUIBox;
//import backend.ui.PsychUIButton;
//import backend.ui.PsychUICheckBox;
//import backend.ui.PsychUINumericStepper;

//import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
//import backend.CacheSystem;
var fakeLib = false;
var _NativeFileSystem = Type.resolveClass("mikolka.funkin.custom.NativeFileSystem");
if (_NativeFileSystem==null){
    import sys.FileSystem as FileSystem;
    // #if OPENFL_LOOKUP
    import lime.utils.Assets;
    import openfl.utils.Assets as OpenFlAssets;
    // #end
    
    //import cutscenes.DialogueBoxPsych;
     function addCwd(directory:String):String
	{
		//#if (desktop || web)
        if (["windows_x86","windows","linux","mac","browser"].contains(LuaUtils.getBuildTarget()))
		    return directory;
        else{
		//#else
            var cwd = Sys.getCwd();//idk how port this
            var test_cwd = Path.removeTrailingSlashes(cwd);
            if (directory.indexOf(test_cwd)==0)
                return directory;
            return Path.addTrailingSlash(cwd) + directory;
        }
		//#end
	}
    function getPathLike(path:String):Null<String> {
		var path = addCwd(path);// fix ios
		
		//var dir = Path.directory(path);
		//for(exclude in excludePaths){
		//	if(dir.startsWith(exclude)) 
		//		return null;
		//	
		//}
		if(FileSystem.exists(path)) return path;
//
		var baseParts:Array<String> = path.split('\\').join('/').split('/');
		var keyParts = [];
		if (baseParts.length == 0) return null;
//
		//while(!FileSystem.exists(baseParts.join("/")) && baseParts.length != 0)
		//	keyParts.insert(0, baseParts.pop());
////
		//return findFile(baseParts.join("/"),keyParts);
	}
    //function findFile(base_path:String,keys:Array<String>):Null<String> {
	//	var nextDir:String = base_path;
	//	for (part in keys) {
	//		if (part == '') continue;
//
	//		var foundNode = findNode(nextDir, part);
//
	//		//if (foundNode == null) {
	//		//	excludePaths.push(nextDir+"/"+part);
	//		//	return null;
	//		//}
	//		nextDir = nextDir+"/"+foundNode;
	//	}
//
	//	return nextDir;
	//}
    //function findNode(dir:String, key:String):Null<String> {
	//	try {
	//		var allFiles:Array<String> = FileSystem.readDirectory(dir);
	//		var fileMap:Map<String, String> = new Map();
//
	//		for (file in allFiles) {
	//			fileMap.set(file.toLowerCase(), file);
	//		}
//
	//		return fileMap.get(key.toLowerCase());
	//	} catch (e:Dynamic) {
	//		return null;
	//	}
	//}

    //function getPathLike(path:String)
	//{
	//	if (FileSystem.exists(path))
	//		return path;
	//	return null;
	//}
    _NativeFileSystem = {
        //"findNode":findNode,
        //"findFile":findFile,
        //"addCwd":addCwd,
        //"getPathLike":getPathLike,
        "exists":(p)->{
            return getPathLike(p)!=null;
        },
        "readDirectory":(p)->{
            if (getPathLike(p)!=null)
                return FileSystem.readDirectory(p);
            return [];
        },
        "isDirectory":(p)->{
            return FileSystem.isDirectory((directory));
        },
        "getContent":(path)->{
            var isModded = path.indexOf("mods")==0;
            // #if OPENFL_LOOKUP
            if (!isModded)
            {
                var openfl_content = (openFlAssets.contains(path)) ? Assets.getText(path) : null;
                if (openfl_content != null)
                    return openfl_content;
            }
            // #end

            // #if NATIVE_LOOKUP
            // #if OPENFL_LOOKUP
            if (!isModded)
                return null;
            // #end
            var sys_path = getPathLike(path);
            var sys_res = sys_path != null ? File.getContent(sys_path) : null;
            if (sys_res != null)
                return sys_res;
            trace("Fake_NativeFileSystem: Text file doesn't exist!! ", path);
            // #end
            return null;
            
        }
    };
    fakeLib = true;
}
this.set("NativeFileSystem",_NativeFileSystem);

var _CacheSystem = Type.resolveClass("backend.CacheSystem");
if (_CacheSystem==null){
    _CacheSystem = {
        "loadSound":(p,b,t)->{
            p = p.split(".ogg")[0];
            var a = p.split("/");
            var k = [];
            k.push(a[0]);
            k.push(a[1]);
            var mp = [];
            for (i in 2...a.length){
                mp.push(a[i]);
            }
            //addOutText(mp);
            return Paths.returnSound(mp.join("/"));
        }
    };
    fakeLib = true;
}
this.set("CacheSystem",_CacheSystem);


var HXmodules = [];

function onCreatePost() {
    var news = true;
    for (i in Iris.instances){
        if (i.config.name.indexOf(Path.normalize(this.config.name).split("/").pop().split("_")[0])>=0&&i!=this)
            news = false;
        //debugPrint(i.config.name+" "+this.config.name);
        //debugPrint((i!=this)+" "+(news));
    }
	if (news) {
        startInjectSignals();
    }
    else{
        trace("no duplicates");
    }
}

function startInjectSignals() {
    FlxG.signals.preUpdate.add(signalOnUpdate);
    FlxG.signals.postUpdate.add(signalOnUpdatePost);
    FlxG.signals.preDraw.add(signalOnDraw);
    FlxG.signals.postDraw.add(signalOnDrawPost);
    FlxG.signals.preStateCreate.add(signalOnCreate);
    FlxG.signals.postStateSwitch.add(signalOnSwitchPost);
    FlxG.signals.preStateSwitch.add(signalOnSwitch);
    FlxG.signals.focusGained.add(signalOnFocus);
    FlxG.signals.focusLost.add(signalOnFocusLost);
    FlxG.signals.gameResized.add(signalOnGameResized);
    Iris.instances.set(this.config.name+"_cloned",this);
    //trace("hi "+this.config.packageName);
    //FlxG.signals.preStateSwitch.add(function() {
    //trace("Попытка переключения. Текущее: " + FlxG.state + " Запрошено: " + FlxG.game._requestedState);
    //});
}
var customState = "test";
var customArgs = [];
function createModules(?dirs,?ss) {

    //trace("hi "+this.config.name);
    var state = Type.getClassName(Type.getClass((ss==null)?FlxG.state:ss));
    state = state=="backend.MusicBeatState"?customState:state;
    var mods = Mods.globalMods.copy();
    if (mods.contains(Mods.currentModDirectory))
        mods.remove(Mods.currentModDirectory);
    mods = mods.concat([Mods.currentModDirectory]);
    //trace(mods);
	for (i in mods) {
        if (dirs==null){
            var paths = "mods/" + i + ((ss==null)?"/states/":"/substates/")+state+"/";
            //trace(NativeFileSystem.readDirectory(paths));
            for (n in NativeFileSystem.readDirectory(paths)){
                trace("hi S "+n);
                if (n.indexOf(".hx")>0)
                    StartHXModule(n.split(".hx")[0],paths);
            }
        }else{
            for (m in dirs)
            {
                var path = "mods/" + i + "/" + m +"/modules/";
                for (n in NativeFileSystem.readDirectory(path+state+"/")){
                    trace("hi "+n);
                    if (n.indexOf(".hx")>0)
                        StartHXModule(n.split(".hx")[0],path+state+"/");
                }
                for (n in NativeFileSystem.readDirectory(path+"global/")){
                    trace("hi G "+n);
                    if (n.indexOf(".hx")>0)
                        StartHXModule(n.split(".hx")[0],path+"global/");
                }
            }
        }
    }
    
}

function callHX(fun,?arrs){
    try{
        arrs ??= [];
        //var r;
        for (hx in HXmodules)
            if (hx.exists(fun))
                try{
                    hx.call(fun,arrs);
                    
                }catch (e:Dynamic){
                    trace(e);
                    //e = Std.string(e).split(":").join(":\n\t\t");
                    //addOutText("err "+e,true,true);
                } 
    }catch (e:Dynamic){
        trace(e);
    }
}

var objThis;
var interp = this.interp;
var gVars =  ["null"=>null];
function StartHXModule(module,?dir) {
    //dir ??= "scripts";
    //var scriptToLoad = Paths.modFolders(dir+module+".hx");
    var scriptToLoad = dir+module+".hx";
    //trace("try "+module);
    
	if (NativeFileSystem.exists(scriptToLoad)) {
		if (Iris.instances.exists(scriptToLoad)) {
            Iris.instances.get(scriptToLoad)?.destroy();
            Iris.instances.remove(scriptToLoad);
        }
        try {
            DeltaRuneCode = new HScript(null, scriptToLoad,null,true);
            DeltaRuneCode.interp.parentInstance = dir.indexOf("/substates/")==-1?FlxG.state:FlxG.state.subState;
            DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
            DeltaRuneCode.interp.showPosOnLog = false;
            DeltaRuneCode.set("getThisVar",(V)->{DeltaRuneCode.interp.resolve(V);});
            
            DeltaRuneCode.set("CacheSystem",CacheSystem);//with fake
            DeltaRuneCode.set("NativeFileSystem",NativeFileSystem);//with fake
            DeltaRuneCode.set("StateHelper",objThis);
            DeltaRuneCode.set("setGlobalVar",function(_var,?_r){
                gVars.set(_var,_r ?? DeltaRuneCode.interp.resolve(_var));
                for (h in HXmodules)
                    h.set(_var,_r ?? DeltaRuneCode.interp.resolve(_var));
            });
            for (m in gVars.keys())
                DeltaRuneCode.set(m,gVars.get(m));
            try {
                 DeltaRuneCode.set("MyExtendIs",(V)->{
                    //if (Type.typeOf(V)==)
                    DeltaRuneCode.interp.parentInstance = Type.createEmptyInstance(Type.resolveClass(V));  
                    DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
                    //Reflect.setField(obj,"super",DeltaRuneCode.interp.parentInstance);
                    DeltaRuneCode.set("super",Reflect.makeVarArgs(function (?args){ 
                        DeltaRuneCode.interp.parentInstance = Type.createInstance(Type.getClass(DeltaRuneCode.interp.parentInstance),args ?? []);  
                        DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
                        //Reflect.setField(obj,"super",DeltaRuneCode.interp.parentInstance);
                    }));
                    DeltaRuneCode.set("MyExtendIs",(V)->{return;});
                });
				var ret:Dynamic = DeltaRuneCode.execute();
				DeltaRuneCode.returnValue = ret;
			} catch(e:IrisError) {
				DeltaRuneCode.returnValue = null;
				DeltaRuneCode.destroy();
                trace(e);
                return;
				//throw e;
			}
            HXmodules.push(DeltaRuneCode);
            return DeltaRuneCode;
        } catch (e:Dynamic) {
            trace(e);
            //addOutText(e,true);
            var newScript:HScript = Iris.instances.get(dir+module+".hx");
            if (newScript != null)
                newScript?.destroy();
            return;
        }
		
	} else {
		trace("hx file not found", 0xFF0000);
		return;
	}
}
function getLV(L) {
	return interp.locals.get(L).r;	
	//return this.interp.resolve(L);	
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
function switchCustomState(_state,?args) {
    customState = _state;
    customArgs = args ;
    MusicBeatState.switchState(new MusicBeatState());
    
}
function seatchLastSubState(state) {
    return state.subState==null?state:seatchLastSubState(state.subState);
}
var customSubState;
var subStates = [];
var deffollowLerp = 1;
function openCustomSubstate(name,?pause,?_state) {// please no use // in progress
    trace("open CSS-"+name);
    _state ??= seatchLastSubState(FlxG.state);
    customSubState = new MusicBeatSubstate();
    if(pause){
        deffollowLerp = FlxG.camera.followLerp;
        FlxG.camera.followLerp = 0;
        _state.persistentUpdate = false;
        //_state.persistentDraw = false;
    }
    subStates.push({name: name,pause: pause,subState: customSubState,state: _state});
    callHX("onCustomSubstateCreate",[customSubState,name]);
    _state.closeSubState();
    _state.openSubState(customSubState);
    callHX("onCustomSubstateCreatePost",[customSubState,name]);
}
function closeCustomSubstate(name) {
    trace("close CSS-"+name);
    var SS;
    for (s in subStates){
        if (s.name == name){
            SS = s;
            break;
        }
    }
    if(SS.pause){
        FlxG.camera.followLerp = deffollowLerp;
        SS.state.persistentUpdate = true;
        //SS.state.persistentDraw = true;
    }
    subStates.remove(SS);
    callHX("onCustomSubstateDestroy",[SS.subState,SS.name]);
    SS.subState?.destroy();
    SS.state.closeSubState();
}
objThis = {};
for (f in this.interp.variables.keys()){
    Reflect.setField(objThis,f,this.get(f));
}

var switchTimer = 5;
function signalOnCreate(_state) {
    createModules();
    createModules(["scripts","custom_events","custom_notetypes","characters"]);
    callHX("onCreate",customArgs);
    _state.subStateOpened.add(signalOnSSCreate);
    _state.subStateClosed.add(signalOnSSDestroy);
    customArgs = [];
    trace("created "+(Type.getClassName(Type.getClass(FlxG.state))=="backend.MusicBeatState"?("("+customState+")"):Type.getClassName(Type.getClass(FlxG.state))));
    switchTimer = 5;
}
function signalOnSwitch() {
    callHX("onSwitch");
    signalOnDestroy();
    trace("switched");
    //trace(FlxG.game._requestedState);
    if (switchTimer<0){
        //FlxG.game._requestedState = new MasterEditorMenu();
        //FlxG.game._skipSplash = true;
        //FlxG.game.resetGame();//crash loops fix
        //FlxG.game.switchState();//crash loops fix
        //FlxG.game.update();//crash loops fix
        var _Main = findChildAtClass(Lib.current,"Main");
        _Main.init();
        trace("try");
        switchTimer = 5;
    }
    switchTimer -=1;
}
function signalOnSwitchPost() {
    callHX("onCreatePost");
    trace("postswitched");
    switchTimer = 5;
}
function signalOnSSCreate(SS) {
    createModules(null,SS);
    callHX("onSubstateCreate",[SS]);
    SS.subStateOpened.add(signalOnSSCreate);
    SS.subStateClosed.add(signalOnSSDestroy);
    trace("preSS "+Type.getClassName(Type.getClass(SS)));
}
function signalOnSSDestroy(SS) {
    callHX("onSubstateDestroy",[SS]);
    var i = 0;
        while (i< HXmodules.length){
            var m = HXmodules[i];
            try{
            if (m?.interp.parentInstance==SS){
                m?.destroy();
                HXmodules.remove(m);
            }
            }catch (e:Dynamic) {
                    trace(e);
                }
            i += 1;
        }
    trace("postsSS "+Type.getClassName(Type.getClass(SS)));
}
function signalOnUpdate() {
    var e = FlxG.elapsed;
    var paused = false;
    SS = subStates.copy();
    SS.reverse();
    for (s in SS){
        callHX("onCustomSubstateUpdate",[s.subState,s.name,e]);
        paused = s.pause;
        if (paused) break;
    }
    if (!paused)callHX("onUpdate",[e]);
}
function signalOnUpdatePost() {
    var e = FlxG.elapsed;
    var paused = false;
    SS = subStates.copy();
    SS.reverse();
    for (s in subStates){
        callHX("onCustomSubstateUpdatePost",[s.subState,s.name]);
        paused = s.pause;
        if (paused) break;
    }
    if (!paused)callHX("onUpdatePost",[e]);
}
function signalOnDraw() {
    callHX("onDraw");
}
function signalOnDrawPost() {
    callHX("onDrawPost");
}
function signalOnFocus() {
    callHX("onFocus");
}
function signalOnFocusLost() {
    callHX("onFocusLost");
}
function signalOnGameResized(w,h) {
    callHX("OnGameResized",[w,h]);
}
function signalOnDestroy() {
    callHX("onDestroy");
    for (i in HXmodules){
        i?.destroy();
    }
    subStates = [];
    HXmodules = [];
}
function findChildAtClass(bob:Sprite,class:String)
    {
    var len = bob.numChildren ;
    for (i in 0...len)
        {
        var obj = bob.getChildAt(i);
        var cll = Type.getClassName(Type.getClass(obj));
        trace(cll);
        if (cll == class)
            {
            trace("     true");
            return obj;
            }
        }
    }