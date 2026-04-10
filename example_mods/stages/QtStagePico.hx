var qtCarsCanDrive:Bool = true;
var qtCarsGoingRight:Bool = true;

function qtpProp(name:String)
{
    return getVar(name);
}

function qtpResetCars()
{
    var cars = qtpProp('randomCars');
    qtCarsCanDrive = true;
    qtCarsGoingRight = true;

    if (cars == null) return;

    FlxTween.cancelTweensOf(cars);
    if (cars.offset != null) FlxTween.cancelTweensOf(cars.offset);
    cars.x = -600;
    cars.flipX = false;
    if (cars.offset != null) cars.offset.y = 0;
}

function qtpDriveCar()
{
    if (!qtCarsCanDrive) return;

    var cars = qtpProp('randomCars');
    if (cars == null || cars.animation == null) return;

    qtCarsCanDrive = false;
    FlxTween.cancelTweensOf(cars);
    if (cars.offset != null) FlxTween.cancelTweensOf(cars.offset);

    var variant = FlxG.random.int(0, 3);
    cars.animation.play('car-' + variant, true);

    var duration = 3.0;
    switch (variant)
    {
        case 3:
            duration = FlxG.random.float(1.85, 1.9);
        case 2:
            duration = FlxG.random.float(2.4, 2.8);
        case 1:
            duration = FlxG.random.float(3.8, 4.0);
        default:
            duration = FlxG.random.float(3.0, 3.5);
    }

    var startX = qtCarsGoingRight ? -600 : 2400;
    var endX = qtCarsGoingRight ? 2400 : -600;
    cars.flipX = !qtCarsGoingRight;
    cars.x = startX;

    FlxTween.tween(cars, {x: endX}, duration, {
        ease: FlxEase.sineInOut,
        onComplete: function(twn)
        {
            qtCarsCanDrive = true;
            qtCarsGoingRight = !qtCarsGoingRight;
            if (cars.offset != null) cars.offset.y = 0;
        }
    });

    if (cars.offset != null)
    {
        FlxTween.tween(cars.offset, {y: 3}, 0.1, {
            ease: FlxEase.sineInOut,
            type: 4,
            loopDelay: 0
        });
    }
}

function onCreatePost()
{
    if (qtpProp('lucky') != null && FlxG.random.bool(5))
        qtpProp('lucky').loadGraphic(Paths.image('outskirts/qtPlush'));

    if (game.boyfriend != null) game.boyfriend.color = 0xFFF0E1D1;
    if (game.gf != null) game.gf.color = 0xFFF0E1D1;
    if (game.dad != null) game.dad.color = 0xFF9FB4C7;

    qtpResetCars();
}

function onBeatHit()
{
    if (qtCarsCanDrive && FlxG.random.bool(10))
        qtpDriveCar();
}

function onSongStart()
{
    qtpResetCars();
}


