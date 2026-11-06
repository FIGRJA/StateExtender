//package scripts.modules.global;

import Reflect;
import backend.Controls;
import flixel.text.FlxTextBorderStyle;

var controls = {
    // from https://github.com/HaxeFlixel/flixel/blob/master/flixel/input/keyboard/FlxKey.hx
	"ANY" : -2,
	"NONE" : -1,
	"A" : 65,
	"B" : 66,
	"C" : 67,
	"D" : 68,
	"E" : 69,
	"F" : 70,
	"G" : 71,
	"H" : 72,
	"I" : 73,
	"J" : 74,
	"K" : 75,
	"L" : 76,
	"M" : 77,
	"N" : 78,
	"O" : 79,
	"P" : 80,
	"Q" : 81,
	"R" : 82,
	"S" : 83,
	"T" : 84,
	"U" : 85,
	"V" : 86,
	"W" : 87,
	"X" : 88,
	"Y" : 89,
	"Z" : 90,
	"ZERO" : 48,
	"ONE" : 49,
	"TWO" : 50,
	"THREE" : 51,
	"FOUR" : 52,
	"FIVE" : 53,
	"SIX" : 54,
	"SEVEN" : 55,
	"EIGHT" : 56,
	"NINE" : 57,
	"PAGEUP" : 33,
	"PAGEDOWN" : 34,
	"HOME" : 36,
	"END" : 35,
	"INSERT" : 45,
	"ESCAPE" : 27,
	"MINUS" : 189,
	"PLUS" : 187,
	"DELETE" : 46,
	"BACKSPACE" : 8,
	"LBRACKET" : 219,
	"RBRACKET" : 221,
	"BACKSLASH" : 220,
	"CAPSLOCK" : 20,
	"SCROLL_LOCK" : 145,
	"NUMLOCK" : 144,
	"SEMICOLON" : 186,
	"QUOTE" : 222,
	"ENTER" : 13,
	"SHIFT" : 16,
	"COMMA" : 188,
	"PERIOD" : 190,
	"SLASH" : 191,
	"GRAVEACCENT" : 192,
	"CONTROL" : 17,
	"ALT" : 18,
	"SPACE" : 32,
	"UP" : 38,
	"DOWN" : 40,
	"LEFT" : 37,
	"RIGHT" : 39,
	"TAB" : 9,
	"WINDOWS" : 15,
	"MENU" : 302,
	"PRINTSCREEN" : 301,
	"BREAK" : 19,
	"F1" : 112,
	"F2" : 113,
	"F3" : 114,
	"F4" : 115,
	"F5" : 116,
	"F6" : 117,
	"F7" : 118,
	"F8" : 119,
	"F9" : 120,
	"F10" : 121,
	"F11" : 122,
	"F12" : 123,
	"NUMPADZERO" : 96,
	"NUMPADONE" : 97,
	"NUMPADTWO" : 98,
	"NUMPADTHREE" : 99,
	"NUMPADFOUR" : 100,
	"NUMPADFIVE" : 101,
	"NUMPADSIX" : 102,
	"NUMPADSEVEN" : 103,
	"NUMPADEIGHT" : 104,
	"NUMPADNINE" : 105,
	"NUMPADMINUS" : 109,
	"NUMPADPLUS" : 107,
	"NUMPADPERIOD" : 110,
	"NUMPADMULTIPLY" : 106,
	"NUMPADSLASH" : 111
};

function str2int(str) {
    return Reflect.field(controls,str); 
}

function int2str(int) {
    for (str in Reflect.fields(controls)){
        if (str2int(str)==int)
            return str;
    }
}

function listS2I(list) {
    var ilist = [];
    for (s in list)
        ilist.push(str2int(s));
    return ilist;
}

var SuperControls = {
            "anyJustPressed":(l)->{return FlxG.keys.anyJustPressed(listS2I(l));},
            "anyJustReleased":(l)->{return FlxG.keys.anyJustReleased(listS2I(l));},
            "anyPressed":(l)->{return FlxG.keys.anyJustPressed(listS2I(l));},

            "justPressed":(k)->{return FlxG.keys.checkStatus(str2int(k),2);},
            "pressed":(k)->{return FlxG.keys.checkStatus(str2int(k),1);},
            "justReleased":(k)->{return FlxG.keys.checkStatus(str2int(k),-1);},
            "released":(k)->{return FlxG.keys.checkStatus(str2int(k),0);}
        };
function onCreatePost() {
    //for (m in StateHelper.getLV("HXmodules")){
    //    m.set("SuperControls",SuperControls);
    //}
	setGlobalVar("SuperControls");
	FlxG.timeScale = 1;
}
	setGlobalVar("SuperControls");
//function onSubstateCreate() {
//	try{
//    for (m in StateHelper.subStates){
//        m.set("SuperControls",{
//            "anyJustPressed":(l)->{return FlxG.keys.anyJustPressed(listS2I(l));},
//            "anyJustReleased":(l)->{return FlxG.keys.anyJustReleased(listS2I(l));},
//            "anyPressed":(l)->{return FlxG.keys.anyJustPressed(listS2I(l));},
//
//            "justPressed":(k)->{return FlxG.keys.checkStatus(str2int(k),2);},
//            "pressed":(k)->{return FlxG.keys.checkStatus(str2int(k),1);},
//            "justReleased":(k)->{return FlxG.keys.checkStatus(str2int(k),-1);},
//            "released":(k)->{return FlxG.keys.checkStatus(str2int(k),0);}
//        });
//    }
//}catch(e:Dynamic){}
//}