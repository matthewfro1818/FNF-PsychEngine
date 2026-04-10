var starcraftEndingPlayed:Bool = false;
var starcraftEndingTimer:FlxTimer = null;

function starcraftEndCleanup()
{
    if (starcraftEndingTimer != null)
    {
        starcraftEndingTimer.cancel();
        starcraftEndingTimer = null;
    }
}

function onCreatePost()
{
    setVar('sourcePortSongCompat_starcraft', true);
}

function onEndSong()
{
    if (starcraftEndingPlayed || !PlayState.isStoryMode)
        return Function_Continue;

    starcraftEndingPlayed = true;
    game.inCutscene = true;
    game.camHUD.alpha = 0;
    game.camOther.flash(0xFF000000, 0.1);
    starcraftEndingTimer = new FlxTimer().start(1.0, function(tmr)
    {
        game.inCutscene = false;
        game.endSong();
    });
    return Function_Stop;
}

function onDestroy()
{
    starcraftEndCleanup();
}
