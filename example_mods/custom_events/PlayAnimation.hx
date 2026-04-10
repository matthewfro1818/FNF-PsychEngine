function resolveTargetCharacter(target:String)
{
    if (target == null) return game.dad;

    var value = target.toLowerCase().trim();
    switch (value)
    {
        case 'bf', 'boyfriend', '1':
            return game.boyfriend;
        case 'gf', 'girlfriend', '2':
            return game.gf;
        default:
            return game.dad;
    }
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2;
    if (target != null && target.indexOf('|') >= 0)
        target = target.split('|')[0];

    var char = resolveTargetCharacter(target);
    if (char == null || value1 == null || value1.trim().length < 1) return;

    char.playAnim(value1, true);
    char.specialAnim = true;
}


