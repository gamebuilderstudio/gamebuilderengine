package PBLabs.Animation
{
   import flash.events.Event;
   
   public class AnimationEvent extends Event
   {
   	public static const ANIMATION_STARTED_EVENT:String = "ANIMATION_STARTED_EVENT";
   	public static const ANIMATION_RESUMED_EVENT:String = "ANIMATION_RESUMED_EVENT";
   	public static const ANIMATION_REPEATED_EVENT:String = "ANIMATION_REPEATED_EVENT";
   	public static const ANIMATION_STOPPED_EVENT:String = "ANIMATION_STOPPED_EVENT";
   	public static const ANIMATION_FINISHED_EVENT:String = "ANIMATION_FINISHED_EVENT";
	   
	   public var Animation:Animator = null;
	   
   	public function AnimationEvent(type:String, animation:Animator, bubbles:Boolean=true, cancelable:Boolean=false)
   	{
   	   Animation = animation;
   		super(type, bubbles, cancelable);
   	}
   }
}

