package com.soe.eventBus
{
    import flash.display.*;
    import flash.events.*;
    import flash.ui.Mouse;
    /**
     *  则存在一定问题
     * 
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * MouseManager 
     * 说明：
     * 此类是“事件总线”中的“鼠标总线”，负责管理MOUSE_DOWN、MOUSE_UP事件。
     * 使用MouseManager能设置自定义鼠标
     * 获得鼠标是否按下
     * MouseManager不直接响应MOUSE_DOWN或者MOUSE_UP。如果不需要在一帧内监听多次鼠标按下，或者需要很精确地监听鼠标按下，作者更推荐用ENTER_FRAME或本包提供的OEFManager逐帧检测鼠标是否按下并对其响应
     * 
     * 接口：
     * init(root:Sprite):void
     * 	初始化，在stage上addEventListener监听MOUSE_DOWN和MOUSE_UP事件
     * mouseLeave():void
     * 	stage失去焦点时调用，令鼠标状态变为“弹起”避免错误操作
     * bindingMouseMC(mc:MovieClip,parent:DisplayObjectContainer)
     * 	在parent下添加一个影片剪辑作为自定义鼠标，会对该自定义鼠标添加鼠标跟随并隐藏默认鼠标
     * get isDown():Boolean
     * 	获得鼠标是否按下
     * get mouseX():Number
     * 	获得鼠标对场景x坐标
     * get mouseY():Number
     * 	获得鼠标对场景y坐标
     * clearAll():void
     * 	清空所有已注册的监听方法
     * destroy():void
     * 	清空所有已注册的监听方法，并摧毁addEventListener注册的监听器，停止功耗
     * 	再次启用需要重新init();
     * 
     */
    public final class MouseManager{
        private static var listener:Stage;
        private static var _isDown:Boolean = false;
        public static var mouseMC:MovieClip = null;
        public static function init(root:Sprite):void{
            listener = root.stage;			
            root.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
            root.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
        }
        
        public static function mouseLeave():void{
            _isDown = false;
        }
        public static function bindingMouseMC(mc:MovieClip,parent:DisplayObjectContainer):void{
            if(mouseMC){
                mouseMC.destroy();
                listener.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
            }
            Mouse.hide();
            mouseMC = mc;
            mc.mouseEnabled = false;
            mc.mouseChildren = false;
            parent.addChild(mc);
            listener.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
            mouseMC.x = listener.mouseX;
            mouseMC.y = listener.mouseY;
            //listener.addEventListener(Event.ENTER_FRAME,mouseMove);
        }		
        public static function get isDown():Boolean{
            return _isDown;
        }
        public static function get mouseX():Number{
            return listener.mouseX;
        }
        public static function get mouseY():Number{
            return listener.mouseY;
        }
        public static function clearAll():void{
            //给MouseOver和即时MouseDown事件备用
            listener.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
        }
        public static function destroy():void{
            clearAll();
        }
        private static function mouseMove(evt:Event):void{
            mouseMC.x = listener.mouseX;
            mouseMC.y = listener.mouseY;
        }
        private static function mouseDown(evt:MouseEvent):void{			
            _isDown = true;
        }
        private static function mouseUp(evt:MouseEvent):void{
            _isDown =false;
        }
        
    }
}