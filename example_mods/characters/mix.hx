function mixChar()
{
    if (game == null) return null;
    for (char in [game.dad, game.boyfriend, game.gf])
        if (char != null && char.curCharacter == 'mix') return char;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;
    var char = mixChar();
    if (char == null) return;
    if (value1 == 'hey')
        char.specialAnim = true;
}
