function sourcePortApplyAlt(note:Note)
{
    if (note == null || note.noteType != 'alt') return;
    note.noteType = 'Alt Animation';
    note.animSuffix = '-alt';
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyAlt(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyAlt(note);
}


