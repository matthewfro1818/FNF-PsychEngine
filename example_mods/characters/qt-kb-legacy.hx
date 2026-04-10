var qtKbLegacyAltIdle:Bool = false;
var qtKbLegacyLastDanceLeft:Bool = false;

function qtKbLegacyChar()
{
    if (game == null) return null;
    for (char in [game.dad, game.boyfriend, game.gf])
        if (char != null && char.curCharacter == 'qt-kb-legacy') return char;
    return null;
}

function qtKbLegacyApplyIdle(force:Bool = false)
{
    var char = qtKbLegacyChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        qtKbLegacyLastDanceLeft = !qtKbLegacyLastDanceLeft;
        target = qtKbLegacyLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (qtKbLegacyAltIdle)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;
    if (value1 == 'preDance') qtKbLegacyAltIdle = true;
    if (value1 == 'cheer' || value1 == 'hey') qtKbLegacyAltIdle = false;
}

function onBeatHit()
{
    qtKbLegacyApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = qtKbLegacyChar();
    if (char == null || char.animation == null || char.animation.curAnim == null) return;
    if ((char.animation.curAnim.name == 'danceLeft' || char.animation.curAnim.name == 'danceRight') && qtKbLegacyAltIdle)
        qtKbLegacyApplyIdle();
}
