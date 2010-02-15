/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.entity.*;
    import com.pblabs.rendering2D.*;
    import com.pblabs.rendering2D.ui.*;
    
    import flash.display.Sprite;
    import flash.geom.Point;
    
    [SWF(width="800", height="600", frameRate="60")]
    public class Lesson2Base extends Sprite
    {
        public function Lesson2Base()
        {
            PBE.startup(this);                                                  // Start up PBE
        }
    }
}
