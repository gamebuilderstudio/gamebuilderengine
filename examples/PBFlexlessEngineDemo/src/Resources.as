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
    import com.pblabs.engine.resource.*;
    
    public class Resources extends ResourceBundle
    {
        [Embed(source = "../assets/levelDescriptions.xml", mimeType = 'application/octet-stream')]
        public var _levelDesc:Class;
        [Embed(source = "../assets/Levels/common.pbelevel", mimeType = 'application/octet-stream')]
        public var _levelCommon:Class;
        [Embed(source = "../assets/Levels/level1.pbelevel", mimeType = 'application/octet-stream')]
        public var _level1:Class;
        [Embed(source = "../assets/Levels/level2.pbelevel", mimeType = 'application/octet-stream')]
        public var _level2:Class;
        [Embed(source = "../assets/Levels/level3.pbelevel", mimeType = 'application/octet-stream')]
        public var _level3:Class;
        [Embed(source = "../assets/Levels/spriteSheets.pbelevel", mimeType = 'application/octet-stream')]
        public var _levelSprites:Class;
        [Embed(source = "../assets/Levels/templates.pbelevel", mimeType = 'application/octet-stream')]
        public var _levelTemplates:Class;
        
        [Embed(source = "../assets/Images/mannequin.png")]
        public var _mannequin:Class;
        [Embed(source = "../assets/Images/platform.png")]
        public var _platform:Class;
        
        [Embed(source = "../assets/Sounds/testSound.mp3")]
        public var _testSound:Class;
    }
}