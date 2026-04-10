function kbChar()
{
    if (game == null) return null;
    for (char in [game.dad, game.boyfriend, game.gf])
        if (char != null && char.curCharacter == 'kb') return char;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;
    var char = kbChar();
    if (char == null) return;
    if (value1 == 'hey' || value1 == 'cheer')
        char.specialAnim = true;
}
