function doAnim()
{
    if (this == null || this.animation == null) return;

    if (this.animation.getByName != null && this.animation.getByName('idle') != null)
        this.animation.play('idle', true);
    else if (this.animation.curAnim != null)
        this.animation.play(this.animation.curAnim.name, true);
}

function onCreatePost()
{
    doAnim();
}
