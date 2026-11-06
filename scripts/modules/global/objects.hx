package scripts.modules.global;


import Type;
import Reflect;
import backend.Mods;
import psychlua.HScript;
import crowplexus.iris.Iris;
import haxe.io.Path;

function onSelfCreate() {
    createObjects();
    setGlobalVar("newObject",newObject);
    setVar("newObject",newObject);
}

function createObjects() {

    var mods = Mods.globalMods.copy();
    if (mods.contains(Mods.currentModDirectory))
        mods.remove(Mods.currentModDirectory);
    mods = mods.concat([Mods.currentModDirectory]);
    //trace(mods);
	for (i in mods) {
        var paths = "mods/" + i + "/objects/";
        //trace(NativeFileSystem.readDirectory(paths));
        CORead(paths);        
    }
    
}
var Objs = [""=>null];
function CORead(paths) {
    for (n in NativeFileSystem.readDirectory(paths)){
        if (n.indexOf(".hx")==(n.length-3)){
            trace("hi Obj "+n);
            //StartHXModule(n.split(".hx")[0],paths);
            Objs.set(n.split(".hx")[0],paths);
        }
        //else if (NativeFileSystem.isDirectory(paths+"/"+n))//idk how use
        //    CORead(paths+"/"+n);
    }
}

function StartHXObj(module,?dir) {
    //dir ??= "scripts";
    //var scriptToLoad = Paths.modFolders(dir+module+".hx");
    var scriptToLoad = dir+module+".hx";
    //trace("try "+module);
    
	if (NativeFileSystem.exists(scriptToLoad)) {
		//if (Iris.instances.exists(scriptToLoad)) {
        //    Iris.instances.get(scriptToLoad)?.destroy();
        //    Iris.instances.remove(scriptToLoad);
        //}
        try {
            DeltaRuneCode = new HScript(null, scriptToLoad,null,true);
            DeltaRuneCode.interp.parentInstance = Type.createEmptyInstance(Type.resolveClass("flixel.FlxBasic"));
            DeltaRuneCode.interp.showPosOnLog = false;  
            DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
            DeltaRuneCode.set("getThisVar",(V)->{DeltaRuneCode.interp.resolve(V);});
            
            DeltaRuneCode.set("CacheSystem",CacheSystem);//with fake
            DeltaRuneCode.set("NativeFileSystem",NativeFileSystem);//with fake
            DeltaRuneCode.set("StateHelper",StateHelper);
            //DeltaRuneCode.set("setGlobalVar",(_var)->{
            //    gVars.set(_var,DeltaRuneCode.interp.resolve(_var));
            //    for (h in HXmodules)
            //        h.set(_var,DeltaRuneCode.interp.resolve(_var));
            //});
            //for (m in gVars.keys())
            //    DeltaRuneCode.set(m,gVars.get(m));
            
            var obj = {};
            try {

                DeltaRuneCode.set("MyExtendIs",(V)->{
                    //if (Type.typeOf(V)==)
                    DeltaRuneCode.interp.parentInstance = Type.createEmptyInstance(Type.resolveClass(V));  
                    DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
                    Reflect.setField(obj,"super",DeltaRuneCode.interp.parentInstance);
                    DeltaRuneCode.set("super",Reflect.makeVarArgs(function (?args){ 
                        DeltaRuneCode.interp.parentInstance = Type.createInstance(Type.getClass(DeltaRuneCode.interp.parentInstance),args ?? []);  
                        DeltaRuneCode.set("super",DeltaRuneCode.interp.parentInstance);
                        Reflect.setField(obj,"super",DeltaRuneCode.interp.parentInstance);
                    }));
                    DeltaRuneCode.set("MyExtendIs",(V)->{return;});
                });
				var ret:Dynamic = DeltaRuneCode.execute();
				DeltaRuneCode.returnValue = ret;
			} catch(e:IrisError) {
				DeltaRuneCode.returnValue = null;
				DeltaRuneCode?.destroy();
                trace(e);
                return;
				//throw e;
			}
            StateHelper.getLV("HXmodules").push(DeltaRuneCode);
            for (f in Reflect.fields(Type.getClass(DeltaRuneCode.interp.parentInstance))){
                Reflect.setField(obj,f,Reflect.field(DeltaRuneCode.interp.parentInstance,f));
            }
            //for (f in DeltaRuneCode.interp.locals.keys()){
            //    Reflect.setField(obj,f,DeltaRuneCode.interp.resolve(f));
            //}
            for (f in DeltaRuneCode.interp.variables.keys()){
                Reflect.setField(obj,f,DeltaRuneCode.get(f));
            }
            //obj.set("this",DeltaRuneCode);
            
            return obj;
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
function newObject(obj,?args) {
    if (Objs.exists(obj)){
        _obj = StartHXObj(obj,Objs.get(obj));
        _obj.this.call("new",args ?? []);
        return _obj;
    }
}
onSelfCreate();