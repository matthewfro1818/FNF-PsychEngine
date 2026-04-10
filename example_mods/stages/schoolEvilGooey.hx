var schoolEvilWiggleTime:Float = 0;
var schoolEvilWiggleNames:Array<String> = ['school', 'evilstreet', 'backspikes', 'backspike'];

function schoolEvilProp(name:String)
{
    return getVar(name);
}

function onUpdatePost(elapsed:Float)
{
    schoolEvilWiggleTime += elapsed;

    if (schoolEvilProp('school') != null)
        schoolEvilProp('school').angle = Math.sin(schoolEvilWiggleTime * 2.0) * 1.5;
    if (schoolEvilProp('evilstreet') != null)
        schoolEvilProp('evilstreet').angle = Math.sin(schoolEvilWiggleTime * 1.7) * 1.1;
    if (schoolEvilProp('backspikes') != null)
        schoolEvilProp('backspikes').angle = Math.sin(schoolEvilWiggleTime * 1.3) * 1.2;
    if (schoolEvilProp('backspike') != null)
        schoolEvilProp('backspike').angle = Math.sin(schoolEvilWiggleTime * 1.9) * 1.4;
}
