function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'blackIn') return;

    var black = getVar('blackScreenR');
    if (black != null) black.alpha = 1;
}


