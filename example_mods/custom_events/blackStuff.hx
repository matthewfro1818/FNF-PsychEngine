function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'blackStuff') return;

    var black = getVar('blackScreenR');
    if (black != null) black.alpha = 1;
    game.camHUD.alpha = 0;
}

