package com.sprite.events
{
	import starling.events.Event;
	
	public class SpriteEvent extends Event
	{
		public function SpriteEvent(type:String, bubbles:Boolean=false, data:Object=null, x:Number = 0, y:Number = 0)
		{
			mX = x;
			mY = y;
			super(type, bubbles, data);
		}

		public function get tY():Number
		{
			return mY;
		}

		public function get tX():Number
		{
			return mX;
		}
		
		private var mX:Number;
		private var mY:Number;
		
		public static const SPRITE_CLICKED:String = "spriteClicked"; 
		public static const SPRITE_PRESSED:String = "spritePressed";
	}
}