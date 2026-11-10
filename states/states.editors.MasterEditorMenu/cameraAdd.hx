package states.states.editors.MasterEditorMenu;


function onCreate() {
    //options.insert(10,'Crash the game');
    //options.insert(11,'Usermess the game');
    options.insert(options.indexOf("Stage Editor")+1,'Camera Editor');
}
function onCreatePost() {
    menu.onSelect.add(onAcceptE);
    
}
function onAcceptE(option) {
    switch(option){
        case "Camera Editor":
            StateHelper.switchCustomStateWithLoading("customstate.cameraEditor");
    }
}