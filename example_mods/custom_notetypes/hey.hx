function sourcePortApplyHey(note:Note)
{
    if (note == null || note.noteType != 'hey') return;
    note.noteType = 'Hey!';
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyHey(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyHey(note);
}


