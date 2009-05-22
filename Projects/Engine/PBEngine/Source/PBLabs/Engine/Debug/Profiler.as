package PBLabs.Engine.Debug
{
   import PBLabs.Engine.Core.*;
   import flash.utils.getTimer;
   import flash.utils.Dictionary;
   
   /**
    * Simple, static hierarchical block profiler.
    *
    * Currently it is hardwired to start measuring when you press P, and dump
    * results to the log when you let go of P. Eventually something more
    * intelligent will be appropriate.
    *
    * Use it by calling Profiler.Enter("CodeSectionName"); before the code you
    * wish to measure, and Profiler.Exit("CodeSectionName"); afterwards. Note
    * that Enter/Exit calls must be matched - and if there are any branches, like
    * an early return; statement, you will need to add a call to Profiler.Exit()
    * before the return.
    *
    * Min/Max/Average times are reported in milliseconds, while self and non-sub
    * times (times including children and excluding children respectively) are
    * reported in percentages of total observed time.
    */
   public class Profiler
   {
      static public var Enabled:Boolean = false;
      static public var NameFieldWidth:int = 80;

      /**
       * Indicate we are entering a named execution block.
       */
      static public function Enter(blockName:String):void
      {
         if(_CurrentNode == null)
         {
            _RootNode = new ProfileInfo("Root")
            _CurrentNode = _RootNode;
         }
         
         // If we're at the root then we can update our internal enabled state.
         if(_StackDepth == 0)
         {
            // Hack - if they press, then release insert, start/stop and dump
            // the profiler.
            if(InputManager.Instance.IsKeyDown(InputKey.P.KeyCode))
            {
               if(Enabled == false)
               {
                  _WantWipe = true;
                  Enabled = true;
               }
            }
            else
            {
               if(Enabled == true)
               {
                  _WantReport = true;
                  Enabled = false;
               }
            }
            
            _ReallyEnabled = Enabled;
            
            if(_WantWipe)
               DoWipe();
            
            if(_WantReport)
               DoReport();
         }
         
         // Update stack depth and early out.
         _StackDepth++;
         if(_ReallyEnabled == false)
            return;
            
         // Look for child; create if absent.
         var newNode:ProfileInfo = _CurrentNode.children[blockName];
         if(!newNode)
         {
            newNode = new ProfileInfo(blockName, _CurrentNode);
            _CurrentNode.children[blockName] = newNode;
         }
         
         // Push onto stack.
         _CurrentNode = newNode;
         
         // Start timing the child node. Too bad you can't QPC from Flash. ;)
         _CurrentNode.startTime = flash.utils.getTimer();
      }
      
      /**
       * Indicate we are exiting a named exection block.
       */
      static public function Exit(blockName:String):void
      {
         // Update stack depth and early out.
         _StackDepth--;
         if(_ReallyEnabled == false)
            return;
         
         if(blockName != _CurrentNode.name)
            throw new Error("Mismatched Profiler.Enter/Profiler.Exit calls, was expecting '" + _CurrentNode.name + "' but got '" + blockName + "'");
         
         // Update stats for this node.
         var elapsedTime:int = flash.utils.getTimer() - _CurrentNode.startTime;
         _CurrentNode.activations++;
         _CurrentNode.totalTime += elapsedTime;
         if(elapsedTime > _CurrentNode.maxTime) _CurrentNode.maxTime = elapsedTime;
         if(elapsedTime < _CurrentNode.minTime) _CurrentNode.minTime = elapsedTime;

         // Pop the stack.
         _CurrentNode = _CurrentNode.parent;
      }
      
      /**
       * Dumps statistics to the log next time we reach bottom of stack.
       */
      static public function Report():void
      {
         if(_StackDepth)
         {
            _WantReport = true;
            return;
         }
         
         DoReport();
      }
      
      /**
       * Reset all statistics to zero.
       */
      static public function Wipe():void
      {
         if(_StackDepth)
         {
            _WantWipe = true;
            return;
         }
         
         DoWipe();
      }
      
      /**
       * Call this outside of all Enter/Exit calls to make sure that things
       * have not gotten unbalanced. If all enter'ed blocks haven't been
       * exit'ed when this function has been called, it will give an error.
       *
       * Useful for ensuring that profiler statements aren't mismatched.
       */
      static public function EnsureAtRoot():void
      {
         if(_StackDepth)
            throw new Error("Not at root!");
      }
      
      static private function DoReport():void
      {
         _WantReport = false;
         
         var header:String = sprintf( "%-" + NameFieldWidth + "s%-8s%-8s%-8s%-8s%-8s%-8s", "Name", "Calls", "Self %", "NonSelf%", "AvgMs", "MinMs", "MaxMs" );
         Logger.Print(Profiler, header);
         _Report_R(_RootNode, 0);
      }
      
      static private function _Report_R(pi:ProfileInfo, indent:int):void
      {
         // Figure our display values.
         var selfTime:Number = pi.totalTime;

         var hasKids:Boolean = false;
         var totalTime:Number = 0;
         for each(var childPi:ProfileInfo in pi.children)
         {
            hasKids = true;
            selfTime -= childPi.totalTime;
            totalTime += childPi.totalTime;
         }
         
         // Fake it if we're root.
         if(pi.name == "Root")
            pi.totalTime = totalTime;
         
         var displayTime:Number = -1;
         if(pi.parent)
            displayTime = Number(pi.totalTime) / Number(_RootNode.totalTime) * 100;
            
         var displayNonSubTime:Number = -1;
         if(pi.parent)
            displayNonSubTime = selfTime / Number(_RootNode.totalTime) * 100;
         
         // Print us.
         var entry:String = sprintf( "%-" + (indent * 3) + "s%-" + (NameFieldWidth - indent * 3) + "s%-8s%-8s%-8s%-8s%-8s%-8s", "",
            (hasKids ? "+" : "-") + pi.name, pi.activations, displayTime.toFixed(2), displayNonSubTime.toFixed(2), (Number(pi.totalTime) / Number(pi.activations)).toFixed(1), pi.minTime, pi.maxTime);
         Logger.Print(Profiler, entry);
         
         // Sort and draw our kids.
         var tmpArray:Array = new Array();
         for each(childPi in pi.children)
            tmpArray.push(childPi);
         tmpArray.sortOn("totalTime", Array.NUMERIC | Array.DESCENDING);
         for each(childPi in tmpArray)
            _Report_R(childPi, indent + 1);
      }

      static private function DoWipe(pi:ProfileInfo = null):void
      {
         _WantWipe = false;
         
         if(pi == null)
         {
            DoWipe(_RootNode);
            return;
         }
         
         pi.Wipe();
         for each(var childPi:ProfileInfo in pi.children)
            DoWipe(childPi);
      }
      
      /**
       * Because we have to keep the stack balanced, we can only enabled/disable
       * when we return to the root node. So we keep an internal flag.
       */
      static private var _ReallyEnabled:Boolean = true;
      static private var _WantReport:Boolean = false, _WantWipe:Boolean = false;
      static private var _StackDepth:int = 0;
      
      static private var _RootNode:ProfileInfo;
      static private var _CurrentNode:ProfileInfo;
   }
}

class ProfileInfo
{
   public var name:String;
   public var children:Object = {};
   public var parent:ProfileInfo;
   
   public var startTime:int, totalTime:int, activations:int;
   public var maxTime:int = int.MIN_VALUE;
   public var minTime:int = int.MAX_VALUE;
   
   public function ProfileInfo(n:String, p:ProfileInfo = null)
   {
      name = n;
      parent = p;
   }
   
   public function Wipe():void
   {
      startTime = totalTime = activations = 0;
      maxTime = int.MIN_VALUE;
      minTime = int.MAX_VALUE;
   }
}