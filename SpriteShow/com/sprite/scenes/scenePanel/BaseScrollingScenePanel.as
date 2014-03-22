package com.sprite.scenes.scenePanel
{
	import com.sprite.core.Constants;
	import com.sprite.core.EmbeddedAssets;
	import com.sprite.utils.ClippedSprite;
	
	import flash.utils.getTimer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BaseScrollingScenePanel extends ClippedSprite
	{
		public function BaseScrollingScenePanel()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			mImages = [];
			mCurIndex = -1;
			mImagesContainer = new Sprite();
			mPretime = 0;
			
			mCurImage = null;
			
			this.touchable = true;
			this.useHandCursor = true;
			
			this.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function set images(value:Array):void
		{
			mImages = value;
			addImages();
			changeItem();
			createBackground();
			mPretime = getTimer();
		}
		
		protected function addImages():void
		{
			if (!mImages) return;
			
			var len:int = mImages.length;
			for (var i:int = 0; i < len; i++)
			{
				var img:Image = mImages[i];
				if (!img) continue;
				
				img.visible = true;
				img.x = Constants.SPRITE_BORDER_WIDTH;
				img.y = img.height * i + Constants.SPRITE_BORDER_WIDTH * (i + 1);
				mImagesContainer.addChild(img);
			}
			mImagesContainer.visible = false;
			this.addChild(mImagesContainer);
		}
		
		protected function changeItem():void
		{
			var len:int = mImages.length;
			
			//第一次直接显示
			if (mCurIndex < 0)
			{
				mCurIndex = 0;
				mCurImage = mImages[mCurIndex];
				mImagesContainer.visible = true;
				return;
			}
			//到达最后一个，者直接反向滚动
			else if (mCurIndex == (len - 1))
			{
				mScrollingBack = true;
			}
			else if (mCurIndex == 0)
			{
				mScrollingBack = false;
			}
			
			if (mScrollingBack) mCurIndex--;
			else mCurIndex++;
			
			mCurImage = mImages[mCurIndex];
			
			mMove = new Tween(mImagesContainer, Constants.SPRITE_SCROLLING_TIME, Transitions.EASE_OUT);
			var targetY:Number = 0;
			if (mScrollingBack)
				targetY = mImagesContainer.y + mCurImage.height + Constants.SPRITE_BORDER_WIDTH;
			else
				targetY = mImagesContainer.y - mCurImage.height - Constants.SPRITE_BORDER_WIDTH;
			
			mMove.moveTo(mImagesContainer.x, targetY);
			Starling.juggler.add(mMove);
			trace("mMove tween start");
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			//Doing tween or without images
			if (mMove && !mMove.isComplete && !mCurImage) return;
			
			var deltTime:Number = getTimer() - mPretime;
			if (Constants.SPRITE_VSCROLLING_GAP < deltTime)
			{
				changeItem();
				mPretime = getTimer();
			}
		}
		
		/**
		 * Border for the sprite.
		 */		
		protected function createBackground():void
		{
			if (!mCurImage) return;
			
			if (!mBgImg) mBgImg = new Image(EmbeddedAssets.assetManager.getTexture("panelBackground"));
			
			if (!this.contains(mBgImg)) this.addChildAt(mBgImg, 0);
			
			mBgImg.x = -Constants.SPRITE_BORDER_WIDTH;
			mBgImg.y = -Constants.SPRITE_BORDER_WIDTH;
			mBgImg.width = mCurImage.width + 2 * Constants.SPRITE_BORDER_WIDTH;
			mBgImg.height = mCurImage.height + 2 * Constants.SPRITE_BORDER_WIDTH;
			
			mBgImg.alpha = Constants.SPRITE_BORDER_ALPHA;
			
			mBgImg.visible = false;
		}
		
		private function onTouchHandler(event:TouchEvent):void
		{
			if (event.getTouch(this, TouchPhase.HOVER)) //Hover
			{
				if (mBgImg) mBgImg.visible =  true;
			}
			
			if (null == event.getTouch(this))//MouseOut
			{
				if (mBgImg) mBgImg.visible =  false;
			}
		}
		
		protected var mImages:Array;
		protected var mCurIndex:int;
		protected var mCurImage:Image;
		protected var mImagesContainer:Sprite;
		
		protected var mPretime:Number;
		protected var mScrollingBack:Boolean;
		protected var mMove:Tween;
		
		protected var mBgImg:Image;
	}
}