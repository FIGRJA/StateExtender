package substates.substates.PauseSubState;
// Un safe charts in pause when charting mode!
import backend.Song;
import backend.Difficulty;
import haxe.Unserializer;
import haxe.Serializer;

if (!PlayState.chartingMode||this.get("unSafeCharts")==null) return;
var dfClone;
var curDif = Difficulty.getString();
var copy;
var curChartPath = Song.chartPath;
function onSubstateCreate() {
    dfClone = difficultyChoices.copy();
    copy = Unserializer.run(Serializer.run(PlayState.SONG));//deepseak ))
    //if ()
    unSafeCharts.set(curDif,{chart: copy,chartPath:curChartPath});
    for (d in difficultyChoices){
        if (unSafeCharts.exists(d)){
            difficultyChoices[difficultyChoices.indexOf(d)] = "* "+d;
        }
    }
    
}
//var steps = 0;
//function onUpdate(e) {
//    if (controls.ACCEPTs){
//        if (steps==1&&difficultyChoices==menuItem){
//            trace("jii");
//            FlxG.state.closeSubState();
//        }
//        steps +=1;
//        //close();
//
//    }
//}

function onSubstateDestroy() {
    //trace(PlayState.changedDifficulty);
    if (PlayState.changedDifficulty){
        ChangeDD();
    }
}
function ChangeDD() {
    var assDiff = dfClone[curSelected];
    if (unSafeCharts.exists(assDiff)){
        PlayState.chartingMode = true;
        PlayState.SONG = unSafeCharts.get(assDiff).chart;
        Song.chartPath = unSafeCharts.get(assDiff).chartPath;
        unSafeCharts.set(curDif,{chart: copy,chartPath:curChartPath});
    }
    //trace(assDiff);
}
