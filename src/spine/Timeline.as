/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package spine
{
	public interface Timeline
	{
		/** Sets the value(s) for the specified time. */
		function apply (skeleton : Skeleton, time : Number, alpha : Number):void;
	}
}