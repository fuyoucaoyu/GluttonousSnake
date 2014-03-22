package com.sprite.scenes
{
	import com.sprite.core.Constants;
	import com.sprite.core.EmbeddedAssets;
	import com.sprite.events.SpriteEvent;
	import com.sprite.scenes.scenePanel.BaseScenePanel;
	import com.sprite.scenes.scenePanel.BaseScrollingScenePanel;
	import com.sprite.scenes.scenePanel.HScrollScenePanel;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class MainScene extends BaseScene
	{
		public function MainScene()
		{
			super();
			
			init();
		}
		
		public function init():void
		{
			mTimerPanel = new BaseScenePanel();
			mTimerPanel.image = new Image(EmbeddedAssets.assetManager.getTexture("timer"));
			mTimerPanel.x = 8;
			mTimerPanel.y = 11;
			mTimerPanel
			mTimerPanel.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mTimerPanel);
			
			mWeather = new BaseScenePanel();
			mWeather.image = new Image(EmbeddedAssets.assetManager.getTexture("weather"));
			mWeather.x = 179;
			mWeather.y = 11;
			mWeather.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mWeather);
			
			mInvestigation = new BaseScenePanel();
			mInvestigation.image = new Image(EmbeddedAssets.assetManager.getTexture("investigation"));
			mInvestigation.x = 8;
			mInvestigation.y = 178;
			mInvestigation.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mInvestigation);
			
			mEvaluation = new BaseScenePanel();
			mEvaluation.image = new Image(EmbeddedAssets.assetManager.getTexture("evaluation"));
			mEvaluation.x = 179;
			mEvaluation.y = 178;
			mEvaluation.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mEvaluation);
			
			mNews = new BaseScenePanel();
			mNews.image = new Image(EmbeddedAssets.assetManager.getTexture("news"));
			mNews.x = 8;
			mNews.y = 346;
			mNews.touchable = false;
			mNews.useHandCursor = false;
			//mNews.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mNews);
			
			
			mMainScrolling = new HScrollScenePanel();
			mMainScrolling.scrollGap = Constants.SPRITE_HSCROLLING_GAP1;
			mMainScrolling.images = new Array(new Image(EmbeddedAssets.assetManager.getTexture("mainScrolling")), new Image(EmbeddedAssets.assetManager.getTexture("mainScrolling")));
			mMainScrolling.x = 348;
			mMainScrolling.y = 9;
			mMainScrolling.clipRect = new Rectangle(348, 9, 556, 395);
			mMainScrolling.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mMainScrolling);
			
			
			mScrolling = new HScrollScenePanel();
			mScrolling.scrollGap = Constants.SPRITE_HSCROLLING_GAP2;
			mScrolling.images = new Array(new Image(EmbeddedAssets.assetManager.getTexture("scrolling")), new Image(EmbeddedAssets.assetManager.getTexture("scrolling")), new Image(EmbeddedAssets.assetManager.getTexture("scrolling")));
			mScrolling.x = 348;
			mScrolling.y = 406;
			mScrolling.clipRect = new Rectangle(348, 406, 556, 96);
			mScrolling.touchable = false;
			mScrolling.useHandCursor = false;
			//mScrolling.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			this.addChild(mScrolling);
		}
		
		private function onTouchHandler(event:TouchEvent):void
		{
			var curTouch:Touch;
			
			curTouch = event.getTouch(mTimerPanel, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_CLICKED, false, (curTouch.target as Image).texture, mTimerPanel.x, mTimerPanel.y));
				return;
			}
			
			
			curTouch = event.getTouch(mWeather, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_CLICKED, false, (curTouch.target as Image).texture, mWeather.x, mWeather.y));
				return;
			}
			
			curTouch = event.getTouch(mInvestigation, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_PRESSED, false, (curTouch.target as Image).texture, mInvestigation.x, mInvestigation.y));
				return;
			}
			
			curTouch = event.getTouch(mEvaluation, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_PRESSED, false, (curTouch.target as Image).texture, mEvaluation.x, mEvaluation.y));
				return;
			}
			
			curTouch = event.getTouch(mNews, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_CLICKED, false, (curTouch.target as Image).texture, mNews.x, mNews.y));
				return;
			}
			
			curTouch = event.getTouch(mMainScrolling, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_CLICKED, false, (curTouch.target as Image).texture, 349, 10));
				return;
			}
			
			curTouch = event.getTouch(mScrolling, TouchPhase.ENDED);
			if (curTouch) //MouseUp
			{
				dispatchEvent(new SpriteEvent(SpriteEvent.SPRITE_CLICKED, false, (curTouch.target as Image).texture, 349, 407));
				return;
			}
			
		}
		
		private var mTimerPanel:BaseScenePanel;
		private var mWeather:BaseScenePanel;
		private var mInvestigation:BaseScenePanel;
		private var mEvaluation:BaseScenePanel;
		private var mNews:BaseScenePanel;
		
		private var mScrolling:HScrollScenePanel;
		private var mMainScrolling:HScrollScenePanel;
	}
}