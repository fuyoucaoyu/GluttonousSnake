package com.sprite.scenes.scenePanel
{
	import com.sprite.core.Constants;
	import com.sprite.core.EmbeddedAssets;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class BaseScenePanel extends Sprite
	{
		public function BaseScenePanel()
		{
			super();
			
			init();
		}
		
		protected function init():void
		{
			this.touchable = true;
			this.useHandCursor = true;
			
			this.addEventListener(TouchEvent.TOUCH, onTouchHandler);
		}
		
		public function set image(value:Image):void
		{
			mImg = value;
			this.addChild(mImg);
			
			trace(" --- " + this.width + " - " + mImg.width);
			
			createBackground();
		}
		
		/**
		 * Border for the sprite.
		 */		
		protected function createBackground():void
		{
			if (!mImg) return;
			
			if (!mBgImg) mBgImg = new Image(EmbeddedAssets.assetManager.getTexture("panelBackground"));
			
			if (!this.contains(mBgImg)) this.addChildAt(mBgImg, 0);
			
			mBgImg.x = -Constants.SPRITE_BORDER_WIDTH;
			mBgImg.y = -Constants.SPRITE_BORDER_WIDTH;
			mBgImg.width = mImg.width + 2 * Constants.SPRITE_BORDER_WIDTH;
			mBgImg.height = mImg.height + 2 * Constants.SPRITE_BORDER_WIDTH;
			
			mBgImg.alpha = Constants.SPRITE_BORDER_ALPHA;
			
			mBgImg.visible = false;
		}
		
		private function onTouchHandler(event:TouchEvent):void
		{
			if (event.getTouch(this, TouchPhase.HOVER)) //Hover
			{
				mBgImg.visible =  true;
			}
			
			if (null == event.getTouch(this))//MouseOut
			{
				mBgImg.visible =  false;
			}
		}
		
		protected var mImg:Image;
		protected var mBgImg:Image;
	}
}