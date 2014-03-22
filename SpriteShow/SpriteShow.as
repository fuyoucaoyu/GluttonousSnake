package
{
	import com.sprite.core.EmbeddedAssets;
	import com.sprite.core.MainContainer;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	[SWF(width="910", height="515", frameRate="60", backgroundColor="#FFFFFF")]
	public class SpriteShow extends Sprite
	{
		public function SpriteShow()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:* = null):void
		{
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
			Starling.multitouchEnabled = true; // for Multitouch Scene
			Starling.handleLostContext = true; // required on Windows, needs more memory
			
			mStarling = new Starling(MainContainer, stage);
			mStarling.simulateMultitouch = true;
			mStarling.enableErrorChecking = Capabilities.isDebugger;
			mStarling.start();
			
			// this event is dispatched when stage3D is set up
			mStarling.addEventListener(Event.ROOT_CREATED, onRootCreatedHlr);
		}
		
		private function onRootCreatedHlr(event:Event, game:MainContainer):void
		{
			// set framerate to 30 in software mode
			if (mStarling.context.driverInfo.toLowerCase().indexOf("software") != -1)
				mStarling.nativeStage.frameRate = 30;
			
			EmbeddedAssets.assetManager = new AssetManager();
			EmbeddedAssets.assetManager.verbose = Capabilities.isDebugger;
			EmbeddedAssets.assetManager.enqueue(EmbeddedAssets);
			
			EmbeddedAssets.assetManager.loadQueue(function(ratio:Number):void
			{
				if (ratio == 1)
					Starling.juggler.delayCall(function():void
					{
						trace(" ------- START ------");
						game.start();
					}, 0.15);
			});
        }
		
		private var mStarling:Starling;
	}
}