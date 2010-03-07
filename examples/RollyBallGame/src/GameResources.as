package
{
	import com.pblabs.engine.resource.ResourceBundle;
 	
    /**
     * All the game's resources are embedded here so they are immediately available,
     * instead of streaming in later.
     */
	public class GameResources extends ResourceBundle
	{
        [Embed(source='../assets/Levels/level.pbelevel', mimeType='application/octet-stream')]
        public var res0:Class;

        [Embed(source='../assets/Images/coin.png')]
        public var res1:Class;
        [Embed(source='../assets/Images/welcome.png')]
        public var res2:Class;

        [Embed(source='../assets/Images/intro.png')]
        public var res2a:Class;
        
        [Embed(source='../assets/Images/level1_height.png')]
        public var res3:Class;
        [Embed(source='../assets/Images/level1_normal.png')]
        public var res4:Class;
        [Embed(source='../assets/Images/level1_diffuse.png')]
        public var res5:Class;
        
        [Embed(source='../assets/Images/level2_height.png')]
        public var res6:Class;
        [Embed(source='../assets/Images/level2_normal.png')]
        public var res7:Class;
        [Embed(source='../assets/Images/level2_diffuse.png')]
        public var res8:Class;
        
        [Embed(source='../assets/Sounds/pickup.mp3')]
        public var res9:Class;
        [Embed(source='../assets/Sounds/scorechunk.mp3')]
        public var res10:Class;
	}
}