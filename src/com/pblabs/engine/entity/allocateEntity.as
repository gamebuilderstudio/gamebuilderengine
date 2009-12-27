/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.entity
{
    /**
     * Allocates an instance of the hidden Entity class. This should be
     * used anytime an IEntity object needs to be created. Encapsulating
     * the Entity class forces code to use IEntity rather than Entity when
     * dealing with entity references. This will ensure that code is future
     * proof as well as allow the Entity class to be pooled in the future.
     * 
     * @return A new IEntity.
     */
    public function allocateEntity():IEntity
    {
        return new Entity();
    }
}