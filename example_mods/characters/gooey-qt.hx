function gooeyQtChar()
{
    if (game == null) return null;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'gooey-qt') return game.boyfriend;
    if (game.dad != null && game.dad.curCharacter == 'gooey-qt') return game.dad;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'bf' && target != 'boyfriend' && target != '1') return;

    var char = gooeyQtChar();
    if (char == null) return;

    if (value1 == 'GooeyQTwave' || value1 == 'GooeyBirdBrain')
    {
        char.specialAnim = true;
    }
}
