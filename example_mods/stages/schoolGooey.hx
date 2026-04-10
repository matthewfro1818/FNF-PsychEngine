function schoolGooeyProp(name:String)
{
    return getVar(name);
}

function onCreatePost()
{
    if (schoolGooeyProp('freaks') != null)
    {
        if (songPath == 'roses')
            schoolGooeyProp('freaks').idleSuffix = '-scared';
        else
            schoolGooeyProp('freaks').idleSuffix = '';
    }
}
