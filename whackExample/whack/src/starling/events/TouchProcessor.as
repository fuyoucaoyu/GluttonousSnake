// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.events
{
    import flash.geom.Point;
    
    import starling.display.DisplayObject;
    import starling.display.Stage;

    public class TouchProcessor
    {
        private static const MULTITAP_TIME:Number = 0.3;
        private static const MULTITAP_DISTANCE:Number = 25;
        
        private var mStage:Stage;
        private var mElapsedTime:Number;        
        private var mTouchMarker:TouchMarker;
        
        private var mCurrentTouches:Vector.<Touch>;
        private var mQueue:Vector.<Array>;
        private var mLastTaps:Vector.<Touch>;
        
        private var mShiftDown:Boolean = false;
        private var mCtrlDown:Boolean = false;
        
        public function TouchProcessor(stage:Stage)
        {
            mStage = stage;
            mElapsedTime = 0;
            mCurrentTouches = new <Touch>[];
            mQueue = new <Array>[];
            mLastTaps = new <Touch>[];
            
            mStage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
            mStage.addEventListener(KeyboardEvent.KEY_UP,   onKey);
        }

        public function dispose():void
        {
            mStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
            mStage.removeEventListener(KeyboardEvent.KEY_UP,   onKey);
            if (mTouchMarker) mTouchMarker.dispose();
        }
        
        public function advanceTime(passedTime:Number):void
        {
            mElapsedTime += passedTime;
            
            // remove old taps
            if (mLastTaps.length > 0)
            {
                mLastTaps = mLastTaps.filter(function(touch:Touch, ...rest):Boolean
                {
                    return mElapsedTime - touch.timestamp <= MULTITAP_TIME;
                });
            }
            
            while (mQueue.length > 0)
            {
                var processedTouchIDs:Vector.<int> = new <int>[];
                var touchID:int;
                var touch:Touch;
                var hoverTouch:Touch = null;
                var hoverTarget:DisplayObject = null;
                
                // update existing touches
                for each (var currentTouch:Touch in mCurrentTouches)
                {
                    // set touches that were moving to phase 'stationary'
                    if (currentTouch.phase == TouchPhase.MOVED)
                        currentTouch.setPhase(TouchPhase.STATIONARY);
                    
                    // check if target is still connected to stage, otherwise find new target
                    if (currentTouch.target.stage == null)
                        currentTouch.setTarget(mStage.hitTestPoint(
                            new Point(currentTouch.globalX, currentTouch.globalY), true));
                }
                
                // process new touches, but each ID only once
                while (mQueue.length > 0 && 
                    processedTouchIDs.indexOf(mQueue[mQueue.length-1][0]) == -1)
                {
                    var touchArgs:Array = mQueue.pop();
                    touchID = touchArgs[0] as int;
                    touch = getCurrentTouch(touchID);
                    
                    // hovering touches need special handling (see below)
                    if (touch && touch.phase == TouchPhase.HOVER)
                    {
                        hoverTouch = touch;
                        hoverTarget = touch.target;
                    }
                    
                    processTouch.apply(this, touchArgs);
                    processedTouchIDs.push(touchID);
                }
                
                // if the target of a hovering touch changed, we dispatch an event to the previous
                // target to notify it that it's no longer being hovered over.
                if (hoverTarget && hoverTouch.target != hoverTarget)
                {
                    hoverTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, mCurrentTouches,
                                                             mShiftDown, mCtrlDown));
                }
                
                // dispatch events
                for each (touchID in processedTouchIDs)
                {
                    touch = getCurrentTouch(touchID);
                    touch.target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, mCurrentTouches,
                                                              mShiftDown, mCtrlDown));
                }
                
                // remove ended touches
                mCurrentTouches = mCurrentTouches.filter(function(currentTouch:Touch, ...rest):Boolean
                {
                    return currentTouch.phase != TouchPhase.ENDED;
                });
                
                // timestamps must differ for remaining touches
                if (mQueue.length != 0) mElapsedTime += 0.00001;
            }
        }
        
        public function enqueue(touchID:int, phase:String, globalX:Number, globalY:Number):void
        {
            mQueue.unshift(arguments);
            
            // multitouch simulation (only with mouse)
            if (mCtrlDown && simulateMultitouch && touchID == 0) 
            {
                mTouchMarker.moveMarker(globalX, globalY, mShiftDown);
                
                // only mouse can hover
                if (phase != TouchPhase.HOVER)
                    mQueue.unshift([1, phase, mTouchMarker.mockX, mTouchMarker.mockY]);
            }
        }
        
        private function processTouch(touchID:int, phase:String, globalX:Number, globalY:Number):void
        {
            var position:Point = new Point(globalX, globalY);
            var touch:Touch = getCurrentTouch(touchID);
            
            if (touch == null)
            {
                touch = new Touch(touchID, globalX, globalY, phase, null);
                addCurrentTouch(touch);
            }
            
            touch.setPosition(globalX, globalY);
            touch.setPhase(phase);
            touch.setTimestamp(mElapsedTime);
            
            if (phase == TouchPhase.HOVER || phase == TouchPhase.BEGAN)
                touch.setTarget(mStage.hitTestPoint(position, true));
            
            if (phase == TouchPhase.BEGAN)
                processTap(touch);
        }
        
        private function onKey(event:KeyboardEvent):void
        {
            if (event.keyCode == 17) // ctrl key
            {
                mCtrlDown = event.type == KeyboardEvent.KEY_DOWN;
                
                if (simulateMultitouch)
                {
                    mTouchMarker.visible = mCtrlDown;
                    mTouchMarker.moveCenter(mStage.stageWidth/2, mStage.stageHeight/2);
                    
                    // if currently active, end mocked touch
                    var mockedTouch:Touch = getCurrentTouch(1);
                    if (mockedTouch && mockedTouch.phase != TouchPhase.ENDED) 
                        enqueue(1, TouchPhase.ENDED, mockedTouch.globalX, mockedTouch.globalY);
                }
            }
            else if (event.keyCode == 16) // shift key 
            {
                mShiftDown = event.type == KeyboardEvent.KEY_DOWN;
            }
        }
        
        private function processTap(touch:Touch):void
        {
            var nearbyTap:Touch = null;
            var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;
            
            for each (var tap:Touch in mLastTaps)
            {
                var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) +
                                    Math.pow(tap.globalY - touch.globalY, 2);
                if (sqDist <= minSqDist)
                {
                    nearbyTap = tap;
                    break;
                }
            }
            
            if (nearbyTap)
            {
                touch.setTapCount(nearbyTap.tapCount + 1);
                mLastTaps.splice(mLastTaps.indexOf(nearbyTap), 1);
            }
            else
            {
                touch.setTapCount(1);
            }
            
            mLastTaps.push(touch.clone());
        }
        
        private function addCurrentTouch(touch:Touch):void
        {
            mCurrentTouches = mCurrentTouches.filter(function(existingTouch:Touch, ...rest):Boolean
            {
                return existingTouch.id != touch.id;
            });
            
            mCurrentTouches.push(touch);
        }
        
        private function getCurrentTouch(touchID:int):Touch
        {
            for each (var touch:Touch in mCurrentTouches)
                if (touch.id == touchID) return touch;
            return null;
        }
        
        public function get simulateMultitouch():Boolean { return mTouchMarker != null; }
        public function set simulateMultitouch(value:Boolean):void
        { 
            if (simulateMultitouch == value) return; // no change
            if (value)
            {
                mTouchMarker = new TouchMarker();
                mTouchMarker.visible = false;
                mStage.addChild(mTouchMarker);
            }
            else
            {                
                mTouchMarker.removeFromParent(true);
                mTouchMarker = null;
            }
        }
    }
}
