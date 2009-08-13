package
{
	import com.pblabs.engine.resource.ResourceBundle;
 	
	public class TestResources extends ResourceBundle
	{
        [Embed(source="../assets/testLevel.xml", mimeType='application/octet-stream')]
        public var _levelFile:Class;
	}
}