var floraAltMode:Bool = false;
var floraTransMode:Bool = false;
var floraLastDanceLeft:Bool = false;
var floraTransformTimer:FlxTimer = null;

function floraChar()
{
    if (game == null) return null;
    for (char in [game.gf, game.dad, game.boyfriend])
        if (char != null && char.curCharacter == 'flora-tankmen') return char;
    return null;
}

function floraClearTransformTimer()
{
    if (floraTransformTimer != null)
    {
        floraTransformTimer.cancel();
        floraTransformTimer = null;
    }
}

function floraApplyDanceVariant(force:Bool = false)
{
    var char = floraChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        floraLastDanceLeft = !floraLastDanceLeft;
        target = floraLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (floraTransMode)
        target += '-trans';
    else if (floraAltMode)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'gf' && target != 'girlfriend' && target != '2') return;

    switch (value1)
    {
        case 'combo200':
            floraAltMode = false;
            floraTransMode = true;
            floraClearTransformTimer();
            floraTransformTimer = new FlxTimer().start(0.05, function(tmr)
            {
                floraTransMode = false;
                floraAltMode = true;
            });
        case 'drop70':
            floraAltMode = false;
            floraTransMode = false;
            floraClearTransformTimer();
    }
}

function onBeatHit()
{
    floraApplyDanceVariant();
}

function onUpdatePost(elapsed:Float)
{
    var char = floraChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && (floraAltMode || floraTransMode))
        floraApplyDanceVariant();
}

function onDestroy()
{
    floraClearTransformTimer();
}
