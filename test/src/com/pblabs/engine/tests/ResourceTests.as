/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.tests
{
    import com.pblabs.engine.debug.Logger;
    
    import flexunit.framework.Assert;

    /**
     * @private
     */
    public class ResourceTests
    {

        [Test]
        public function testResourceLoad():void
        {
            Logger.printHeader(null, "Running Resource Load Test");
            //Assert.fail("not implemented");
            Logger.printFooter(null, "");
        }

        [Test]
        public function testReferenceCounting():void
        {
            Logger.printHeader(null, "Running Resource Reference Count Test");
            //Assert.fail("not implemented");
            Logger.printFooter(null, "");
        }
    }
}