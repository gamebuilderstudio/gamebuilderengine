package PBLabs.Components.StateMachine
{
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Debug.*;
   
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   /**
    * Implementation of IMachine; probably any custom FSM would be based on this.
    *
    * @see IMachine for API docs.
    */
   public class Machine implements IMachine
   {
      /** 
       * Set of states, indexed by name.
       */
      [TypeHint(type="PBLabs.Components.StateMachine.BasicState")]
      public var States:Dictionary = new Dictionary();
      
      /**
       * What state will we start out in?
       */
      public var DefaultState:String = null;
      
      private var _CurrentState:IState = null;
      private var _PreviousState:IState = null;
      private var _SetNewState:Boolean = false;
      private var _EnteredStateTime:Number = 0;

      private var _PropertyBag:IPropertyBag = null;

      /**
       * Virtual time at which we entered the state.
       */
      public function get EnteredStateTime():Number
      {
         return _EnteredStateTime;
      }
      
      public function get PropertyBag():IPropertyBag
      {
         return _PropertyBag;
      }
      
      public function set PropertyBag(v:IPropertyBag):void
      {
         _PropertyBag = v;
      }
      
      public function Tick():void
      {
         _SetNewState = false;
         
         // DefaultState - we get it if no state is set.
         if(!_CurrentState)
            SetCurrentState(DefaultState);
         
         if(_CurrentState)
            _CurrentState.Tick(this);
         
         // If didn't set a new state, it counts as transitioning to the
         // current state. This updates prev/current state so we can tell
         // if we just transitioned into our current state.
         if(_SetNewState == false && _CurrentState)
         {
             _PreviousState = _CurrentState;
         }
         
         //if(_PreviousState != _CurrentState)
         //   Logger.Print(this, "Transition: " + GetStateName(_PreviousState) + " -> " + GetStateName(_CurrentState));              
      }
      
      public function GetCurrentState():IState
      {
         // DefaultState - we get it if no state is set.
         if(!_CurrentState)
            SetCurrentState(DefaultState);

         return _CurrentState;
      }
      
      public function get CurrentState():IState
      {
         return GetCurrentState();
      }
      
      public function get CurrentStateName():String
      {
          return GetStateName(GetCurrentState());
      }
      
      public function set CurrentStateName(v:String):void
      {
         SetCurrentState(v);
      }
      
      public function GetPreviousState():IState
      {
         return _PreviousState;
      }
      
      public function AddState(name:String, state:IState):void
      {
          States[name] = state;
      }
      
      public function GetState(name:String):IState
      {
         return States[name] as IState;
      }

      public function GetStateName(state:IState):String
      {
         for(var name:String in States)
            if(States[name] == state)
                return name;
         
         return null;
      }

      public function SetCurrentState(name:String):Boolean
      {
         var newState:IState = GetState(name);
         if(!newState)
            return false;
                  
         var oldState:IState = _CurrentState;
         _SetNewState = true;
         
         _PreviousState = _CurrentState;
         _CurrentState = newState;
         
         // Do the right callbacks if we are changing state.
         //if(newState != oldState)
         if(true)
         {
            // Old state gets notified it is changing out.
            if(oldState)
              oldState.Exit(this);
             
            // New state finds out it is coming in.    
            newState.Enter(this);
            
            // Note the time at which we entered this state.             
            _EnteredStateTime = ProcessManager.Instance.VirtualTime;
             
            // Fire a transition event, if we have a dispatcher.
            if(_PropertyBag)
            {
               var te:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION);
               te.oldState = oldState;
               te.oldStateName = GetStateName(oldState);
               te.newState = newState;
               te.newStateName = GetStateName(newState);
                     
               _PropertyBag.EventDispatcher.dispatchEvent(te);
            }
         }
                  
         return true;
      }
      
   }
}
