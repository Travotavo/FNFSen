package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	var ConfirmFlicker:FlxSprite;
	var GameOverSplash:FlxSprite;
	var RetryFairy:FlxSprite;
	var DrawnOver:FlxSprite;

	public function new(x:Float, y:Float, camX:Float, camY:Float, deathState:String) //Travotavo was here = "linkBF"
	{
		super();
		
		PlayState.instance.setOnLuas('inGameOver', true);
		
		Conductor.songPosition = 0;

		//sorry im a lil lazy ; w ;
		var realCharName:String = deathState; //Travotavo was here
		ConfirmFlicker = new FlxSprite();
		ConfirmFlicker.scrollFactor.set(0,0);
		ConfirmFlicker.frames = Paths.getSparrowAtlas('GameOver/ConfirmFlicker');
		ConfirmFlicker.animation.addByPrefix('bump', 'Retry Loading', 24, true);
		ConfirmFlicker.animation.play('bump');
		ConfirmFlicker.updateHitbox();
		ConfirmFlicker.screenCenter();


		boyfriend = new Boyfriend(x, y, realCharName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);
		
		DrawnOver = new FlxSprite();
		DrawnOver.scrollFactor.set(0,0);
		DrawnOver.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		DrawnOver.updateHitbox();
		DrawnOver.screenCenter();
		DrawnOver.alpha = 0;
		
		GameOverSplash = new FlxSprite();
		GameOverSplash.scrollFactor.set(0,0);
		GameOverSplash.frames = Paths.getSparrowAtlas('GameOver/Game_Over');
		GameOverSplash.animation.addByPrefix('roll', 'Game Over', 24, false);
		GameOverSplash.updateHitbox();
		GameOverSplash.screenCenter(X);
		GameOverSplash.y = FlxG.height * .2;
		GameOverSplash.x += 300;
		GameOverSplash.alpha = 0;
		
		RetryFairy = new FlxSprite();
		RetryFairy.scrollFactor.set(0,0);
		RetryFairy.frames = Paths.getSparrowAtlas('GameOver/Retry');
		RetryFairy.animation.addByPrefix('bump', 'Retry', 24, true);
		RetryFairy.animation.play('bump');
		RetryFairy.updateHitbox();
		RetryFairy.screenCenter(X);
		RetryFairy.y = FlxG.height * .6;
		RetryFairy.alpha = 0;

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');
		
		add(DrawnOver);
		add(RetryFairy);
		add(GameOverSplash);
		
		
		add(ConfirmFlicker);
		ConfirmFlicker.alpha = 0;
		
		var exclude:Array<Int> = [];
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished)
			{
				DrawnOver.alpha = 1;
				RetryFairy.alpha = 1;
				GameOverSplash.alpha = 1;
				GameOverSplash.animation.play('roll');
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			
			ConfirmFlicker.alpha = 1;
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName), 0);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
		}
	}
}
