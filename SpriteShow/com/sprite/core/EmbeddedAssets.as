package com.sprite.core
{
	import starling.utils.AssetManager;

    public class EmbeddedAssets
    {
        /** ATTENTION: Naming conventions!
         *  
         *  - Classes for embedded IMAGES should have the exact same name as the file,
         *    without extension. This is required so that references from XMLs (atlas, bitmap font)
         *    won't break.
         *    
         *  - Atlas and Font XML files can have an arbitrary name, since they are never
         *    referenced by file name.
         * 
         */
        
        [Embed(source = "/assets/textures/sprite/timer.png")]
        public static const timer:Class;
		
		[Embed(source = "/assets/textures/sprite/weather.png")]
		public static const weather:Class;
		
		[Embed(source = "/assets/textures/sprite/evaluation.png")]
		public static const evaluation:Class;
		
		[Embed(source = "/assets/textures/sprite/investigation.png")]
		public static const investigation:Class;
		
		[Embed(source = "/assets/textures/sprite/news.png")]
		public static const news:Class;
		
		[Embed(source = "/assets/textures/sprite/mainScrolling.png")]
		public static const mainScrolling:Class;
		
		[Embed(source = "/assets/textures/sprite/scrolling.png")]
		public static const scrolling:Class;
		
		[Embed(source = "/assets/textures/sprite/panelBackground.png")]
		public static const panelBackground:Class;
		
		[Embed(source = "/assets/textures/sprite/helloPanel.png")]
		public static const helloPanel:Class;
        
        // Sounds
        [Embed(source="/assets/audio/wing_flap.mp3")]
        public static const wing_flap:Class;
		
		
		public static var assetManager:AssetManager;
    }
}