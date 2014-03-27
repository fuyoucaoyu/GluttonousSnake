package com.soe.eventBus
{
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    /**
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * TimerManager 
     * 说明：
     * 此类是“事件总线”中的“延迟执行总线”，注意，这个类并不取代Timer的功能，仅仅负责谋些方法延迟若干帧后再执行。
     * 使用TimerManager能让某个方法延迟若干帧后再执行，
     * 适合匿名对象/弱引用对象希望延迟调用方法时使用
     * 也能给非MovieClip对象模拟addFrameScript功能
     * 能一次性移除所有等待执行的方法，这个功能在游戏项目的过关时或者跳转场景时很有用
     * 
     * 接口：
     * init(root:Sprite):void
     * 	初始化，在root上addEventListener监听ENTER_FRAME事件
     * pause():void
     *  暂停，暂停所有不是push(func,true)注册的监听方法，再调用一次恢复
     * add(func:Function,timeout:int):void
     * 	注册的func会在timeout帧之后执行。这个“命令”不能取消，如果希望取消，请改写此类
     * clearAll():void
     * 	清空所有已注册的监听方法
     * destroy():void
     * 	清空所有已注册的监听方法，并摧毁addEventListener注册的监听器，停止功耗
     * 	再次启用需要重新init();
     * 
     */
    public final class TimerManager {
        private static var softHeap:Object={};
        private static var listener:Sprite;
        private static var timer:int=0;
        public static function init(root:Sprite) :void{
            listener=root;
            listener.addEventListener(Event.ENTER_FRAME,enterFrame);
        }
        public static function add(func:Function,timeout:int):void{			
            if(softHeap[timer+timeout]){
                softHeap[timer+timeout].push(func);
            }else{
                softHeap[timer+timeout]=[func];
            }
        }
        public static function clearAll():void{
            softHeap = {};
        }
        public static function destroy():void{
            clearAll();
            listener.removeEventListener(Event.ENTER_FRAME,enterFrame);
        }
        private static function enterFrame(evt:Event):void {
            timer++;
            if(softHeap[timer]){
                var len:int = softHeap[timer].length;
                for(var i:int = 0;i<len;i++){
                    softHeap[timer][i]();
                }
                delete softHeap[timer];
            }
        }
        
    }
}