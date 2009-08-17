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
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.IEntityComponent;

    /**
     * @private
     */
    public class TestComponentA extends EntityComponent
    {
        public var testValue:int = 0;
        public var namedReference:IEntity = null;
        public var instantiatedReference:IEntity = null;
        public var componentReference:TestComponentB = null;
        public var namedComponentReference:IEntityComponent = null;
    }
}