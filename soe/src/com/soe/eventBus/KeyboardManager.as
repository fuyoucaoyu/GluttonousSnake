package com.soe.eventBus
{
    import flash.display.*;
    import flash.events.*;
    /**
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * KeyboardManager 
     * 说明：
     * 此类是“事件总线”中的“键盘总线”，负责管理KEY_DOWN、KEY_UP事件。
     * 使用KeyboardManager能杜绝按住某个按键连续触发KEY_DOWN的问题
     * 能即时检测某个按键是否在按下状态
     * KeyboardManager能正常作用需要stage获得焦点
     * 
     * 接口：
     * init(root:Sprite):void
     * 	初始化，在stage上addEventListener监听KEY_DOWN和KEY_UP事件
     * get isDown(keyCode:int):Boolean
     * 	获得某个键控代码对应按键是否按下的信息，与as2的Key.isDown类似
     * regFunc(func:Function,keyCode:int):void
     * 	对某个键控代码注册“按下”事件，用regFunc注册的Func不需要KeyboardEvent参数
     * 	不能重复对某个按键进行注册。如果需要请clearAll后重新注册或改写此类
     * mouseLeave() :void
     * 	stage失去焦点时调用，令所有按键变成“弹起”状态，避免错误操作
     * clearAll():void
     * 	清空所有已注册的监听方法
     * destroy():void
     * 	清空所有已注册的监听方法，并摧毁addEventListener注册的监听器，停止功耗
     * 	再次启用需要重新init();
     * 
     */
    public final class KeyboardManager {
        public static const N1:int = 0x31;
        public static const N2:int = 0x32;
        public static const N3:int = 0x33;
        public static const W:int = 87;
        public static const S:int = 83;
        public static const A:int = 65;
        public static const D:int = 68;
        public static const E:int = 69;
        public static const SPACE:int = 32;
        public static const P:int = 80
        public static const Q:int = 81;
        private static var _listener:Stage;
        private static var data:Object = {};
        private static var funcArray:Array = [];
        public static function init(root:Sprite):void {
            _listener = root.stage;
            _listener.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
            _listener.addEventListener(KeyboardEvent.KEY_UP,keyUp);
        }
        public static function mouseLeave() :void{
            data = {};
        }
        public static function isDown(keyCode:int):Boolean {
            if (data[keyCode]) {
                return true;
            }
            return false;
        }
        public static function regFunc(func:Function,keyCode:int):void {
            if(funcArray[keyCode]){
                throw new Error("重复对"+String(keyCode)+"进行按键注册方法可能造成管理混乱，请将同一按键执行的动作放置于一个统一的方法中");
            }
            funcArray[keyCode] = func
        }
        public static function clearAll() :void{
            funcArray = [];
        }
        public static function destroy() :void{
            clearAll();
            _listener.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
            _listener.removeEventListener(KeyboardEvent.KEY_UP,keyUp);
        }
        private static function keyDown(evt:KeyboardEvent):void {
            var i:int = evt.keyCode;
            if (! data[i]) {
                data[i] = true;
                if (funcArray[i]) {
                    funcArray[i]();
                }
            }			
        }
        private static function keyUp(evt:KeyboardEvent) :void{
            data[evt.keyCode] = false;
        }
        
    }
}