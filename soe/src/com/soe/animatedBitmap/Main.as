/*
 * AnimatedBitmap Demo v1.0.0
 * Copyright(c) Copyright(c) Hexagon Star Softworks
 */

package com.soe.animatedBitmap
{
	import com.soe.animatedBitmap.display.FrameRateTimer;
	import com.soe.animatedBitmap.display.bitmaps.AnimatedBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	[SWF(width="448", height="320", backgroundColor="#111111", frameRate="99")]
	
	/**********************************************************************************
	 * Main Class
	 * @version 1.0.0
	 **********************************************************************************/
	public class Main extends Sprite
	{
		[Embed(source="./ring1_anim_seq.png")]
		private var RingClass:Class;
		private var _ringArray:Array;
		
		/******************************************************************************
		 * Constructs a new Main instance.
		 */
		public function Main()
		{
			stage.quality = StageQuality.LOW;
			start();
		}
		
		/******************************************************************************
		 * start
		 */
		private function start():void
		{
			_ringArray = new Array();
			var ringBitmap:BitmapData = Bitmap(new RingClass()).bitmapData;
			var timer:FrameRateTimer = new FrameRateTimer(24);
			var sizeW:int = 32;
			var sizeH:int = 32;
			var spacing:int = 0;
			var yPos:int = 0;
			var xPos:int = 0;
			var id:int = 0;
			
			do
			{
				var animBitmap:AnimatedBitmap = new AnimatedBitmap(ringBitmap,
					32, 32, timer);
				animBitmap.width = sizeW;
				animBitmap.height = sizeH;
				animBitmap.x = xPos;
				animBitmap.y = yPos;
				_ringArray.push(animBitmap);
				stage.addChild(animBitmap);
				playDelayed(id);
				
				if (xPos > stage.stageWidth - (sizeW * 2))
				{
					xPos = 0;
					yPos += sizeH + spacing;
				}
				else
				{
					xPos += sizeW + spacing;
				}
				id++;
			}
			while (yPos < stage.stageHeight);
			_ringArray.reverse();
		}
		
		/******************************************************************************
		 * playDelayed
		 */
		private function playDelayed(id:int):void
		{
			var ms:int = id * 5;//Math.random() * 500;
			var timer:Timer = new Timer(ms, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,
				onTimerComplete, false, 0, false);
			timer.start();
		}
		
		/******************************************************************************
		 * onTimerComplete
		 */
		private function onTimerComplete(event:TimerEvent):void
		{
			AnimatedBitmap(_ringArray.pop()).play();
		}
	}
}
