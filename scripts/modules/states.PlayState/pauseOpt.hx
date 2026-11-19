//package scripts.modules.states.PlayState;
return//soon...
function onCreate() {
    PGlistAction.insert(PGlistAction.indexOf("Debug"),"testing...");
}
function PGpressAccept(c) {
    if (c == "testing...")
        debugPrint("cool...");
}