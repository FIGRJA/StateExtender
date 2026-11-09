//package states.states.editors.CharacterEditorState;
import backend.ui.PsychUIButton;
import backend.ui.PsychUIInputText;
import animate.FlxAnimate;
import animate.FlxAnimateFrames;
//import flxanimate.PsychFlxAnimate as FlxAnimate;
import Reflect;
//this.set("FlxAnimate",Type.typeof("flxanimate.PsychFlxAnimate"));
var state;

var imageInputText:PsychUIInputText;
function onCreatePost() {
    state = FlxG.state;
	var tab_group = state.UI_characterbox.getTab('Character').menu;
    imageInputText = new PsychUIInputText(15, 30, 200, character.imageFile, 8);
    //tab_group.remove(state.imageInputText);
    //tab_group.add(imageInputText);
    //var oldOCI = state.imageInputText.onChange ?? (_,_)->{};
    //state.imageInputText.onChange = (ls,s)->{
    //    //oldOCI(ls,s);
    //    trace(ls);
    //    trace(s);
    //    imageInputText.text = s;
    //};
    var reloadImage:PsychUIButton = new PsychUIButton(imageInputText.x + 210, imageInputText.y - 3, "Reload Image", function()
    {
        trace("hi");
        var lastAnim = state.character.getAnimationName();
        state.character.imageFile = imageInputText.text;
        try{
            state.reloadCharacterImage();
        }catch(e:Dynamic){
            trace(e);
            //reloadCharacterImageMultiAAtlas();
        }
        if (!state.character.isAnimationNull())
        {
            state.character.playAnim(lastAnim, true);
        }
    });

    for (b in tab_group){
        if (b.label == "Reload Image"){
            tab_group.remove(b);
            tab_group.add(reloadImage);
            trace("found");
            break;
        }}
}

function reloadCharacterImageMultiAAtlas()
{
    var lastAnim:String = state.character.getAnimationName();
    var anims:Array<AnimArray> = state.character.animationsArray.copy();

    //state.character.atlas = FlxDestroyUtil.destroy(state.character.atlas);
    //state.character.isAnimateAtlas = false;
    //state.character.color = FlxColor.WHITE;
    //state.character.alpha = 1;
    //already done

    //if (Paths.fileExists('images/' + state.character.imageFile + '/Animation.json', TEXT))
    //{
    //state.character.atlas = new FlxAnimate();
    //state.character.atlas.showPivot = false;
    //    try
    //    {
    //        Paths.loadAnimateAtlas(character.atlas, character.imageFile);
    //    }
    //    catch (e:Dynamic)
    //    {
    //        FlxG.log.warn('Could not load atlas ${character.imageFile}: $e');
    //    }
    //}
    //else
    //{
    var a = multiAnimate(imageInputText.text.split(','));
    trace(a);
      state.character.frames = a;
      trace("done");
    state.character.isAnimateAtlas = true;
    //}

    for (anim in anims)
    {
        var animAnim:String = '' + anim.anim;
        var animName:String = '' + anim.name;
        var animFps:Int = anim.fps;
        var animLoop:Bool = !!anim.loop; // Bruh
        var animIndices:Array<Int> = anim.indices;
        state.addAnimation(animAnim, animName, animFps, animLoop, animIndices);
    }

    if (anims.length > 0)
    {
        if (lastAnim != '')
            state.character.playAnim(lastAnim, true);
        else
            state.character.dance();
    }
}
var lastTextImage = '';
function onUpdatePost(e) {
    if (imageInputText.text!=lastTextImage ){
        imageInputText.text = super.imageInputText.text;
        lastTextImage = super.imageInputText.text;
    }
}
function multiAnimate(keys) {
    
    trace(keys[0]);
    var parentFrames = Paths.loadAnimateAtlas(keys[0]);
		if (keys.length > 1)
		{
			var original = parentFrames;
			parentFrames = new FlxAnimateFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length)
			{
            trace("a"+i);
				var extraFrames = Paths.loadAnimateAtlas(keys[i]);
				if (extraFrames != null)
					parentFrames.addAtlas(extraFrames, true);
			}
		}
		return parentFrames;
    //for (i in arrs){
    //    FlxAnimateFrames.fromSpriteMap(cast myData, img);
    //}
}

function sAnimAtlas(anim,folderOrImg) {
trace("try");
	var dir = Paths.getPath("images/" + folderOrImg);
    if (NativeFileSystem.exists(Path.join([dir, "spritemap1.json"])))
        pathOrStr = NativeFileSystem.getContent(Path.join([dir, "spritemap1.json"]));
    else
    {
        trace(Path.join([dir, "spritemap1.json"]) + " is missing!!");
        return;
    }
    if (NativeFileSystem.exists(Path.join([dir, "Animation.json"])))
        animationJson = NativeFileSystem.getContent(Path.join([dir, "Animation.json"]));
    else
    {
        trace(Path.join([dir, "Animation.json"]) + " is missing!!");
        return;
    }
    var img = image(Path.join([folderOrImg, "spritemap1"]));
    var animJson:AnimAtlas = null;

trace("found");
//
    //if(myJson is String)
    //{
    //    #if sys
        var trimmed:String = pathOrStr.trim();
        trimmed = trimmed.substr(trimmed.length - 5).toLowerCase();
        if(trimmed == '.json') myJson = NativeFileSystem.getContent(myJson); //is a path
    //    #end
//
    //    //animJson = cast haxe.Json.parse(_removeBOM(myJson));
        animJson = TJSON.parse(_removeBOM(myJson));
    //}
    //else animJson = myJson;

    //var isXml:Null<Bool> = null;
    var myData:Dynamic = pathOrStr;

    var trimmed:String = pathOrStr.trim();
    trimmed = trimmed.substr(trimmed.length - 5).toLowerCase();

    #if sys
    if(trimmed == '.json') //Path is json
    {
        myData = NativeFileSystem.getContent(pathOrStr);
        //isXml = false;
    }

trace("get");
    //else if (trimmed.substr(1) == '.xml') //Path is xml
    //{
    //    myData = NativeFileSystem.getContent(pathOrStr);
    //    isXml = true;
    //}
    #end
    
    myData = _removeBOM(myData);

    // Automatic if everything else fails
    //switch(isXml)
    //{
    //    case true:
    //        myData = Xml.parse(myData);
    //    case false:
            myData = TJSON.parse(myData);
    //    case null:
    //        try
    //        {
    //            myData = TJSON.parse(myData);
    //            isXml = false;
    //            //trace('JSON parsed successfully!');
    //        }
    //        catch(e)
    //        {
    //            myData = Xml.parse(myData);
    //            isXml = true;
    //            //trace('XML parsed successfully!');
    //        }
    //}
    //anim._loadAtlas(animJson);
    //if(!isXml) return FlxAnimateFrames.fromSpriteMap(myData, img);
	return FlxAnimateFrames.fromSparrowDirect(img,myData);

}
function _removeBOM(str:String) //Removes BOM byte order indicator
	{
		if (str.charCodeAt(0) == 0xFEFF) str = str.substr(1); //myData = myData.substr(2);
		return str;
	}