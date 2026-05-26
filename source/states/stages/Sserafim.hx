package states.stages;

import objects.BGSprite;
import objects.Character;
import objects.Note;
import states.stages.objects.SserafimLipSyncSprite;

using StringTools;

class Sserafim extends BaseStage
{
	var chaewon:Character;
	var eunchae:Character;
	var kazuha:Character;

	override function create()
	{
		super.create();

		setDefaultGF('gf');

		add(new BGSprite('bg', -1888, -660));
		add(new BGSprite('back-tables', -1908, 267));
		add(new BGSprite('floor', -2232, 631));
		add(new BGSprite('back-stools', -1551, 431));
		add(new BGSprite('front-stools', -1551, 431));
		add(new BGSprite('truck-stuff', -983, -707));
		add(new BGSprite('truck-door', -980, -173));
	}

	override function createPost()
	{
		super.createPost();

		chaewon = new Character(200, -240, 'sserafim-chaewon');
		chaewon.scrollFactor.set(1, 1);
		addBehindBF(chaewon);

		eunchae = new Character(250, 290, 'sserafim-eunchae');
		eunchae.scrollFactor.set(1, 1);
		add(eunchae);

		kazuha = new Character(-500, 100, 'sserafim-kazuha');
		kazuha.scrollFactor.set(1, 1);
		add(kazuha);
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			danceIfNotSinging(chaewon);
			danceIfNotSinging(eunchae);
			danceIfNotSinging(kazuha);
		}
	}

	override function goodNoteHit(note:Note)
	{
		super.goodNoteHit(note);

		if (note == null)
			return;

		switch (note.noteType)
		{
			case 'ChaewonNote':
				singCharacter(chaewon, note.noteData);

			case 'EunchaeNote':
				singCharacter(eunchae, note.noteData);

			case 'YunjinNote':
				singCharacter(dad, note.noteData);

			case 'KazuhaNote':
				singCharacter(kazuha, note.noteData);

			case 'sakura-joint':
				singAll(note.noteData);
		}
	}

	function danceIfNotSinging(char:Character):Void
	{
		if (char == null)
			return;

		var anim:String = char.getAnimationName();
		if (anim == null || !anim.startsWith('sing'))
			char.dance();
	}

	function singCharacter(char:Character, noteData:Int):Void
	{
		if (char == null)
			return;

		var anims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		if (noteData < 0 || noteData >= anims.length)
			return;

		var anim:String = anims[noteData];
		if (char.hasAnimation(anim))
		{
			char.playAnim(anim, true);
			char.holdTimer = 0;
		}
	}

	function singAll(noteData:Int):Void
	{
		singCharacter(boyfriend, noteData);
		singCharacter(dad, noteData);
		singCharacter(gf, noteData);
		singCharacter(chaewon, noteData);
		singCharacter(eunchae, noteData);
		singCharacter(kazuha, noteData);
	}
}
