var limoFastCarCanDrive:Bool = false;
var limoShootingStarBeat:Int = 0;
var limoShootingStarOffset:Int = 2;
var limoCarResetTimer:FlxTimer = null;

function limoProp(name:String)
{
    return getVar(name);
}

function limoResetCarTimer()
{
    if (limoCarResetTimer != null)
    {
        limoCarResetTimer.cancel();
        limoCarResetTimer = null;
    }
}

function limoResetFastCar()
{
    limoResetCarTimer();

    var fastCar = limoProp('fastCar');
    if (fastCar == null) return;

    fastCar.active = true;
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    limoFastCarCanDrive = true;
}

function limoFastCarDrive()
{
    var fastCar = limoProp('fastCar');
    if (fastCar == null) return;

    playSound('carPass' + FlxG.random.int(0, 1), 0.7);
    fastCar.velocity.x = (FlxG.random.int(170, 220) / Math.max(FlxG.elapsed, 0.016)) * 3;
    limoFastCarCanDrive = false;

    limoCarResetTimer = new FlxTimer().start(2.0, function(tmr)
    {
        limoResetFastCar();
    });
}

function limoDoShootingStar(beat:Int)
{
    var star = limoProp('shootingStar');
    if (star == null) return;

    star.x = FlxG.random.int(50, 900);
    star.y = FlxG.random.int(-10, 20);
    star.flipX = FlxG.random.bool(50);
    if (star.animation != null) star.animation.play('shooting star', true);

    limoShootingStarBeat = beat;
    limoShootingStarOffset = FlxG.random.int(4, 8);
}

function onCreatePost()
{
    if (limoProp('shootingStar') != null)
        limoProp('shootingStar').blend = 0;

    limoResetFastCar();
}

function onStartCountdown()
{
    limoResetFastCar();
    return Function_Continue;
}

function onBeatHit()
{
    if (FlxG.random.bool(10) && limoFastCarCanDrive)
        limoFastCarDrive();

    if (FlxG.random.bool(10) && curBeat > (limoShootingStarBeat + limoShootingStarOffset))
        limoDoShootingStar(curBeat);
}

function onDestroy()
{
    limoResetCarTimer();
}
