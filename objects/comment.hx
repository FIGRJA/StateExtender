//package objects;

import tjson.TJSON;
MyExtendIs("flixel.group.FlxTypedSpriteGroup");
var time = 0;
var text;
var bg;
var contr;
//var hide = false;
var jsons;
var note;

function new(ev,_note) {
    note = _note;
    jsons = TJSON.parse(ev[2]);
    time = note.strumTime;
    super(jsons?.x ?? FlxG.width*4/6,_note.y);
    bg = new FlxSprite(0,0);
    bg.makeGraphic(100,40,0xFF5D49B8);
    super.add(bg);
    text = new FlxText(5,15,90,ev[1],15);
    super.add(text);
    contr = new FlxSprite(0,0);
    contr.makeGraphic(100,10,0xFF7E7994);
    super.add(contr);
    add(super);
}
function get_time() {
    return time;
}
function updatePos() {
    super.y = note.y;
}
function set_text(txt) {
    text.text = txt;
}
function destroy() {
    
    text.destroy();
    bg.destroy();
    contr.destroy();
    super.destroy();
    this.destroy();
}