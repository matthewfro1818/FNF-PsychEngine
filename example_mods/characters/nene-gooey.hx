var neneGooeyAltIdle:Bool = false;
var neneGooeyLastDanceLeft:Bool = false;

function neneGooeyChar()
{
    if (game == null) return null;
    for (char in [game.gf, game.dad, game.boyfriend])
        if (char != null && char.curCharacter == 'nene-gooey') return char;
    return null;
}

function neneGooeyApplyIdle(force:Bool = false)
{
    var char = neneGooeyChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight' && curName != 'idle') return;

    var target = curName;
    if (target == 'idle')
        target = neneGooeyAltIdle ? 'idle-alt' : 'idle';
    else
    {
        if (target != 'danceLeft' && target != 'danceRight')
        {
            neneGooeyLastDanceLeft = !neneGooeyLastDanceLeft;
            target = neneGooeyLastDanceLeft ? 'danceLeft' : 'danceRight';
        }
        if (neneGooeyAltIdle)
            target += '-alt';
    }

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;
    if (value1 == 'huh') neneGooeyAltIdle = true;
    if (value1 == 'cheer') neneGooeyAltIdle = false;
}

function onBeatHit()
{
    neneGooeyApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = neneGooeyChar();
    if (char == null || char.animation == null || char.animation.curAnim == null) return;
    if ((char.animation.curAnim.name == 'danceLeft' || char.animation.curAnim.name == 'danceRight' || char.animation.curAnim.name == 'idle') && neneGooeyAltIdle)
        neneGooeyApplyIdle();
}
