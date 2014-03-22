package com.sprite.scenes.scenePanel
{
	import com.sprite.core.Constants;
	
	import flash.utils.getTimer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;

	public class HScrollScenePanel extends BaseScrollingScenePanel
	{
		public function HScrollScenePanel()
		{
			super();
		}
		
		public function get scrollGap():int
		{
			return (mScrollGap > 0 ? mScrollGap : Constants.SPRITE_HSCROLLING_GAP);
		}

		public function set scrollGap(value:int):void
		{
			mScrollGap = value;
		}

		override protected function addImages():void
		{
			if (!mImages) return;
			
			var len:int = mImages.length;
			for (var i:int = 0; i < len; i++)
			{
				var img:Image = mImages[i];
				if (!img) continue;
				
				img.visible = true;
				img.x = img.width * i + Constants.SPRITE_BORDER_WIDTH * (i + 1);
				img.y = Constants.SPRITE_BORDER_WIDTH;
				mImagesContainer.addChild(img);
			}
			mImagesContainer.visible = false;
			this.addChild(mImagesContainer);
		}
		
		override protected function changeItem():void
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
			var targetX:Number = 0;
			if (mScrollingBack)
				targetX = mImagesContainer.x + mCurImage.width + Constants.SPRITE_BORDER_WIDTH;
			else
				targetX = mImagesContainer.x - mCurImage.width - Constants.SPRITE_BORDER_WIDTH;
			
			mMove.moveTo(targetX, mImagesContainer.y);
			Starling.juggler.add(mMove);
			trace("mMove tween start");
		}
		
		override protected function enterFrameHandler(event:Event):void
		{
			//Doing tween or without images
			if (mMove && !mMove.isComplete && !mCurImage) return;
			
			var deltTime:Number = getTimer() - mPretime;
			if (scrollGap < deltTime)
			{
				changeItem();
				mPretime = getTimer();
			}
		}
		
		protected var mScrollGap:int;
	}
}