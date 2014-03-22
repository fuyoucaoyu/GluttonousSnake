package com.sprite.core
{
	import com.sprite.events.SpriteEvent;
	import com.sprite.scenes.MainScene;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class MainContainer extends Sprite
	{
		public function MainContainer()
		{
			super();
		}
		
		public function start():void
		{
			this.addChild(new Image(Texture.fromBitmap(new Background())));
			showMainScene();
			mTargetImg = new Image(EmbeddedAssets.assetManager.getTexture("helloPanel"));
			mTargetImg.pivotX = mTargetImg.width / 2;
			mTargetImg.pivotY = mTargetImg.height / 2;
			mTargetImg.visible = false;
			mTargetImg.useHandCursor = true;
			mTargetImg.x = 0;
			mTargetImg.y = 0;
			mTargetImg.addEventListener(TouchEvent.TOUCH, targetImgTouchHandler);
			stage.addChild(mTargetImg)
		}
		
		private function showMainScene():void
		{
			if (!mMainScene)
			{
				mMainScene = new MainScene();
				mMainScene.x = 0;
				mMainScene.y = 0;
				this.addChild(mMainScene);
				mMainScene.addEventListener(SpriteEvent.SPRITE_CLICKED, spriteClickedHandler);
				mMainScene.addEventListener(SpriteEvent.SPRITE_PRESSED, spritePressedHandler);
			}
		}
		
		private function isTweenCompleted():Boolean
		{
			if ((mHideTween && !mHideTween.isComplete) || (mShowTween && !mShowTween.isComplete) || (mTurnTween && !mTurnTween.isComplete) || (mScaleTween && !mScaleTween.isComplete))
				return false;
			
			return true;
		}
		private function spriteClickedHandler(event:SpriteEvent):void
		{
			if (!isTweenCompleted())
				return;
			
			mHideTween = new Tween(mMainScene, Constants.SPRITE_TURN_TIME, Transitions.EASE_IN);
			mHideTween.animate("alpha", 0);
			Starling.juggler.add(mHideTween);
			mMainScene.touchable = false;
			
			mTargetImg.visible = false;
			
			mSourceImg = new Image(event.data as Texture);
			stage.addChild(mSourceImg);
			mSourceImg.pivotX = mSourceImg.width / 2;
			mSourceImg.pivotY = mSourceImg.height / 2;
			mSourceImg.x = event.tX + mSourceImg.width / 2;
			mSourceImg.y = event.tY + mSourceImg.height / 2;
			
			var tx:Number = (stage.stageWidth/2 - mSourceImg.x) / 2 + mSourceImg.x;
			var ty:Number = (stage.stageHeight/2 - mSourceImg.y) / 2 + mSourceImg.y;
			
			mTurnTween = new Tween(mSourceImg, Constants.SPRITE_TURN_TIME, Transitions.EASE_IN);
			mTurnTween.moveTo(tx, ty);
			mTurnTween.animate("scaleX", 0);
			mTurnTween.animate("scaleY", (mSourceImg.height + (stage.stageHeight - mSourceImg.height)/ 2)/mSourceImg.height);
			mTurnTween.onComplete = turnComplete;
			Starling.juggler.add(mTurnTween);
		}
		
		private function turnComplete():void
		{
			mTargetImg.x = mSourceImg.x;
			mTargetImg.y = mSourceImg.y;
			mTargetImg.scaleX = mSourceImg.scaleX;
			mTargetImg.scaleY = mSourceImg.height / mTargetImg.height;
			mTargetImg.visible = true;
			mSourceImg.visible = false;
			
			mScaleTween = new Tween(mTargetImg, Constants.SPRITE_SCALE_TIME, Transitions.EASE_OUT);
			mScaleTween.moveTo(stage.stageWidth/2, stage.stageHeight/2);
			mScaleTween.animate("scaleX", 1);
			mScaleTween.animate("scaleY", 1);
			Starling.juggler.add(mScaleTween);
			mTargetImg.touchable = true;
		}
		
		private function spritePressedHandler(event:SpriteEvent):void
		{
			if (!isTweenCompleted())
				return;
			
			mHideTween = new Tween(mMainScene, Constants.SPRITE_TURN_TIME, Transitions.EASE_IN);
			mHideTween.animate("alpha", 0);
			Starling.juggler.add(mHideTween);
			mMainScene.touchable = false;
			
			mTargetImg.visible = false;
			
			mSourceImg = new Image(event.data as Texture);
			stage.addChild(mSourceImg);
			mSourceImg.pivotX = mSourceImg.width / 2;
			mSourceImg.pivotY = mSourceImg.height / 2;
			mSourceImg.x = event.tX + mSourceImg.width / 2;
			mSourceImg.y = event.tY + mSourceImg.height / 2;
			mSourceImg.visible = false;
			
			mTargetImg.x = mSourceImg.x;
			mTargetImg.y = mSourceImg.y;
			mTargetImg.scaleX = mSourceImg.width / mTargetImg.width;
			mTargetImg.scaleY = mSourceImg.height / mTargetImg.height;
			mTargetImg.visible = true;
			mScaleTween = new Tween(mTargetImg, Constants.SPRITE_SCALE_TIME, Transitions.EASE_OUT);
			mScaleTween.moveTo(stage.stageWidth/2, stage.stageHeight/2);
			mScaleTween.animate("scaleX", 1);
			mScaleTween.animate("scaleY", 1);
			Starling.juggler.add(mScaleTween);
			mTargetImg.touchable = true;
		}
		
		private function targetImgTouchHandler(event:TouchEvent):void
		{
			if (!isTweenCompleted())
				return;
			
			if (event.getTouch(mTargetImg, TouchPhase.ENDED)) //MouseUp
			{
				mTargetImg.visible = false;
				mTargetImg.touchable = false;
				
				mShowTween = new Tween(mMainScene, Constants.SPRITE_TURN_TIME, Transitions.EASE_IN);
				mShowTween.animate("alpha", 1);
				Starling.juggler.add(mShowTween);
				mMainScene.touchable = true;
			}
		}
		
		private var mMainScene:MainScene;
		
		private var mSourceImg:Image;
		private var mTargetImg:Image;
		
		protected var mHideTween:Tween;
		protected var mShowTween:Tween;
		protected var mTurnTween:Tween;
		protected var mScaleTween:Tween;
		
		[Embed(source = "/background.png")]
		private var Background:Class;
	}
}