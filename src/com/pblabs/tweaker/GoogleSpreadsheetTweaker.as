/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.tweaker
{
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.entity.PropertyReference;
   
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Dictionary;

   /**
    * Put values from a Google Spreadsheet into your game for tweaking purposes.
    * <p>
    * A big part of any game are the values that define how it behaves. Small
    * changes in timing, forces, or scores can have big impacts on how fun a
    * game is. The process of making a game fun involves endless tweaking and
    * testing. Often the people doing that work are not programmers, so editing
    * source code and recompiling can be a big barrier for them.</p>
    * <p>
    * The GoogleSpreadsheetTweaker lets the game programmer map values on named
    * objects and in templates to cells on a Google Spreadsheet.</p>
    * 
    * @example Here's an example of how to use this component: 
    * 
    * <listing version="3.0">
    * &lt;entity name="Tweaker"&gt;
    *  &lt;component name="Tweaker" type="com.pblabs.tweaker.GoogleSpreadsheetTweaker"&gt;
    *    &lt;SpreadsheetUrl&gt;http://spreadsheets.google.com/feeds/cells/abc73bd7db73b73cb73b7c/od7/public/basic&lt;/SpreadsheetUrl&gt;
    *    &lt;ProxyUrl&gt;http://mydomain.com/game/GoogleSpreadsheetProxy.php&lt;/ProxyUrl&gt;
    *    &lt;Config&gt;
    *        &lt;!-- Wave 1 --&gt;
    *        &lt;_&gt;&lt;Cell&gt;B3&lt;/Cell&gt;&lt;Property&gt;!Waves1.WaveManager.Waves.0.ObserverDescription&lt;/Property&gt;&lt;/_&gt;
    *    &lt;/Config&gt;
    *  &lt;/component&gt;
    * &lt;/entity&gt;
    * </listing>
    */
   public class GoogleSpreadsheetTweaker extends EntityComponent
   {
      /**
       * The feed for a publicly accessible Google Spreadsheet.
       *
       * <p>The naming convention for these feeds is described at 
       * http://code.google.com/apis/spreadsheets/docs/3.0/reference.html#ConstructingURIs</p>
       *
       * <p>Example of a working URL (key changed to protect the innocent):
       * http://spreadsheets.google.com/feeds/cells/pZ6iqteeevF7uf4J123yqSw/od6/public/basic
       * This gets the first sheet of the specified document.</p>
       */
      public var spreadsheetUrl:String = "";
      
      /**
       * The URL for the proxy script, described in the web subfolder of this
       * project.
       */
      public var proxyUrl:String = "http://yoururl.com/yourproxyscript.php";
      
      /**
       * List of TweakerMapEntry instances mapping cells to properties.
       */
      [TypeHint(type="com.pblabs.tweaker.TweakerMapEntry")]
      public var config:Array = new Array();

      /**
       * Groups let you assign patterns of cells and properties to multiple items.
       */
      [TypeHint(type="com.pblabs.tweaker.TweakerMapGroup")]
      public var groups:Array = new Array();
      
      override protected function onAdd():void
      {
         // Process the groups.
         for each(var tmg:TweakerMapGroup in groups)
         {
            for each(var tmgoffset:TweakerMapEntry in tmg.offsets)
            {
               // Figure base cell position.
               var baseX:int = tmgoffset.cell.charCodeAt(0) - "A".charCodeAt(0);
               var baseY:int = parseInt(tmgoffset.cell.substr(1));
               
               // Generate the entries for this offset.
               for each(var tmgp:TweakerMapEntry in tmg.entries)
               {
                  // Concatenate the property reference.
                  var groupProp:String = tmgoffset.property.property + tmgp.property.property;
                  
                  // Add the cell references.
                  var cellX:String = String.fromCharCode(baseX + (tmgp.cell.charCodeAt(0) - "A".charCodeAt(0)) + "A".charCodeAt(0));
                  var cellY:int = parseInt(tmgp.cell.substr(1)) + baseY;
                  var cell:String = cellX + cellY.toString();
                  
                  // Note the new entry.
                  var newEntry:TweakerMapEntry = new TweakerMapEntry();
                  newEntry.cell = cell;
                  newEntry.property = new PropertyReference(groupProp);
                  
                  //trace(" made property " + newEntry);
                  
                  config.push(newEntry);
               }               
            }
         }
         
         // Request the URL via our proxy.
         var ur:URLRequest = new URLRequest(proxyUrl);
         ur.method = URLRequestMethod.POST;
         ur.data = new URLVariables();
         ur.data["_url"] = spreadsheetUrl;

         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE, onLoadComplete);
         loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFail);
         loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, 
               function(event:HTTPStatusEvent):void { Logger.print(this, "Got status back: " + event.toString()); }
               );
         loader.load(ur);
         
         Logger.print(this, "Requesting spreadsheet " + spreadsheetUrl);
      }

      private function onLoadComplete(e:Event):void
      {
         // Convert bytes to string to XML.
         var tweakXML:XML = new XML((e.target as URLLoader).data);

        // Extract the entries.
        var xmlns:Namespace = new Namespace("xmlns", "http://www.w3.org/2005/Atom");
        tweakXML.addNamespace(xmlns);

        // Parse into a dictionary.
        var cellDictionary:Dictionary = new Dictionary();
        var res:XMLList = tweakXML.xmlns::entry;
        for each(var entryXML:XML in res)
        {
           //Logger.print(this, "Cell " + entryXML.xmlns::title.toString() + " = " + entryXML.xmlns::content.toString());
           cellDictionary[entryXML.xmlns::title.toString()] = entryXML.xmlns::content.toString();
        }

        // Now we can map based on config data.
        for each(var configItem:TweakerMapEntry in config)
        { 
           var newValue:* = cellDictionary[configItem.cell];
           if(newValue == "NA" || newValue == "")
              continue;

           Logger.warn(this, "onLoadComplete", "Setting property " + configItem.property.property + " to " + newValue +  " based on " + configItem.cell);
           owner.setProperty(configItem.property, newValue);
           if(!owner.doesPropertyExist(configItem.property))
           {
              Logger.warn(this, "onLoadComplete", "   - failed to set " + configItem.property.property);
              owner.setProperty(configItem.property, newValue);
           }
        }

        // Give some status.
        Logger.print(this, "Updated " + config.length + " properties from " + spreadsheetUrl);
      }

      private function onLoadFail(e:Event):void
      {
         Logger.print(this, "Failed to load google spreadsheet tweak url: " + e.toString());
      }
   }
}
