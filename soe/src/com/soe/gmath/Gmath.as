/**
 *@Description:
 *	Gmath数学类集成了常用二维数学运算公式
 *	此版本是精简版a组
 *	集中解决速度分解与合成问题
 *	此版本通用数组来作为参数和返回值，有必要的话请自行生成实体类
 */


/*
名词注释：
角度角：每周360度
弧度角：每周2*Math.PI
数学坐标系：特指数学平面直角坐标系，以垂直方向为y轴，竖直向上为正方向；以水平方向为x轴，水平向右为正方向；以x轴正方向为0度，逆时针为正向旋转，弧度角，常用值0~2*PI
flash坐标系：以垂直方向为y轴，竖直向下为正方向；以水平方向为x轴，水平向右为正方向,角度角，常用值-180~180
因flash实际开发中，大部分俯视视角的美工素材以上方即y轴负方向为默认方向，故此处flash坐标系以y轴负方向0度，顺时针为正向旋转。
无特殊说明前提下，Gmath Lite系列普遍使用flash坐标系以及角度角
*/

package {	
    public class Gmath {
        public static const TO_PI:Number = 0.017453292519943295;//等于Math.PI/180
        public static const TO_ROT:Number = 57.29577951308232;//等于180/Math.PI
        
        /**
        * 获得相对于mc前方front，右方right的一个点的坐标。其中“前方”是以mc.rotation属性确定的。
        * 如果不希望以mc.rotation作为正方向，请使用relativePos_A()方法或改写此方法
        * mc通常为Sprite，但也支持包含x,y,rotation属性的其它自定义类
        * 
        * @param:
        *     mc:参考影片剪辑
        *     front:目标点到mc距离在mc前方的投影长度
        *     right:目标点到mc距离在mc右方的投影长度
        * 
        * @return:
        *     返回值是一个二元数组values
        *         values[0]:目标点横坐标
        *         values[1]:目标点纵坐标
        */  
        public static function relativePos_O(mc:Object,front:Number,right:Number=0):Array{			
            var rot_PI:Number = (90-mc.rotation)*TO_PI
            var x:Number = mc.x+front*Math.cos(rot_PI)+right*Math.sin(rot_PI)
            var y:Number = mc.y-front*Math.sin(rot_PI)+right*Math.cos(rot_PI)
            return [x,y];
        }
        
        /**
         * 获得相对于srcPos前方front，右方right的一个点的坐标。其中“前方”是以srcPos[2]确定的
         * 
         * @param:
         *   srcPos:参考点及参考正方向
         *   srcPos[0]:参考点横坐标
         *   srcPos[1]:参考点纵坐标
         *   srcPos[2]:参考正方向，以flash坐标轴为参考系的一个角度角
         *   front:目标点到原点距离在指向正方向的投影长度
         *   right:目标点到原点距离在垂直于正方向向右的投影长度
         * @return:
         *    返回值是一个二元数组values
         *        values[0]:目标点横坐标
         *        values[1]:目标点纵坐标
         */
        public static function relativePos_A(srcPos:Array,front:Number,right:Number=0):Array{			
            var rot_PI:Number = (90-srcPos[2])*TO_PI
            var x:Number = srcPos[0]+front*Math.cos(rot_PI)+right*Math.sin(rot_PI)
            var y:Number = srcPos[1]-front*Math.sin(rot_PI)+right*Math.cos(rot_PI)
            return [x,y];
        }
        
        /**
         * 通过改变x,y属性使一个对象(多为影片剪辑)发生相对移动，front是向前移动的距离，right是向右移动的距离，以mc.rotation为正方向
         * 笔者从自认开发经验认为此方法不需要加个角度参数，如果不希望以mc.rotation为正方向，
         * 请使用relativePos_A()方法后再修改mc的x,y值，或自行改写此方法
         * mc通常为Sprite，但也支持包含x,y,rotation属性的其它自定义类
         *
         * @param:
         *   mc:目标对象
         *   front:目标对象向前移动的距离
         *   right:目标对象向右移动的距离
         */
        public static function relativeMove_O(mc:Object,front:Number,right:Number=0):void{
            var rot_PI:Number = mc.rotation*TO_PI;
            var sinRot:Number = Math.sin(rot_PI)
            var cosRot:Number = Math.cos(rot_PI);
            mc.x+= front*sinRot+right*cosRot
            mc.y+=-front*cosRot+right*sinRot
        }
        
        /**
         * 直接修改srcPos的数值，改写为相对于srcPos前方front，右方right的一个点的坐标。其中“前方”是以srcPos[2]确定的
         * 此方法与relativePos_A的不同是此方法直接覆盖srcPos而不生成新的返回值。
         * srcPos[2]不会被覆盖
         * @param:
         *   srcPos:参考点及参考正方向
         *   srcPos[0]:参考点横坐标
         *   srcPos[1]:参考点纵坐标
         *   srcPos[2]:参考正方向，以flash坐标轴为参考系的一个角度角
         *   front:目标点到原点距离在指向正方向的投影长度
         *   right:目标点到原点距离在垂直于正方向向右的投影长度
         */
        public static function relativeMove_A(srcPos:Array,front:Number,right:Number=0):void{
            var rot_PI:Number = srcPos[2]*TO_PI;
            var sinRot:Number = Math.sin(rot_PI)
            var cosRot:Number = Math.cos(rot_PI);
            srcPos[0]+= front*sinRot+right*cosRot
            srcPos[1]+=-front*cosRot+right*sinRot
        }		
        
        /**
         * 速度正交分解&合成公式
         * 在已知x速度和y速度的前提下，可以获得指向任意角度的分速度
         * 
         * @param:
         *   speeds_xyr:一个三元数组
         *   speeds_xyr[0]:x方向速度
         *   speeds_xyr[1]:y方向速度
         *   speeds_xyr[2]:希望分解速度的方向
         *   @return:
         *   values:一个三元数组
         *   values[0]:指向speeds_xyr[2]方向的分速度
         *   values[1]:垂直于speeds_xyr[2]方向向右的分速度
         *   values[2]:等同于speeds_xyr[2]
         */
        public static function decByRotation(speeds_xyr:Array):Array{
            var xspeed:Number = speeds_xyr[0];
            var yspeed:Number = speeds_xyr[1];
            var rotation:Number = speeds_xyr[2];
            var rotFs_PI:Number = rotation*TO_PI
            var rotRs_PI:Number = (rotation+90)*TO_PI;		
            var rs:Number = yspeed*Math.sin(rotFs_PI)+xspeed*Math.cos(rotFs_PI);
            var fs:Number = -yspeed*Math.sin(rotRs_PI)-xspeed*Math.cos(rotRs_PI);
            return [fs,rs,rotation];
        }
        
        /**
         * 速度正交分解&合成公式逆运算
         * 在已知速度角度以及平行、垂直于该角度两个分速度的前提下，得出x速度和y速度
         * 
         * @param:
         *     speeds_frr:一个三元数组
         *     speeds_frr[0]:指向正方向的速度
         *     speeds_frr[1]:垂直于正方向向右的速度
         *     speeds_frr[2]:原始速度正方向
         * @return:
         *     values:一个二元数组
         *     values[0]:指向x方向速度
         *     values[1]:指向y方向速度
         */
        public static function synByRotation(speeds_frr:Array):Array{		
            var fspeed:Number = speeds_frr[0];
            var rspeed:Number = speeds_frr[1];
            var rotation:Number = speeds_frr[2];
            var rotFs_PI:Number = rotation*TO_PI
            var xspeed:Number = fspeed*Math.sin(rotFs_PI) +rspeed*Math.cos(rotFs_PI);
            var yspeed:Number =-fspeed*Math.cos(rotFs_PI) +rspeed*Math.sin(rotFs_PI);		
            return [xspeed,yspeed];
        }
        
        /**
         * 取得p1和p2之间连线与垂直方向夹角
         *   
         * @param:
         *     p1,p2:两个点
         *     p1[0],p2[0]:两个点的横坐标
         *     p1[1],p2[1]:两个点的纵坐标
         * @return:
         *     values:p1,p2连线与垂直方向夹角
         */
        public static function getAngle_A(p1:Array,p2:Array):Number{
            var rt:Number = Math.atan2(p2[1]-p1[1],p2[0]-p1[0]);
            rt = rt*TO_ROT+90
            if(rt>180){
                rt-=360;
            }
            return rt;
        }
        
        /**
         * 取得p1和p2之间连线与垂直方向夹角
         *  
         * @param:
         *     p1,p2:可以是Point或Sprite或拥有x,y属性的自定义类。
         * @return:
         *     values:p1,p2连线与垂直方向夹角
         */
        public static function getAngle_O(p1:Object,p2:Object):Number{
            var rt:Number = Math.atan2(p2.y-p1.y,p2.x-p1.x);
            rt = rt*TO_ROT+90
            if(rt>180){
                rt-=360;
            }
            return rt;
        }		
        
        
        /**
         *   取得三角形斜边长度
         * 
         * @param:
         *     x,y:三角形两直角边长度
         * @return:
         *     values:斜边长度
         */
        public static function distance(x:Number,y:Number):Number{
            return Math.sqrt(x*x+y*y);
        }
        
        /**
         * 取得两点间距离
         * @param:
         *   p1,p2:两个点
         *   p1[0],p2[0]:两个点的横坐标
         *   p1[1],p2[1]:两个点的纵坐标
         * @return:
         *               两点间距离
         */
        public static function PtoP_A(p1:Array,p2:Array):Number{
            var tmp1:Number = p1[0]-p2[0]
            var tmp2:Number = p1[1]-p2[1];
            return Math.sqrt(tmp1*tmp1+tmp2*tmp2);
        }
        /**
         *   取得两角之差，返回值被锁定在-180到180之间，不含-180
         *   
         * @param
         *         ogRot,tgRot:两个角度
         * @return
         *         *两角之差
         */
        public static function dtRot(ogRot:Number,tgRot:Number):Number{
            var rt:Number = tgRot-ogRot;
            rt%=360;
            if(rt>180){
                rt-=360;
            }else if(rt<=-180){
                rt+=360;
            }
            return rt;
        }
        /**
         * 取得两角之差的绝对值，返回值在0~180之间，此方法节约使用dtRot后再进行Math.abs步骤
         *   
         *@param
         *   ogRot,tgRot:两个角度
         *@return
         *   两角之差的绝对值
         */
        public static function absDtRot(ogRot:Number,tgRot:Number):Number{
            var rt:Number = tgRot-ogRot;
            rt%=360;
            if(rt>180){
                rt = 360-rt;
            }else if(rt<-180){
                rt+=360;
            }else if(rt<0){
                rt = -rt;
            }
            return rt;
        }
        /**
         *    取得两点间距离
         *    
         * @param:
         *     p1,p2:两个对象，可以是Point或Sprite或有x,y属性的自定义类
         * @return:
         *     两点间距离
         */
        public static function PtoP_O(mc1:Object,mc2:Object):Number{
            var tmp1:Number = mc1.x-mc2.x
            var tmp2:Number = mc1.y-mc2.y
            return Math.sqrt(tmp1*tmp1+tmp2*tmp2);
        }		
    }
}
