package substates.substates.PauseSubState;

import backend.Difficulty;
var steps = 0;
function onUpdatePost(e) {
    if (controls.ACCEPT){
        if (steps==0&&difficultyChoices==menuItems){
            trace("jii");
            //curSelected = difficultyChoices.indexOf(Difficulty.getString());
            changeSelection(Difficulty.list.indexOf(Difficulty.getString()),true);
            //FlxG.state.closeSubState();
        }
        steps +=1;
        //close();

    }
}