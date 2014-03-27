package com.soe.eventBus
{
    import flash.events.*;
    import flash.display.* 
        
    /**
     * 
     * “事件总线”包说明：
     * 代替addEventListener管理最常用的CLICK、ENTER_FRAME、CLICK、MOUSE_DOWN、MOUSE_UP、KEY_DOWN、KEY_UP事件，
     * 使用事件总线不影响同时使用addEventListener但不推荐用addEventListener注册上面提到的几种事件
     * 
     * OEFManager 
     * 说明：
     * 此类是“事件总线”中的“OnEnterFrame总线”，负责管理ENTER_FRAME事件。
     * 使用OEFManager能轻易实现游戏、程序的“暂停”功能
     * 使用OEFManager能一次性移除所有注册的ENTER_FRAME事件，这在游戏开发的“过关”步骤尤为好用
     * OEFManager区分注册方法的种类，可以有部分方法不受暂停或清空的影响，例如游戏计时器、帧频检测器等
     * 
     * 接口：
     * init(root:Sprite):void
     *     初始化，在root上addEventListener监听ENTER_FRAME事件
     * pause():void
     *  暂停，暂停所有不是push(func,true)注册的监听方法，再调用一次恢复
     * add(func:Function):String
     *     添加一个可独立删除的监听方法，返回一个唯一id，记录这个id可以用remove移除该监听方法
     * remove(id:String):void
     *  移除一个监听方法
     * push(func:Function,hard:Boolean = false):void
     *  添加一个不可独立删除的监听方法，这样添加的方法会顺序执行并在add添加的方法之后执行，如果hard是true，那么这个“硬方法”无论程序是否暂停都会执行，并在add添加的方法之前执行
     *     push添加的监听方法可以用clearAll或者destroy移除
     * clearAll():void
     *     清空所有已注册的监听方法
     * destroy():void
     *     清空所有已注册的监听方法，并摧毁addEventListener注册的监听器，停止功耗
     *     再次启用需要重新init();
     * 
     */
    public final class OEFManager{
        private static var listener:Sprite;
        private static var softStack:Array = [];
        private static var hardStack:Array = [];
        private static var heap:Object = {};
        private static var nextID:int;
        private static var sa:int = 0;
        private static var isPaused:Boolean = false;
        
        public static function init(root:Sprite):void{
            listener = root;
            listener.addEventListener(Event.ENTER_FRAME,enterFrameLimit);            
        }            
        public static function pause():void{
            isPaused = true;
        }
        public static function resume():void{
            isPaused = false;
        }
        public static function add(func:Function):String{
            var id:String = String(nextID);
            heap[id] = func;
            nextID++;
            return id;
        }        
        
        public static function remove(id:String):void{                
            if(heap[id]){                
                delete heap[id]                    
            }
        }
        public static function push(func:Function,hard:Boolean = false):void{            
            if(hard){
                hardStack.push(func);
            }else{
                softStack.push(func);                    
            }                
        }
        public static function clearAll():void{
            softStack = [];                
            heap = {};
            nextID = 0;
        }
        public static function destroy():void{
            clearAll();
            hardStack = [];
            listener.removeEventListener(Event.ENTER_FRAME,enterFrame);
        }
        private static function enterFrameLimit(evt:Event):void{
            enterFrameHard();
            if(isPaused){
                return;
            }                
            enterFrame();                            
        }
        private static function enterFrame():void{
            for(var s:int = 4;s>=0;s--){                    
                for(var j:String in heap){
                    heap[j]();
                }
            }                
            var len:int = softStack.length; 
            for(var i:int = 0;i<len;i++){
                softStack[i]();
            }            
        }
        private static function enterFrameHard():void{                    
            var len:int = hardStack.length; 
            for(var i:int = 0;i<len;i++){                    
                hardStack[i]();
            }
        }    
    }
}