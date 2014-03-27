/**
 *@Version:
 *	v0.95 beta
 *@Description:
 *	这是一个测试代码块性能使用的静态工具类。
 *  利用GTester可以测试程序中某一段代码具体执行的效率，以便找到占用资源巨大的代码和进行优化。
 *  GTester只能检测同步代码效率，无法有效检测出异步代码效率和某些非同步渲染的效率。
 * 
 *  请将GTester放于默认包
 *  在实际发布前从项目中移除GTester。
 *  
 *  本类末尾附有调用示例
 *@Interface:
 *   <static> <const> EASE:int = 0;
 *   <static> <const> DEFAULT:int = 1;
 *   <static> <const> DETAIL:int = 2;
 *   <static> <const> ANALYSYS:int = 3;
 * 
 *   <static> init(bindingRoot:Sprite,ignoreFirstTime:Boolean = true,ignoreGC:Boolean = true):void
 *   <static> start():void
 *   <static> end(quickOutput:Boolean = false,filter:int = -1):void
 *   <static> output(level:int = DEFAULT):void
 */



package com.soe.performancetest{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.utils.getTimer;

	public final class GTester{
		private static var root:Sprite
		
		private static var runs:int = 0;
		private static var totalTime:int = 0;
		private static var totalFrames:int = 0;
		private static var lastFrame:int = -1;
		private static var lastTimer:int = -1;
		private static var gameFrame:int = 0;
		private static var maxTime:int= 0;
		private static var minTime:int = 0xffffff;
		private static var minRate:Number = 0xffffff;
		private static var maxRate:Number = 0;
		private static var exceptions:Array = [0,0,0];
		private static var runsPerFrame:int = 1;
		private static var maxRunsPerFrame:int = 1;
		private static var multiRunsInOEF:int =1 ;
		private static var maxFrameCost:int = 0;
		private static var curFrameCost:int = 0;
		private static var frameTime:Number;
		private static var sorts:Array = [0,0,0,0,0,0,0,0,0,0,0,0];
		private static var state:String = "";
		private static var rateBar:Array;
		private static var lastMem:Number = 0;
		private static var gcIgnored:Boolean = false;
		private static var firstTime:Boolean = true;
		private static var ignoreGc:Boolean = false;
			
		public static const EASE:int = 0;
		public static const DEFAULT:int = 1;
		public static const DETAIL:int = 2;
		public static const ANALYSIS:int = 3;
		/**
		 * 在使用GTester类前调用此方法。
		 * GTester在调用init()之后才开始计时。init()前经过的帧不会被算入平均值之中
		 * 
		 * @param bindingRoot
		 *   	一个添加到了显示列表的剪辑，推荐为as项目的主类
		 *  	GTester会向bindingRoot注册ENTER_FRAME事件用于计时
		 *   	GTester会索取bindingRoot.stage.frameRate属性，因此bindingRoot必须是添加到显示列表的对象。
		 * @param ignoreFirstTime
		 * 		因加载等原因，flash的第一次调用代码块的效率可能比后续调用低，此参数设置为true将忽视第一次调用
		 * @param ignoreGC
		 * 		执行程序块时，有可能垃圾回收正在运行，并因此导致测试不准确。
		 * 		此参数设为true时，如果执行代码块前后内存差是负值，将舍弃这次执行数据，也不将这次执行计入总执行次数中。
		 * 		此参数设为false时，会把垃圾回收的功耗也当成程序块该次执行的功耗，这在压力测试和非常消耗内存的程序块测试中有用
		 *  
		 */		
		public static function init(bindingRoot:Sprite,ignoreFirstTime:Boolean = true,ignoreGC:Boolean = true):void{
			root = bindingRoot;
			root.addEventListener(Event.ENTER_FRAME,OEF);
			frameTime = 1000/root.stage.frameRate;
			rateBar = [""];
			for(var i:int = 1;i<=100;i++){				
				rateBar[i] = rateBar[i-1]+"*";				
			}
			firstTime = ignoreFirstTime;
			ignoreGc = ignoreGC
		}
		
		
		/**
		 * 标识被测程序段的开始
		 */			
		public static function start():void{
			if(state == "start"){
				throw new Error("GTester::运行时错误：在没有执行到end()前连续调用了两次以上start()，请检测程序块中是否存在return");
			}
			state = "start";
			runs++;
			lastMem = System.totalMemory;
			lastTimer = getTimer();			
		}
		/**
		 * 标识被测程序段的结束 
		 * @param quickOutput
		 *   	如果quickOutput的值是true，每次执行完程序段之后会立刻trace出这次执行资源开销的简单数据
		 *   	将quickOutput设置为true不是输出的唯一途径，也可以通过output方法输出更详细数据
		 * @param filter
		 * 		以毫秒为单位。如果某次执行的时间低于filter，这次执行的数据会被记录，但不会被输出。quickOutput设置为false时此参数无意义
		 * @return
		 * 		当次执行时间低于filter并成功输出时返回true，否则返回false
		 * 
		 * 
		 */		
		
		
		public static function end(quickOutput:Boolean = false,outputFilter:int = -1):Boolean{
			if(ignoreGc){
				gcIgnored = true;
			}
			var dtTime:int = getTimer()-lastTimer;
			var dtMem:int = System.totalMemory-lastMem;
			if(state == "end"){
				throw new Error("GTester运行时错误：在没有执行到start()前调用了end()或连续调用多次end()");
			}
			state = "end";
			if(firstTime){
				runs--
				firstTime = false;
				return false;
			}
			if(ignoreGc){
				if(dtMem<-1){
					if(quickOutput){
						if(dtTime>outputFilter){
							trace("#--\t垃圾回收在运行，此次数据被舍弃。");
						}
					}
					runs--
					return false;
				}
			}
			totalTime+=dtTime;
			if(dtTime<minTime){
				minTime = dtTime;
			}
			if(dtTime>maxTime){
				maxTime = dtTime;
			}
			
			var rate:Number = dtTime/frameTime;
			if(rate<minRate){
				minRate = rate;
			}
			if(rate>maxRate){
				maxRate = rate;
			}
			var avgTime:int = totalTime/runs;
			if(dtTime>avgTime*1.5+2){					
				if(dtTime>avgTime*2+2){					
					if(dtTime>avgTime*3+3){
						exceptions[2]++;
					}else{
						exceptions[1]++;
					}
				}else{
					exceptions[0]++;
				}				
			}else if(dtTime<(avgTime-2)/1.5){			
				if(dtTime<(avgTime-2)/2){					
					if(dtTime<(avgTime-3)/3){
						exceptions[2]++
					}else{
						exceptions[1]++
					}
				}else{
					exceptions[0]++
				}				
			}
			
			if(gameFrame != lastFrame){
				lastFrame = gameFrame;
				totalFrames++;
				runsPerFrame = 1;
				curFrameCost = dtTime;
				if(curFrameCost>maxFrameCost){
					maxFrameCost = curFrameCost;
				}
			}else{				
				runsPerFrame++;
				if(runsPerFrame>maxRunsPerFrame){
					maxRunsPerFrame = runsPerFrame;
				}
				curFrameCost += dtTime;
				if(curFrameCost>maxFrameCost){
					maxFrameCost = curFrameCost;
				}
			}
			
			if(dtTime <1){
				sorts[0]++;
			}else{
				var tmp:int = int(Math.sqrt(dtTime/frameTime*100));
				if(tmp>10){
					tmp = 10;
				}
				sorts[tmp]++;
			}
			
			if(quickOutput){	
				if(dtTime>outputFilter){
					var str:String = "#"+runs+"\t"+dtTime+"ms(avg: "+(totalTime/runs).toFixed(2)+"ms)\t"+(100*dtTime/frameTime).toFixed(2)+"%(avg: "+(100*((totalTime/runs)/frameTime)).toFixed(2)+"%)"
					str+="\t"
						
					if(dtMem>0){
						str+="+"
					}
					str+=(dtMem/1000).toFixed(1);
					str+="KB\t";
					
					if(dtTime>avgTime*1.5+2){	
						str+="\t↑ ";		
						if(dtTime>avgTime*2+2){
							str+="↑ ";	
							if(dtTime>avgTime*3+3){
								str+="↑ ";	
							}
						}						
					}else if(dtTime<(avgTime-2)/1.5){
						str+="\t↓ ";
						if(dtTime<(avgTime-2)/2){
							str+="↓ ";	
							if(dtTime<(avgTime-3)/3){
								str+="↓ ";	
							}
						}
						
					}
					trace(str);				
				}
			}
		
			return dtTime>outputFilter
			
		}
		
		/**
		 * 标识被测程序段的结束，取消此次数据。
		 * 如果某代码段有多个return，
		 * 只希望监听其中一个return的效率，可以仅在这个return前使用Gtester.end()，在其它return前使用GTester.cancel()
		 * 
		 */		
		
		
		public static function cancel():void{
			if(state == "end"){
				throw new Error("GTester运行时错误：在没有执行到start()前调用了cancel()或连续调用多次end()/cancel()");
			}
			state = "end";
			runs--
			return
		}
		
		/**
		 * 立刻输出迄今为止统计的性能数据
		 * @param level
		 * 		使用EASE,DEFAULT,DETAIL,ANALYSIS表示输出数据的精细程度
		 *   	也可用数字0,1,2,3表示
		 */		
		public static function output(level:int = DEFAULT):void{
			var avgRate:Number = (totalTime/runs)/frameTime;
			if(runs == 0){
				trace("<!>代码块不存在或完全没有被执行");
				return;
			}
			
			switch(level){	
				case EASE:
					if(gcIgnored){
						trace("<!>已设定在垃圾回收时忽略代码块的运行，部分结果被忽略");
					}
					var str:String = "共"+runs+"次\t"+(totalTime/runs).toFixed(2)+"ms,"+(100*avgRate).toFixed(2)+"%"
					trace(str);
					break;
				case DEFAULT:
					trace("========");
					if(gcIgnored){
						trace("<!>已设定在垃圾回收时忽略代码块的运行，部分结果被忽略，可能因此造成ENTER_FRAME代码块每帧执行不足1次");
					}
					trace("有效执行"+runs+"次\t"+totalFrames+"/"+gameFrame+"帧");
					trace("单次平均时间"+(totalTime/runs).toFixed(2)+"ms\tmax="+maxTime+"ms,min="+minTime+"ms");
					trace("单次占用功耗"+(100*avgRate).toFixed(2)+"%\tmax="+(100*maxRate).toFixed(2)+"%,min="+(100*minRate).toFixed(2)+"%");
					break;
				case DETAIL:
					trace("================================");
					trace("执行次数分析");
					trace("有效执行"+runs+"次");
					trace("单次平均时间"+(totalTime/runs).toFixed(2)+"ms\tmax="+maxTime+"ms,min="+minTime+"ms");
					trace("单次占用功耗"+(100*avgRate).toFixed(2)+"%\tmax="+(100*maxRate).toFixed(2)+"%,min="+(100*minRate).toFixed(2)+"%");
					trace("其中功耗出现【"+exceptions+"】次【小变化，中等波动，骤升骤降】");
					trace("---------------------------");	
					trace("执行帧数分析");
					trace("执行该程序块的帧占全部帧数的"+totalFrames+"/"+gameFrame+"="+(100*totalFrames/gameFrame).toFixed(2)+"%");
					trace("<!>注意：下面数据已忽略不执行该程序块的帧");
					if(gcIgnored){
						trace("<!>已设定在垃圾回收时忽略代码块的运行，部分结果被忽略，可能因此造成ENTER_FRAME代码块每帧执行不足1次");
					}
					trace("单帧平均执行次数"+(runs/totalFrames).toFixed(2)+"次\tmax="+maxRunsPerFrame+"次");										
					trace("平均每帧占用功耗"+((100*totalTime/totalFrames)/frameTime).toFixed(2)+"%\tmax="+(100*maxFrameCost/frameTime).toFixed(2)+"%");			
					break;
				case ANALYSIS:
					trace("================================");
					trace("执行次数分析");
					trace("有效执行"+runs+"次");
					trace("单次平均时间"+(totalTime/runs).toFixed(2)+"ms\tmax="+maxTime+"ms,min="+minTime+"ms");
					trace("单次占用功耗"+(100*avgRate).toFixed(2)+"%\tmax="+(100*maxRate).toFixed(2)+"%,min="+(100*minRate).toFixed(2)+"%");
					trace("其中功耗出现【"+exceptions+"】次【小变化，中等波动，骤升骤降】");
					trace("---------------------------");	
					trace("执行帧数分析");
					trace("执行该程序块的帧占全部帧数的"+totalFrames+"/"+gameFrame+"="+(100*totalFrames/gameFrame).toFixed(2)+"%");
					trace("<!>注意：下面数据已忽略不执行该程序块的帧");
					if(gcIgnored){
						trace("<!>已设定在垃圾回收时忽略代码块的运行，部分结果被忽略，可能因此造成ENTER_FRAME代码块每帧执行不足1次");
					}
					trace("单帧平均执行次数"+(runs/totalFrames).toFixed(2)+"次\tmax="+maxRunsPerFrame+"次");										
					trace("平均每帧占用功耗"+((100*totalTime/totalFrames)/frameTime).toFixed(2)+"%\tmax="+(100*maxFrameCost/frameTime).toFixed(2)+"%");			
					trace("---------------------------");
					trace("帧功耗条形图\t\t-0\t  1         2         3         4         5          6         7         8         9         10");
					trace("≈0%\t:"+sorts[0]+"\t"+(sorts[0]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[0]/runs));
					trace(">1%\t:"+sorts[1]+"\t"+(sorts[1]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[1]/runs));
					trace(">4%\t:"+sorts[2]+"\t"+(sorts[2]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[2]/runs));
					trace(">9%\t:"+sorts[3]+"\t"+(sorts[3]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[3]/runs));
					trace(">16%\t:"+sorts[4]+"\t"+(sorts[4]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[4]/runs));
					trace(">25%\t:"+sorts[5]+"\t"+(sorts[5]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[5]/runs));
					trace(">36%\t:"+sorts[6]+"\t"+(sorts[6]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[6]/runs));
					trace(">49%\t:"+sorts[7]+"\t"+(sorts[7]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[7]/runs));
					trace(">64%\t:"+sorts[8]+"\t"+(sorts[8]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[8]/runs));
					trace(">81%\t:"+sorts[9]+"\t"+(sorts[9]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[9]/runs));
					trace(">100%\t:"+sorts[10]+"\t"+(sorts[10]/runs*100).toFixed(2)+"%\t-"+barChart(sorts[10]/runs));
					trace("---------------------------");
				
					break;
			}
		}
		private static function barChart(rate:Number):String{
			if(rate == 0){
				return "";
			}
			var rRate:int = Math.round(rate*100);
			if(rRate == 0){
				return "?";
			}else{
				return rateBar[rRate];
			}
		}
		private static function sortsMoreThan(i:int):int{
			var rt:int = 0;
			i = int(i/10);
			for(i;i<=10;i++){
				rt+=sorts[i];	
			}
			return rt;
		}
		private static function sortsLessThan(i:int):int{
			i = int(i/10);
			i = i-1;
			var rt:int = 0;
			for(i;i>=0;i--){
				rt+=sorts[i];	
			}
			return rt;
		}
		private static function OEF(e:Event):void{			
			gameFrame++;
		}
		/**
		 * 下面方法是输出一个Object全部属性
		 * 功能简单，不过多注释
		 */		
		public static function traceObj(obj:Object,commonTraceFirst:Boolean = false):void{
			if(commonTraceFirst){
				trace(obj);
			}
			for(var i:* in obj){
				trace(i,"=",obj[i]);
			}
		}
		
	}	
}
/**
 *示例： 
 * 	GTester.init(this);
	var lagTimer:Timer = new Timer(200);
	lagTimer.addEventListener(TimerEvent.TIMER,func);
	lagTimer.start();
	function func(e:TimerEvent):void{
		for(var j:int = 0;j<30;j++){
			GTester.start();
			for(var i:int = 0;i<50000;i++){
				var a:Number = 1+1;
				var b:Number = 2-2;
				var c:Number = 3*3;
				var d:Number = 4/4;
			}
			GTester.end(true);
		}			
		GTester.output(GTester.ANALYSIS);
		lagTimer.stop();
		lagTimer.removeEventListener(TimerEvent.TIMER,func);
	}
 * 本机的输出结果如下。机器性能更好的话能得到更高的性能数据。
#1	14ms(avg: 14.00ms)	42.00%(avg: 42.00%)	+8.2KB	
#2	12ms(avg: 13.00ms)	36.00%(avg: 39.00%)	0.0KB	
#3	13ms(avg: 13.00ms)	39.00%(avg: 39.00%)	0.0KB	
#4	13ms(avg: 13.00ms)	39.00%(avg: 39.00%)	0.0KB	
#5	16ms(avg: 13.60ms)	48.00%(avg: 40.80%)	0.0KB	
#6	18ms(avg: 14.33ms)	54.00%(avg: 43.00%)	0.0KB	
#7	17ms(avg: 14.71ms)	51.00%(avg: 44.14%)	0.0KB	
#8	18ms(avg: 15.13ms)	54.00%(avg: 45.38%)	0.0KB	
#9	16ms(avg: 15.22ms)	48.00%(avg: 45.67%)	0.0KB	
#10	17ms(avg: 15.40ms)	51.00%(avg: 46.20%)	0.0KB	
#11	16ms(avg: 15.45ms)	48.00%(avg: 46.36%)	0.0KB	
#12	12ms(avg: 15.17ms)	36.00%(avg: 45.50%)	0.0KB	
#13	13ms(avg: 15.00ms)	39.00%(avg: 45.00%)	0.0KB	
#14	12ms(avg: 14.79ms)	36.00%(avg: 44.36%)	0.0KB	
#15	12ms(avg: 14.60ms)	36.00%(avg: 43.80%)	0.0KB	
#16	13ms(avg: 14.50ms)	39.00%(avg: 43.50%)	0.0KB	
#17	12ms(avg: 14.35ms)	36.00%(avg: 43.06%)	0.0KB	
#18	13ms(avg: 14.28ms)	39.00%(avg: 42.83%)	0.0KB	
#19	13ms(avg: 14.21ms)	39.00%(avg: 42.63%)	0.0KB	
#20	13ms(avg: 14.15ms)	39.00%(avg: 42.45%)	0.0KB	
#21	13ms(avg: 14.10ms)	39.00%(avg: 42.29%)	0.0KB	
#22	12ms(avg: 14.00ms)	36.00%(avg: 42.00%)	0.0KB	
#23	13ms(avg: 13.96ms)	39.00%(avg: 41.87%)	0.0KB	
#24	13ms(avg: 13.92ms)	39.00%(avg: 41.75%)	0.0KB	
#25	12ms(avg: 13.84ms)	36.00%(avg: 41.52%)	0.0KB	
#26	13ms(avg: 13.81ms)	39.00%(avg: 41.42%)	0.0KB	
#27	13ms(avg: 13.78ms)	39.00%(avg: 41.33%)	0.0KB	
#28	11ms(avg: 13.68ms)	33.00%(avg: 41.04%)	0.0KB	
#29	13ms(avg: 13.66ms)	39.00%(avg: 40.97%)	0.0KB	
#30	13ms(avg: 13.63ms)	39.00%(avg: 40.90%)	0.0KB	
================================
执行次数分析
共执行30次
单次平均时间13.63ms	max=18ms,min=11ms
单次占用功耗40.90%	max=54.00%,min=33.00%
其中功耗出现【0,0,0】次【小变化，中等波动，骤升骤降】
---------------------------
执行帧数分析
执行该程序块的帧占全部帧数的1/5=20.00%
<!>注意：下面数据已忽略不执行该程序块的帧
单帧平均执行次数30.00次	max=30次
平均每帧占用功耗1227.00%	max=1227.00%
---------------------------
帧功耗条形图		-0	  1         2         3         4         5          6         7         8         9         10
≈0%	:0	0.00%	-
>1%	:0	0.00%	-
>4%	:0	0.00%	-
>9%	:0	0.00%	-
>16%	:0	0.00%	-
>25%	:1	3.33%	-***
>36%	:25	83.33%	-***********************************************************************************
>49%	:4	13.33%	-*************
>64%	:0	0.00%	-
>81%	:0	0.00%	-
>100%	:0	0.00%	-
---------------------------

 
 * 
 * 关于上述结果得到“平均每帧占用功耗1227.00%，可判断这个程序段导致某帧至少被拖长12帧的时间。

*/
