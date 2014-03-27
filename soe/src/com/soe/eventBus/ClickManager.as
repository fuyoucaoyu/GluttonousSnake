package com.soe.eventBus
{
    import flash.display.*;
    import flash.events.*;
    /**
     * 则存在一定问题
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * ClickManager 
     * 说明：
     * 此类是“事件总线”中的“点击总线”，负责管理CLICK事件。
     * 使用ClickManager能一次性卸载全部注册的点击事件，在场景/界面转换时很有用。
     * ClickManager也能将一些同parent的按钮归为一组，同时卸载它们的事件，对不切换场景，仅切换面板的项目有用。
     * ClickManager可以让鼠标点击执行的方法带MouseEvent以外的参数。
     * 
     * 接口：
     * regHeap(mc:DisplayObjectContainer):void
     * 	注册一个组，mc的所有子显示对象的事件都会归到这一组中。
     * add(btn:DisplayObject,func:Function,arg:* = null):void
     * 	为某个按钮/影片剪辑注册CLICK事件，CLICK事件触发时执行func(arg); arg可以为空，如果认为可变长度参数比单一参数好用可自行修改。
     * 	如果之前没有对按钮的父显示对象进行regHeap，会自动调用对其父显示对象regHeap
     * remove(btn:DisplayObject):void
     * 	移除对某个按钮按下的监听，这个方法不会移除已注册的组。
     * clearHeap(mc:DisplayObjectContainer):void
     * 	移除一个组以及该组子显示对象的全部CLICK监听
     * clearAll():void
     * 	清空所有已注册的监听方法
     * destroy():void
     * 	清空所有已注册的监听方法，ClickManager的destroy与clearAll功能相同，保留destroy仅为与其它事件总线类保持一致以及备扩展
     * 
     */
    public final class ClickManager{
        private static var heaps:Object = {};
        
        public static function regHeap(mc:DisplayObjectContainer):void{			
            heaps[mc.name] = {};
        }
        public static function add(btn:DisplayObject,func:Function,arg:* = null):void{
            if(!heaps[btn.parent.name]){
                regHeap(btn.parent);
            }
            var heap:Object = heaps[btn.parent.name];
            heap[btn.name]=[btn,func,arg];
            btn.addEventListener(MouseEvent.CLICK,proxyListener);
        }
        public static function remove(btn:DisplayObject):void{
            btn.removeEventListener(MouseEvent.CLICK,proxyListener);
            delete heaps[btn.parent.name][btn.name];
        }
        public static function clearHeap(mc:DisplayObjectContainer):void{
            var heap:Object = heaps[mc.name];
            for(var i:String in heap){
                heap[i][0].removeEventListener(MouseEvent.CLICK,proxyListener);
            }
            delete heaps[mc.name];
        }		
        private static function proxyListener(evt:MouseEvent):void{
            var heap:Object = heaps[evt.currentTarget.parent.name];
            var tmp:Array = heap[evt.currentTarget.name];
            if(tmp[2]==null){
                tmp[1]();	
            }else{
                tmp[1](tmp[2]);
            }
        }
        public static function clearAll():void{			
            for(var i:String in heaps){
                var heap:Object = heaps[i];
                for(var j:String in heap){
                    heap[j][0].removeEventListener(MouseEvent.CLICK,proxyListener);
                }
            }
            heaps = {};
        }
        public static function destroy():void{
            clearAll();
        }
    }
}