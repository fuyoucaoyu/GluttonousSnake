package com.soe.eventBus
{
    import flash.display.*
    import flash.events.*
    /**
     *  “用一组类将全部事件管理起来”
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * MasterManager 
     * 说明：
     * 此类是“事件总线”的“总线”，负责该包内所有其它事件总线类的管理，可以统一初始化或回收所有事件总线相关类
     * 此类无管理功能外的其它实际作用，从该包中剔除不影响其它类功能
     * 
     * 接口：
     * init(root:Sprite):void
     * 	初始化其它事件总线，包括KeyboardManager,MasterManager,OEFManager和TimerManager，其中ClickManager无需初始化
     * clearAll():void
     * 	通知其他事件总线清空当前已经注册的全部监听方法。
     * destroy():void
     * 	通知其他事件总线清空当前已经注册的全部监听方法，并摧毁addEventListener注册的监听器，完全停止事件总线的功耗
     * 	在destroy()后需要继续使用事件总线需要重新init();
     * 
     */
    public final class MasterManager {
        public static function init(root:Sprite):void{
            MouseManager.init(root)
            KeyboardManager.init(root);
            TimerManager.init(root);
            OEFManager.init(root);			
            root.stage.addEventListener(Event.DEACTIVATE,mouseLeave);
        }		
        public static function clearAll():void{
            MouseManager.clearAll();
            KeyboardManager.clearAll();
            TimerManager.clearAll();
            OEFManager.clearAll();			
            ClickManager.clearAll();
        }
        public static function destroy():void{
            MouseManager.destroy();
            KeyboardManager.destroy();
            OEFManager.destroy();
            TimerManager.destroy();
            ClickManager.destroy();
        }
        private static function mouseLeave(evt:Event):void{
            MouseManager.mouseLeave();
            KeyboardManager.mouseLeave();
        }
    }
}