var neneQtAltIdle:Bool = false;
var neneQtReady:Bool = false;
var neneQtLastDanceLeft:Bool = false;

function neneQtChar()
{
    if (game == null) return null;
    if (game.gf != null && game.gf.curCharacter == 'nene-qt') return game.gf;
    if (game.dad != null && game.dad.curCharacter == 'nene-qt') return game.dad;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'nene-qt') return game.boyfriend;
    return null;
}

function neneQtApplyIdle(force:Bool = false)
{
    var char = neneQtChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight' && curName != 'idle') return;

    var target = curName;
    if (target == 'idle')
        target = neneQtAltIdle ? 'idle-alt' : 'idle';
    else
    {
        if (target != 'danceLeft' && target != 'danceRight')
        {
            neneQtLastDanceLeft = !neneQtLastDanceLeft;
            target = neneQtLastDanceLeft ? 'danceLeft' : 'danceRight';
        }
        if (neneQtAltIdle)
            target += '-alt';
    }

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onBeatHit()
{
    var char = neneQtChar();
    if (char == null) return;

    neneQtReady = game.health <= 0.5;
    neneQtApplyIdle();
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'gf' && target != 'girlfriend' && target != '2') return;

    switch (value1)
    {
        case 'huh':
            neneQtAltIdle = true;
        case 'cheer':
            neneQtAltIdle = false;
            neneQtReady = false;
    }
}

function onUpdatePost(elapsed:Float)
{
    var char = neneQtChar();
    if (char == null || char.animation == null) return;

    if (game.health <= 0.5 && !neneQtReady && char.hasAnimation != null && char.hasAnimation('raiseKnife'))
    {
        neneQtReady = true;
        char.playAnim('raiseKnife', true);
        char.specialAnim = true;
        return;
    }
    if (game.health > 0.5 && neneQtReady && char.hasAnimation != null && char.hasAnimation('lowerKnife'))
    {
        neneQtReady = false;
        char.playAnim('lowerKnife', true);
        char.specialAnim = true;
        return;
    }

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if (curAnim.name == 'huh')
        neneQtAltIdle = true;
    else if (curAnim.name == 'cheer')
        neneQtAltIdle = false;
    else if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight' || curAnim.name == 'idle') && neneQtAltIdle)
        neneQtApplyIdle();
}
