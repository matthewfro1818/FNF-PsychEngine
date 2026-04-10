var phillyBackCarCanDrive:Bool = true;
var phillyFrontCarCanDrive:Bool = true;
var phillyAllowCars:Bool = true;
var phillyBackCarTimer:FlxTimer = null;
var phillyFrontCarTimer:FlxTimer = null;
var phillyStoredComboOffset:Array<Int> = null;

function phillyProp(name:String)
{
    return getVar(name);
}

function phillyCancelTimers()
{
    if (phillyBackCarTimer != null)
    {
        phillyBackCarTimer.cancel();
        phillyBackCarTimer = null;
    }
    if (phillyFrontCarTimer != null)
    {
        phillyFrontCarTimer.cancel();
        phillyFrontCarTimer = null;
    }
}

function phillyResetBackCar()
{
    var backCar = phillyProp('backCar');
    if (backCar == null) return;
    backCar.flipX = false;
    backCar.x = 0;
    phillyBackCarCanDrive = true;
}

function phillyResetFrontCar()
{
    var frontCar = phillyProp('frontCar');
    if (frontCar == null) return;
    frontCar.flipX = false;
    frontCar.x = -3000;
    phillyFrontCarCanDrive = true;
}

function phillyBackCarDrive()
{
    var backCar = phillyProp('backCar');
    if (backCar == null) return;

    playSound('extra/carPassMix', 0.4);
    if (FlxG.random.int(1, 2) == 1)
    {
        FlxTween.tween(backCar, {x: 3000}, 0.5, {ease: FlxEase.linear});
    }
    else
    {
        backCar.x = 3000;
        backCar.flipX = true;
        FlxTween.tween(backCar, {x: 0}, 0.5, {ease: FlxEase.linear});
    }
    phillyBackCarCanDrive = false;
    phillyBackCarTimer = new FlxTimer().start(5, function(tmr)
    {
        phillyResetBackCar();
    });
}

function phillyFrontCarDrive()
{
    var frontCar = phillyProp('frontCar');
    if (frontCar == null) return;

    playSound('extra/carPassMix', 0.5);
    if (FlxG.random.int(1, 2) == 1)
    {
        FlxTween.tween(frontCar, {x: 4000}, 0.5, {ease: FlxEase.linear});
    }
    else
    {
        frontCar.x = 4000;
        frontCar.flipX = true;
        FlxTween.tween(frontCar, {x: -3000}, 0.5, {ease: FlxEase.linear});
    }
    phillyFrontCarCanDrive = false;
    phillyFrontCarTimer = new FlxTimer().start(7, function(tmr)
    {
        phillyResetFrontCar();
    });
}

function onCreatePost()
{
    if (phillyProp('lighting') != null)
        phillyProp('lighting').blend = 0;
    phillyAllowCars = true;
}

function onStartCountdown()
{
    phillyResetBackCar();
    phillyResetFrontCar();
    phillyAllowCars = true;

    if (ClientPrefs != null && ClientPrefs.data != null)
    {
        phillyStoredComboOffset = ClientPrefs.data.comboOffset.copy();
        ClientPrefs.data.comboOffset = [-450, 350, -450, 350];
    }

    return Function_Continue;
}

function onBeatHit()
{
    if (curBeat == 332 && phillyProp('picoWalk') != null)
    {
        if (phillyProp('picoWalk').animation != null) phillyProp('picoWalk').animation.play('walk', true);
        FlxTween.tween(phillyProp('picoWalk'), {x: 1950}, 10.55, {ease: FlxEase.linear});
    }
    if (curBeat == 400)
        phillyAllowCars = false;

    if (FlxG.random.bool(10) && phillyBackCarCanDrive && phillyAllowCars)
        phillyBackCarDrive();
    if (FlxG.random.bool(10) && phillyFrontCarCanDrive && phillyAllowCars)
        phillyFrontCarDrive();
}

function onDestroy()
{
    phillyCancelTimers();
    if (ClientPrefs != null && ClientPrefs.data != null && phillyStoredComboOffset != null)
        ClientPrefs.data.comboOffset = phillyStoredComboOffset.copy();
}
