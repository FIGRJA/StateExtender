//package custom_events.modules.states.editors.ChartingState;
var section = -1;
var zoom = 0;
var coments = [];
var evL = 0;
function onUpdate(e) {
    try{
    if (curSec!=section||curZoom!=zoom){
        section = curSec;
        zoom = curZoom;
        for (c in coments){
            c.updatePos();
        }

    }
    if (events.length!=evL){
        evL = events.length;
        var newArr = [];
        for (note in events){
            for (ev in note.events){
                if (ev[0]=="coment"){
                    var oldC;
                    for (c in coments){
                        if (c.get_time()==note.strumTime){
                            oldC = c;
                            break;
                        }
                    }
                    if (oldC==null){
                        try{
                            oldC = newObject("comment",[ev,note]);
                            //add(oldC);
                        }catch(e:Dynamic){addOutText(e);}
                    }
                    newArr.push(oldC);
                }
            }
        }
        for (c in coments){
            if (newArr.contains(c)) continue;
            c.destroy();
        }
        coments = newArr;
    }}catch(e:Dynamic){addOutText(e);}
}
function onDestroy() {
    for (c in coments)
        c.destroy();
}