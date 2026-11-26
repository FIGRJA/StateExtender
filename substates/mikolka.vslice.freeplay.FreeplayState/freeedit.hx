package substates.mikolka.vslice.freeplay.FreeplayState;
import backend.Mods;
import backend.Song;
import backend.Controls;
import backend.Highscore;
import backend.StageData;
import states.LoadingState;
import states.editors.ChartingState;
import mikolka.compatibility.ModsHelper;
var Control = Controls.instance;
var pressed = false;
function onUpdate(e) {
    if (Control.justPressed('debug_1')&&!pressed){
        trace("a");

        funnyCam.filtersEnabled = true;
        fadeShader.fade(1.0, 0, 0.3, {ease: FlxEase.quadIn,onComplete: ()->{LoadingState.loadAndSwitchState(new ChartingState(), true);}});
        super.curCapsule.confirm();
        var level = super.curCapsule.songData;
		PlayState.storyWeek = level.levelId;
		Mods.currentModDirectory = level.folder;
        var diffId = level.loadAndGetDiffId();
		if (diffId == -1)
		{
			trace("SELECTED DIFFICULTY IS MISSING: " + super.currentDifficulty);
			diffId = 0;
		}
        var songLowercase:String = Paths.formatToSongPath(level.getNativeSongId());
        var poop:String = Highscore.formatSong(songLowercase, diffId);
        trace(poop);
        PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		if(PlayState.SONG == null) throw "Song parsing failed!";
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = diffId;
        var directory = StageData.forceNextDirectory;
        LoadingState.loadNextDirectory();
        StageData.forceNextDirectory = directory;
        //PlayState.SONG.song = level.songId
        pressed = true;
    }
}