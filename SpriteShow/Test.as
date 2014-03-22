package
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	[SWF(width="1000", height="600", backgroundColor="#ffffff", frameRate=60)]
	public class Test extends flash.display.Sprite
	{
		public function Test()
		{
			super();
			
			// fix stage size is not the same on mobile device
			addEventListener(flash.events.Event.ENTER_FRAME, init);
		}
		
		private function init(p_event:flash.events.Event):void
		{
			removeEventListener(flash.events.Event.ENTER_FRAME, init);
			
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			
			m_starling = new Starling(starling.display.Sprite, stage);
			m_starling.simulateMultitouch  = false;
			m_starling.enableErrorChecking = false;
			m_starling.start();
			m_starling.addEventListener(starling.events.Event.ROOT_CREATED, function(p_event:starling.events.Event):void
			{
				var l_root:starling.display.Sprite = new starling.display.Sprite();
				m_starling.stage.addChild(l_root);
				m_starling.showStats = true;
				
				stage.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
			});
			
			m_q = new Quad(200, 100, 0xffcccc);
			m_q.x = 500;
			m_q.y = 300;
			m_q.pivotX = 100;
			m_q.pivotY = 50;
			m_starling.stage.addChild(m_q);
			
			m_qBack = new Quad(200, 100, 0xcccccc);
			m_qBack.x = 500;
			m_qBack.y = 300;
			m_qBack.pivotX = 100;
			m_qBack.pivotY = 50;
			m_qBack.visible = false;
			m_starling.stage.addChild(m_qBack);
			
			m_qShow = new Quad(1000, 600, 0xcccccc);
			m_qShow.x = 500;
			m_qShow.y = 300;
			m_qShow.pivotX = 500;
			m_qShow.pivotY = 300;
			m_qShow.visible = false;
			m_starling.stage.addChild(m_qShow);
		}
		
		private var m_vality:Number = 1.2;
		
		private function onEnterFrame(p_event:flash.events.Event):void
		{
			if (0 == m_direct)
			{
				m_q.scaleX -= 0.1 * m_vality;
				m_q.scaleY += 0.1 * m_vality;
				if (0 >= m_q.scaleX)
				{
					m_direct = 1;
					m_qBack.scaleX = 0;
					m_qBack.scaleY = 2;
					m_qBack.visible = true;
					m_q.visible = false;
				}
			}
			
			if (1 == m_direct)
			{
				m_qBack.scaleX -= 0.07 * m_vality;
				m_qBack.scaleY += 0.07 * m_vality;
				if (m_qBack.scaleX <= -1)
				{
					m_direct = 5
				}
			}
			
			if (5 == m_direct)
			{
				m_direct = 6;
				m_qShow.visible = true;
				m_qShow.width = m_qBack.width;
				m_qShow.height = m_qBack.height;
				m_qBack.visible = false;
			}
			
			if (6 == m_direct)
			{
				m_qShow.scaleX += 0.025 * m_vality;
				m_qShow.scaleY += 0.0155 * m_vality;
				if (1 <= m_qShow.scaleX)
				{
					m_direct = 7;
				}
			}
		}
		
		private var m_starling:Starling = null;
		private var m_q:Quad = null;
		private var m_direct:int = 0;
		private var m_time:Number = 0;
		private var m_qBack:Quad = null;
		private var m_qShow:Quad = null;
	}
}