function onCreatePost()
{
    setVar('sourcePortQtStageChange', 'Killer');
    if (getVar('blackScreenR') != null) getVar('blackScreenR').alpha = 1;
}

function onSongStart()
{
    if (getVar('blackScreenR') != null)
        FlxTween.tween(getVar('blackScreenR'), {alpha: 0}, 5, {ease: FlxEase.quadInOut});
}
