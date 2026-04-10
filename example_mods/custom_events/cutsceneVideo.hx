function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'cutsceneVideo') return;

    var black = getVar('blackScreenVideo');
    if (black != null) black.alpha = 1;
    game.camHUD.alpha = 0;
}

