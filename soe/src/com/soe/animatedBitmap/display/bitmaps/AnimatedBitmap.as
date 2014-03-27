/*
 * hexagon framework - Multi-Purpose ActionScript 3 Framework.
 * Copyright (C) 2007 Hexagon Star Softworks
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/ FRAMEWORK_/
 *            \__/  \__/
 *
 * ``The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 */
package com.soe.animatedBitmap.display.bitmaps
{
	import com.soe.animatedBitmap.display.FrameRateTimer;
	import com.soe.animatedBitmap.display.IAnimatedDisplayObject;
	import com.soe.animatedBitmap.env.event.FrameEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * An AnimatedBitmap is a bitmap object that uses a sequence of images
	 * from a provided bitmap to play an animation.
	 * 
	 * @author Sascha Balkau
	 * @version 1.1.0
	 */
	public class AnimatedBitmap extends Bitmap implements IAnimatedDisplayObject
	{
		// Properties /////////////////////////////////////////////////////////////////
		
		/**
		 * The buffer to store the whole bitmap.
		 * @private
		 */
		private var _buffer:BitmapData;
		
		/**
		 * Timer used for frame animation.
		 * @private
		 */
		private var _timer:FrameRateTimer;
		
		/**
		 * The number of frames that the animated bitmap has.
		 * @private
		 */
		private var _frameAmount:int;
		
		/**
		 * Used for the onTimer function to count loops.
		 * @private
		 */
		private var _frameNr:int;
		
		/**
		 * Determines if the animTile is already playing or not.
		 * @private
		 */
		private var _isPlaying:Boolean;
		
		/**
		 * Point object used for copyPixels operation.
		 * @private
		 */
		private var _point:Point;
		
		/**
		 * Rectangle object used for copyPixels operation.
		 * @private
		 */
		private var _rect:Rectangle;
		
		// Constructor ////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new AnimatedBitmap instance.
		 * 
		 * @param bitmap The bitmapData object that contains the image sequence
		 *         for the animated bitmap.
		 * @param w The width of the animated bitmap.
		 * @param h The height of the animated bitmap.
		 * @param timer The frame rate timer used for the animated bitmap.
		 */
		public function AnimatedBitmap(bitmap:BitmapData,
										   w:int,
										   h:int,
										   timer:FrameRateTimer,
										   transparent:Boolean = true,
										   pixelSnapping:String = "auto",
										   smoothing:Boolean = false)
		{
			super(new BitmapData(w, h, transparent, 0x00000000),
				pixelSnapping, smoothing);
			_buffer = bitmap.clone();
			_frameAmount = _buffer.width / width;
			_frameNr = 1;
			_isPlaying = false;
			_timer = timer;
			_point = new Point(0, 0);
			_rect = new Rectangle(0, 0, width, height);
			bitmapData.copyPixels(_buffer, _rect, _point);
		}
		
		// Public Methods /////////////////////////////////////////////////////////////
		
		/**
		 * Sets the frame rate timer object used for the animated
		 * bitmap. This method is useful when it is desired to change
		 * the framerate at a later timer.
		 * 
		 * @param timer The frame rate timer used for the animated bitmap.
		 */
		public function setFrameRateTimer(timer:FrameRateTimer):void
		{
			if (_isPlaying)
			{
				stop();
				_timer = timer;
				play();
			}
			else
			{
				_timer = timer;
			}
		}
		
		/**
		 * Returns the frame rate with that the animated bitmap is playing.
		 * 
		 * @return The fps value of the animated bitmap.
		 */
		public function getFrameRate():int
		{
			return _timer.getFrameRate();
		}
		
		/**
		 * Returns the current frame position of the animated bitmap.
		 * 
		 * @return The current frame position.
		 */
		public function getCurrentFrame():int
		{
			return _frameNr;
		}
		
		/**
		 * Returns the total amount of frames that the animated bitmap has.
		 * 
		 * @return The total frame amount.
		 */
		public function getTotalFrames():int
		{
			return _frameAmount;
		}
		
		/**
		 * Returns whether the animated bitmap is playing or not.
		 * 
		 * @return true if the animated bitmap is playing, else false.
		 */
		public function isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		/**
		 * Starts the playback of the animated bitmap. If the animated
		 * bitmap is already playing while calling this method, it calls
		 * stop() and then play again instantly to allow for framerate
		 * changes during playback.
		 */
		public function play():void
		{
			if (!_isPlaying)
			{
				_isPlaying = true;
				_timer.addEventListener(TimerEvent.TIMER, playForward);
				_timer.start();
			}
			else
			{
				stop();
				play();
			}
		}
		
		/**
		 * Stops the playback of the animated bitmap.
		 */
		public function stop():void
		{
			if (_isPlaying)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, playForward);
				_isPlaying = false;
			}
		}
		
		/**
		 * Jumps to the specified frameNr and plays the animated
		 * bitmap from that position. Note that the frames of an
		 * animated bitmap start at 1.
		 * 
		 * @param frameNr The frame number to which to jump.
		 */
		public function gotoAndPlay(frameNr:int):void
		{
			_frameNr = frameNr - 1;
			play();
		}
		
		/**
		 * Jumps to the specified frameNr and stops the animated
		 * bitmap at that position. Note that the frames of an
		 * animated bitmap start at 1.
		 * 
		 * @param frameNr The frame number to which to jump.
		 */
		public function gotoAndStop(frameNr:int):void
		{
			if (frameNr >= _frameNr)
			{
				_frameNr = frameNr - 1;
				nextFrame();
			}
			else
			{
				_frameNr = frameNr + 1;
				prevFrame();
			}
		}
		
		/**
		 * Moves the animation to the next of the current frame.
		 * If the animated bitmap is playing, the playback is
		 * stopped by this operation.
		 */
		public function nextFrame():void
		{
			if (_isPlaying) stop();
			_frameNr++;
			if (_frameNr > _frameAmount) _frameNr = _frameAmount;
			draw();
		}
		
		/**
		 * Moves the animation to the previous of the current frame.
		 * If the animated bitmap is playing, the playback is
		 * stopped by this operation.
		 */
		public function prevFrame():void
		{
			if (_isPlaying) stop();
			_frameNr--;
			if (_frameNr < 1) _frameNr = 1;
			draw();
		}
		
		// Private Methods ////////////////////////////////////////////////////////////
		
		/**
		 * Plays the animation forward by one frame.
		 * @private
		 */
		private function playForward(event:TimerEvent = null):void
		{
			_frameNr++;
			if (_frameNr > _frameAmount) _frameNr = 1;
			else if (_frameNr < 1) _frameNr = _frameAmount;
			draw();
		}
		
		/**
		 * Plays the animation backwards by one frame.
		 * @private
		 */
		//private function playBackward():void
		//{
		//	_frameNr--;
		//	if (_frameNr < 1) _frameNr = _frameAmount;
		//	draw();
		//}
		
		/**
		 * Draws the next bitmap frame from the buffer to the animated bitmap.
		 * @private
		 */
		private function draw():void
		{
			dispatchEvent(new FrameEvent(FrameEvent.ENTER));
			_rect = new Rectangle((_frameNr - 1) * width, 0, width, height);
			bitmapData.copyPixels(_buffer, _rect, _point);
		}
	}
}
