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
package com.soe.animatedBitmap.display
{
	import flash.utils.Timer;
	
	/**
	 * A Timer for frame rate-related classes.
	 * @author Sascha Balkau
	 * @version 1.0.0
	 */
	public class FrameRateTimer extends Timer
	{
		// Properties /////////////////////////////////////////////////////////////////
		
		/**
		 * Stores the frame rate value.
		 * @private
		 */
		private var _fps:int;
		
		// Constructor ////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new FrameRateTimer instance.
		 * 
		 * @param fps The frame rate value for the FrameRateTimer. If this
		 *         value is smaller than 0, 24 will be used as a default.
		 */
		public function FrameRateTimer(fps:int = -1)
		{
			_fps = (fps > -1) ? fps : 24;
			super(Math.round(1000 / _fps), 0);
		}
		
		// Public Methods /////////////////////////////////////////////////////////////
		
		/**
		 * Returns the frame rate of the FrameRateTimer.
		 * 
		 * @return The frame rate of the FrameRateTimer.
		 */
		public function getFrameRate():int
		{
			return _fps;
		}
	}
}
