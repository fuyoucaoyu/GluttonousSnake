// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;
    
    import starling.core.RenderSupport;
    import starling.errors.AbstractClassError;
    import starling.events.Event;
    
    public class DisplayObjectContainer extends DisplayObject
    {
        // members
        
        private var mChildren:Vector.<DisplayObject>;
        
        // construction
        
        public function DisplayObjectContainer()
        {
            if (getQualifiedClassName(this) == "starling.display::DisplayObjectContainer")
                throw new AbstractClassError();
            
            mChildren = new <DisplayObject>[];
        }
        
        public override function dispose():void
        {
            for each (var child:DisplayObject in mChildren)
                child.dispose();
                
            super.dispose();
        }
        
        // child management
        
        public function addChild(child:DisplayObject):void
        {
            addChildAt(child, numChildren);
        }
        
        public function addChildAt(child:DisplayObject, index:int):void
        {
            if (index >= 0 && index <= numChildren)
            {
                child.removeFromParent();
                mChildren.splice(index, 0, child);
                child.setParent(this);                
                child.dispatchEvent(new Event(Event.ADDED));                
                if (stage) child.dispatchEventOnChildren(new Event(Event.ADDED_TO_STAGE));
            }
            else
            {
                throw new RangeError("Invalid child index");
            }
        }
        
        public function removeChild(child:DisplayObject, dispose:Boolean=false):void
        {
            var childIndex:int = getChildIndex(child);
            if (childIndex != -1) removeChildAt(childIndex, dispose);
        }
        
        public function removeChildAt(index:int, dispose:Boolean=false):void
        {
            if (index >= 0 && index < numChildren)
            {
                var child:DisplayObject = mChildren[index];
                child.dispatchEvent(new Event(Event.REMOVED));
                if (stage) child.dispatchEventOnChildren(new Event(Event.REMOVED_FROM_STAGE));
                child.setParent(null);
                mChildren.splice(index, 1);
                if (dispose) child.dispose();
            }
            else
            {
                throw new RangeError("Invalid child index");
            }
        }
        
        public function removeChildren(beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false):void
        {
            if (endIndex < 0 || endIndex >= numChildren) 
                endIndex = numChildren - 1;
            
            for (var i:int=beginIndex; i<=endIndex; ++i)
                removeChildAt(beginIndex, dispose);
        }
        
        public function getChildAt(index:int):DisplayObject
        {
            return mChildren[index];
        }
        
        public function getChildByName(name:String):DisplayObject
        {
            for each (var currentChild:DisplayObject in mChildren)
                if (currentChild.name == name) return currentChild;
            return null;
        }
        
        public function getChildIndex(child:DisplayObject):int
        {
            return mChildren.indexOf(child);
        }
        
        public function setChildIndex(child:DisplayObject, index:int):void
        {
            var oldIndex:int = getChildIndex(child);
            if (oldIndex == -1) throw new ArgumentError("Not a child of this container");
            mChildren.splice(oldIndex, 1);
            mChildren.splice(index, 0, child);
        }
        
        public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
        {
            var index1:int = getChildIndex(child1);
            var index2:int = getChildIndex(child2);
            if (index1 == -1 || index2 == -1) throw new ArgumentError("Not a child of this container");
            swapChildrenAt(index1, index2);
        }
        
        public function swapChildrenAt(index1:int, index2:int):void
        {
            var child1:DisplayObject = getChildAt(index1);
            var child2:DisplayObject = getChildAt(index2);
            mChildren[index1] = child2;
            mChildren[index2] = child1;
        }
        
        public function contains(child:DisplayObject):Boolean
        {
            if (child == this) return true;
            
            for each (var currentChild:DisplayObject in mChildren)
            {
                if (currentChild is DisplayObjectContainer)
                {
                    if ((currentChild as DisplayObjectContainer).contains(child)) return true;
                }
                else
                {
                    if (currentChild == child) return true;
                }
            }
            
            return false;
        }
        
        // other methods
        
        public override function getBounds(targetSpace:DisplayObject):Rectangle
        {
            var numChildren:int = mChildren.length;
            
            if (numChildren == 0)
            {
                var matrix:Matrix = getTransformationMatrixToSpace(targetSpace);
                var position:Point = matrix.transformPoint(new Point(x, y));
                return new Rectangle(position.x, position.y);
            }
            else if (numChildren == 1)
            {
                return mChildren[0].getBounds(targetSpace);
            }
            else
            {
                var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
                var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
                for each (var child:DisplayObject in mChildren)
                {
                    var childBounds:Rectangle = child.getBounds(targetSpace);
                    minX = Math.min(minX, childBounds.x);
                    maxX = Math.max(maxX, childBounds.x + childBounds.width);
                    minY = Math.min(minY, childBounds.y);
                    maxY = Math.max(maxY, childBounds.y + childBounds.height);                    
                }
                return new Rectangle(minX, minY, maxX-minX, maxY-minY);
            }                
        }
        
        public override function hitTestPoint(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;
            
            var numChildren:int = mChildren.length;
            for (var i:int=numChildren-1; i>=0; --i) // front to back!
            {
                var child:DisplayObject = mChildren[i];
                var transformationMatrix:Matrix = getTransformationMatrixToSpace(child);
                var transformedPoint:Point = transformationMatrix.transformPoint(localPoint);
                var target:DisplayObject = child.hitTestPoint(transformedPoint, forTouch);
                if (target) return target;
            }
            
            return null;
        }
        
        public override function render(support:RenderSupport, alpha:Number):void
        {
            alpha *= this.alpha;
            
            for each (var child:DisplayObject in mChildren)
            {
                if (child.alpha != 0.0 && child.visible && child.scaleX != 0 && child.scaleY != 0)
                {
                    support.pushMatrix();
                    
                    support.transformMatrix(child);
                    child.render(support, alpha);
                    
                    support.popMatrix();
                }
            }
        }
        
        // internal methods
        
        internal override function dispatchEventOnChildren(event:Event):void 
        { 
            // the event listeners might modify the display tree, which could make the loop crash. 
            // thus, we collect them in a list and iterate over that list instead.
            
            var listeners:Vector.<DisplayObject> = new <DisplayObject>[];
            getChildEventListeners(this, event.type, listeners);
            for each (var listener:DisplayObject in listeners)
                listener.dispatchEvent(event);
        }
        
        private function getChildEventListeners(object:DisplayObject, eventType:String, 
                                                listeners:Vector.<DisplayObject>):void
        {
            var container:DisplayObjectContainer = object as DisplayObjectContainer;                
            if (object.hasEventListener(eventType))
                listeners.push(object);
            if (container)
                for each (var child:DisplayObject in container.mChildren)
                    getChildEventListeners(child, eventType, listeners);
        }
        
        // properties
        
        public function get numChildren():int { return mChildren.length; }        
    }
}