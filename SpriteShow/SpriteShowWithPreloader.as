package
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	[SWF(width="910", height="515", frameRate="60", backgroundColor="#FFFFFF")]
	public class SpriteShowWithPreloader extends MovieClip
	{
		public function SpriteShowWithPreloader()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener(Event.ENTER_FRAME, showLoading);
		}
		
		private function showLoading(event:Event):void
		{
			var bytesLoaded:int = this.loaderInfo.bytesLoaded;
			var bytesTotal:int = this.loaderInfo.bytesTotal;
			
			if (bytesLoaded >= bytesTotal && getTimer() > 1000)
			{
				removeEventListener(Event.ENTER_FRAME, showLoading);
				distoryProgressIndicator();
				run();
			}
			else
			{
				if (!m_indicator)
				{
					m_indicator = createProgressIndicator();
					m_indicator.x = stage.stageWidth  / 2;
					m_indicator.y = stage.stageHeight / 2;
				    this.addChild(m_indicator);
				}
				m_indicator.rotation += 7;
			}
		}
		
		private function createProgressIndicator():Shape
		{
			var indicatorShape:Shape = new Shape();
			var shapeGraphics:Graphics = indicatorShape.graphics;
			
			var elements:int = 8;    //elements number
			var radius:Number = 12;  //outer circle
			var angleDelta:Number = Math.PI * 2 / elements;
			var innerRadius:Number = radius / 4;
			var x:Number, y:Number, color:int;
			
			for (var i:int = 0; i < elements; i++)
			{
				x = radius * Math.cos(angleDelta * i);
				y = radius * Math.sin(angleDelta * i);
				color = 255 * i / elements;
				
				shapeGraphics.beginFill(((color << 16) | (color << 8) | color));
				shapeGraphics.drawCircle(x, y, innerRadius);
				shapeGraphics.endFill();
			}
			
			return indicatorShape;
		}
		
		private function distoryProgressIndicator():void
		{
			if (m_indicator)
			{
				if (this.contains(m_indicator))
					this.removeChild(m_indicator);
					
				m_indicator.graphics.clear();
				m_indicator = null;
			}
		}
		
		private function run():void 
		{
//			nextFrame();
//			
//			var startupClass:Class = getDefinitionByName(STARTUP_CLASS) as Class;
//			if (startupClass == null)
//				throw new Error("Invalid Startup class in Preloader: " + STARTUP_CLASS);
//			
//			var startupObject:DisplayObject = new startupClass() as DisplayObject;
			var startupObject:DisplayObject = new SpriteShow();
			if (startupObject == null)
				throw new Error("Startup class needs to inherit from Sprite or MovieClip.");
			
			addChildAt(startupObject, 0);
		}
		
		
		private var m_indicator:Shape; //loading indicator
		
		private const STARTUP_CLASS:String = "SpriteShow";
	}
}