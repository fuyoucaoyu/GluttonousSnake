package com.soe.collisionDetection
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public class BitmapCollisionDetection
    {
        public function BitmapCollisionDetection()
        {
        }
        
        static public function checkForCollision(p_clip1:MovieClip,p_clip2:MovieClip,p_alphaTolerance:Number):Rectangle {
            
            // set up default params:
            if (p_alphaTolerance == undefined) { p_alphaTolerance = 255; }
            
            // 加载的 AVM1Movie 对象将作为 AVM1 SWF 文件和它加载的所有 AVM1 SWF 文件的 psuedo-root 对象操作（如同将 ActionScript 1.0 lockroot 属性设置为 true）。
            //AVM1 影片始终位于任何子级中任何 ActionScript 1.0 或 2.0 代码执行的顶部。除非在加载的 AVM1 SWF 文件中设置 lockroot 属性，
            //否则加载的子级的 _root 属性通常均为该 AVM1 SWF 文件。 
            // avm1 _root 相当于 avm2 root
            // root是swf的主类，stage是root的parent，是所有显示对象的根
            // _root.gotoAndPlay()  改为MovieClip(root).gotoAndPlay()就行了
            // 
            // this["root"].gotoAndPlay()   
            // MovieClip(root).gotoAndPlay()
            //            上一级是this["parent"].gotoAndPlay();
            //            根下的东西是root["asdfasdf"].gotoAndPlay()
            // bitmap 的 root 是他本身。
            
            // get bounds:
            var bounds1:Object = p_clip1.getBounds(MovieClip(p_clip1.root));
            var bounds2:Object = p_clip2.getBounds(MovieClip(p_clip2.root));
            
            // rule out anything that we know can't collide:
            if (((bounds1.xMax < bounds2.xMin) || (bounds2.xMax < bounds1.xMin)) || ((bounds1.yMax < bounds2.yMin) || (bounds2.yMax < bounds1.yMin)) ) {
                return null;
            }
            
            // determine test area boundaries:
            var bounds:Object = {};
            bounds.xMin = Math.max(bounds1.xMin,bounds2.xMin);
            bounds.xMax = Math.min(bounds1.xMax,bounds2.xMax);
            bounds.yMin = Math.max(bounds1.yMin,bounds2.yMin);
            bounds.yMax = Math.min(bounds1.yMax,bounds2.yMax);
            
            // set up the image to use:
            var img:BitmapData = new BitmapData(bounds.xMax-bounds.xMin,bounds.yMax-bounds.yMin,false);
            
            // draw in the first image:
            var mat:Matrix = p_clip1.transform.concatenatedMatrix;
            mat.tx -= bounds.xMin;
            mat.ty -= bounds.yMin;
            img.draw(p_clip1,mat, new ColorTransform(1,1,1,1,255,-255,-255,p_alphaTolerance));
            
            // overlay the second image:
            mat = p_clip2.transform.concatenatedMatrix;
            mat.tx -= bounds.xMin;
            mat.ty -= bounds.yMin;
            img.draw(p_clip2,mat, new ColorTransform(1,1,1,1,255,255,255,p_alphaTolerance),"difference");
            
            // find the intersection:
            var intersection:Rectangle = img.getColorBoundsRect(0xFFFFFFFF,0xFF00FFFF);
            
            // if there is no intersection, return null:
            if (intersection.width == 0) { return null; }
            
            // adjust the intersection to account for the bounds:
            intersection.x += bounds.xMin;
            intersection.y += bounds.yMin;
            
            return intersection;
        }
    }
}