package states.stages;

import states.stages.objects.SserafimLipSyncSprite;

class Sserafim extends BaseStage
{
	var opponentStrumsHidden:Bool = false;
	var storedComboOffset:Array<Int>;

	var currentVisible:Array<Bool> = [false, true, false, false, true, false];
	var currentSinging:Array<Bool> = [false, false, false, false, false, false];
	var beautifulGF:Bool = false;

	var dadLipSync:SserafimLipSyncSprite;
	var boyfriendLipSync:SserafimLipSyncSprite;

	override function create()
	{
		setDefaultGF('gf');
	}

	override function createPost()
	{
		storedComboOffset = ClientPrefs.data.comboOffset.copy();
		ClientPrefs.data.comboOffset = [9999, -50, 9999, -50];

		createLipSyncSprite(dad, dadGroup, false);
		createLipSyncSprite(boyfriend, boyfriendGroup, true);
		applyVisibleState();
		applySingingState();
	}

	override function update(elapsed:Float)
	{
		if (!opponentStrumsHidden)
		{
			hideOpponentStrums();
			opponentStrumsHidden = true;
		}
	}

	override function destroy()
	{
		if (storedComboOffset != null)
			ClientPrefs.data.comboOffset = storedComboOffset.copy();

		super.destroy();
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case 'sserafimShow':
				currentVisible = parseBoolArray(value1, currentVisible);
				applyVisibleState();

			case 'sserafimSing':
				currentSinging = parseBoolArray(value1, currentSinging);
				applySingingState();

			case 'sserafimBeautiful':
				beautifulGF = stringToBool(value1);
				applyGFAnimationState();

			case 'sserafimKick':
				if (stringToBool(value1))
				{
					if (gf != null)
						gf.visible = true;
					applyGFAnimationState();
				}
		}
	}

	function createLipSyncSprite(char:Character, charGroup:FlxSpriteGroup, isBoyfriend:Bool):Void
	{
		if (char == null || !SserafimLipSyncSprite.supportsCharacter(char.curCharacter))
			return;

		var lipSync:SserafimLipSyncSprite = new SserafimLipSyncSprite(char);
		var targetIndex:Int = members.indexOf(charGroup);
		if (targetIndex >= 0)
			insert(targetIndex + 1, lipSync);
		else
			add(lipSync);

		if (isBoyfriend)
			boyfriendLipSync = lipSync;
		else
			dadLipSync = lipSync;
	}

	function hideOpponentStrums():Void
	{
		for (strum in PlayState.instance.opponentStrums.members)
		{
			if (strum == null)
				continue;
			strum.visible = false;
			strum.alpha = 0.0001;
			strum.active = false;
		}
	}

	function applyVisibleState():Void
	{
		if (dad != null)
			dad.visible = currentVisible[1];

		if (boyfriend != null)
			boyfriend.visible = currentVisible[4];

		if (gf != null)
			gf.visible = currentVisible[5];

		applyGFAnimationState();
	}

	function applySingingState():Void
	{
		if (dadLipSync != null)
			dadLipSync.shouldSing = currentSinging[1];

		if (boyfriendLipSync != null)
			boyfriendLipSync.shouldSing = currentSinging[4];
	}

	function applyGFAnimationState():Void
	{
		if (gf == null)
			return;
		if (beautifulGF && gf.hasAnimation('idle-beautiful'))
		{
			gf.idleSuffix = '-beautiful';
			gf.recalculateDanceIdle();
			gf.dance();
		}
		else if (gf.idleSuffix.length > 0)
		{
			gf.idleSuffix = '';
			gf.recalculateDanceIdle();
			gf.dance();
		}
	}

	function parseBoolArray(value:String, fallback:Array<Bool>):Array<Bool>
	{
		if (value == null)
			return fallback.copy();

		var trimmed:String = value.trim();
		if (trimmed.length < 1)
			return fallback.copy();

		var parsed:Array<Bool> = [];
		for (token in ~/[\s,|]+/g.split(trimmed))
		{
			if (token.length < 1)
				continue;
			parsed.push(stringToBool(token));
		}

		if (parsed.length < fallback.length)
		{
			while (parsed.length < fallback.length)
				parsed.push(fallback[parsed.length]);
		}
		else if (parsed.length > fallback.length)
		{
			parsed.resize(fallback.length);
		}

		return parsed;
	}

	function stringToBool(value:String):Bool
	{
		if (value == null)
			return false;
		return switch (value.trim().toLowerCase())
		{
			case 'true', '1', 'yes', 'on': true;
			default: false;
		}
	}
}
