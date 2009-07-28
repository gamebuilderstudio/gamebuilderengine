package
{
	import com.pblabs.engine.resource.ResourceBundle;
 	
	public class GameResources extends ResourceBundle
	{
        [Embed(source='../assets/Levels/level.pbelevel', mimeType='application/octet-stream')]
        public var res0:Class;

        [Embed(source='../assets/Images/coin.png', mimeType='application/octet-stream')]
        public var res1:Class;
        [Embed(source='../assets/Images/welcome.png', mimeType='application/octet-stream')]
        public var res2:Class;
        
        [Embed(source='../assets/Images/level1_height.png', mimeType='application/octet-stream')]
        public var res3:Class;
        [Embed(source='../assets/Images/level1_normal.png', mimeType='application/octet-stream')]
        public var res4:Class;
        [Embed(source='../assets/Images/level1_diffuse.png', mimeType='application/octet-stream')]
        public var res5:Class;
        
        [Embed(source='../assets/Images/level2_height.png', mimeType='application/octet-stream')]
        public var res6:Class;
        [Embed(source='../assets/Images/level2_normal.png', mimeType='application/octet-stream')]
        public var res7:Class;
        [Embed(source='../assets/Images/level2_diffuse.png', mimeType='application/octet-stream')]
        public var res8:Class;
        
        [Embed(source='../assets/Sounds/pickup.mp3')]
        public var res9:Class;
        [Embed(source='../assets/Sounds/scorechunk.mp3')]
        public var res10:Class;
	}
}