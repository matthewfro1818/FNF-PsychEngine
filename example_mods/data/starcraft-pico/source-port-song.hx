var starcraftPicoEndingPlayed:Bool = false;
var starcraftPicoEndingTimer:FlxTimer = null;

function starcraftPicoCleanup()
{
    if (starcraftPicoEndingTimer != null)
    {
        starcraftPicoEndingTimer.cancel();
        starcraftPicoEndingTimer = null;
    }
}

function onCreatePost()
{
    setVar('sourcePortSongCompat_starcraftPico', true);
}

function onEndSong()
{
    if (starcraftPicoEndingPlayed || !PlayState.isStoryMode)
        return Function_Continue;

    starcraftPicoEndingPlayed = true;
    game.inCutscene = true;
    game.camHUD.alpha = 0;
    game.camOther.flash(0xFF000000, 0.1);
    starcraftPicoEndingTimer = new FlxTimer().start(1.0, function(tmr)
    {
        game.inCutscene = false;
        game.endSong();
    });
    return Function_Stop;
}

function onDestroy()
{
    starcraftPicoCleanup();
}
