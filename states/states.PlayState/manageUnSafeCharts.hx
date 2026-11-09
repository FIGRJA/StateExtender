//package states.states.PlayState;
import states.PlayState;

//var unSafeCharts ;
//if (this.get("unSafeCharts")==null) var unSafeCharts;
function onCreatePost() {

    debugPrint(PlayState.chartingMode);
    //debugPrint(unSafeCharts == null);

    if (!PlayState.chartingMode){
        //unSafeCharts = null;
        setGlobalVar("unSafeCharts",[""=>null]);
    }
}