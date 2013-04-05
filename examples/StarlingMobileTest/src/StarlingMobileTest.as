package
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.JSONResource;
	import com.pblabs.rendering2D.AnimationController;
	import com.pblabs.rendering2D.AnimationControllerInfo;
	import com.pblabs.rendering2D.spritesheet.TexturePackerSheetDivider;
	import com.pblabs.starling2D.BitmapRendererG2D;
	import com.pblabs.starling2D.DisplayObjectSceneG2D;
	import com.pblabs.starling2D.SceneViewG2D;
	import com.pblabs.starling2D.ScrollingBitmapRendererG2D;
	import com.pblabs.starling2D.SpriteSheetRendererG2D;
	import com.pblabs.starling2D.spritesheet.SpriteSheetComponentG2D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import starling.core.Starling;
	
	//[SWF(height="1024", width="768")]
	[SWF(height="700", width="800", frameRate="60")]
	public class StarlingMobileTest extends Sprite
	{
		[Embed(source="/assets/background.png")]
		public static const BG : Class;
		
		private var sceneG2D : DisplayObjectSceneG2D;
		private var renderList : Array = new Array();

		public function StarlingMobileTest()
		{
			super();
			initApp(null);
		}
		
		private function initApp(event : Event):void
		{
			PBE.IS_SHIPPING_BUILD = true;
			PBE.startup(this);
			
			var sceneEntity : IEntity = PBE.allocateEntity();
			var sceneViewG2D : SceneViewG2D = new SceneViewG2D();
			//Starling.current.nativeStage.frameRate = 60;
			sceneViewG2D.starlingInstance.showStats = true;
			sceneG2D = new DisplayObjectSceneG2D();
			sceneG2D.sceneView = sceneViewG2D;
			//sceneG2D.sceneAlignment = SceneAlignment.TOP_LEFT;
			sceneEntity.addComponent(sceneG2D, "Scene");
			
			//var bitmap : BitmapRendererG2D = new BitmapRendererG2D();
			var bitmap : ScrollingBitmapRendererG2D = new ScrollingBitmapRendererG2D();
			//bitmap.bitmapData = new BG().bitmapData as BitmapData;
			bitmap.size = new Point(512, 812);
			bitmap.scrollPosition = new Point(0, 250);
			bitmap.scrollSpeed = new Point(0, 50);
			bitmap.fileName = "assets/skypng.png";
			//bitmap.bitmapData = new BG().bitmapData as BitmapData;
			bitmap.scene = sceneG2D;
			bitmap.layerIndex = 0;
			bitmap.position = new Point(0, 0);
			sceneEntity.addComponent(bitmap, "BackgroundRenderer");
			
			sceneEntity.initialize("SceneEntity");
			
			var imageResource : ImageResource = PBE.resourceManager.load("assets/PigsSheet.png", ImageResource) as ImageResource;
			var imageMapResource : JSONResource = PBE.resourceManager.load("assets/PigsSheet.json", JSONResource) as JSONResource;
			
			for(var i : int = 0; i < 350; i++){
				createPigEntity();
			}
			
			//addChild(new Stats());
			PBE.mainStage.addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		private function createPigEntity():void
		{
			var pigEntity : IEntity = PBE.allocateEntity();
			
			var spriteSheetRenderer : SpriteSheetRendererG2D = new SpriteSheetRendererG2D();
			spriteSheetRenderer.layerIndex = 1;
			var sheet : SpriteSheetComponentG2D = new SpriteSheetComponentG2D();
			sheet.image = PBE.resourceManager.getResource("assets/PigsSheet.png", ImageResource) as ImageResource;
			var dataDivider : TexturePackerSheetDivider = new TexturePackerSheetDivider();
			dataDivider.resource = PBE.resourceManager.getResource("assets/PigsSheet.json", JSONResource) as JSONResource;
			sheet.divider = dataDivider;
			spriteSheetRenderer.spriteSheet = sheet;
			spriteSheetRenderer.scene = sceneG2D;
			
			var newPos : Point = new Point((((Math.random() * ((x+1)/9)) * PBE.mainStage.stageWidth) /45), (((Math.random() * ((x+1)+10)) * PBE.mainStage.stageHeight) / 25));
			spriteSheetRenderer.position = newPos;
			renderList.push(spriteSheetRenderer);
			pigEntity.addComponent(spriteSheetRenderer, "SpriteSheetRenderer");
			pigEntity.addComponent(sheet, "SpriteSheetImage");
			
			/*var animator : AnimationController = new AnimationController();
			var idleAnim : AnimationControllerInfo = new AnimationControllerInfo();
			idleAnim.customFrameList = [27,28,29];
			idleAnim.customFrames = true;
			idleAnim.frameRate = 200;
			idleAnim.spriteSheet = sheet;
			animator.animations['Idle'] = idleAnim;
			animator.defaultAnimation = 'Idle';
			animator.currentFrameReference = new PropertyReference("@SpriteSheetRenderer.spriteIndex");
			animator.spriteSheetReference = new PropertyReference("@SpriteSheetRenderer.spriteSheet");
			animator.setAnimation(idleAnim);
			pigEntity.addComponent(animator, "SpriteSheetController");*/
			
			pigEntity.initialize(null, "PigEntity");
		}
		
		private var interval : int = 400;
		private function onRender(event : Event):void
		{
			//if(interval > 8){
			var len : int = renderList.length;
			for (var x:int = 0; x < len; x++)
			{
				renderList[x].position = new Point( (((Math.random() * ((PBUtil.clamp(x+198,0,PBE.mainStage.stageWidth))/9)) * stage.stageWidth) /45), (((Math.random() * ((PBUtil.clamp(x+1,0,PBE.mainStage.stageHeight))+10)) * stage.stageHeight) / 25) );
			}
			interval = 0;
			//}
			interval++;
		}
	}
}