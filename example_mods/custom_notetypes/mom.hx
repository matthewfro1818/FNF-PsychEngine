function sourcePortApplyMom(note:Note)
{
    if (note == null || note.noteType != 'mom') return;
    note.noteType = 'GF Sing';
    note.gfNote = true;
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyMom(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyMom(note);
}


