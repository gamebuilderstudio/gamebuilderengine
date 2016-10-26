package com.pblabs.engine.util
{
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.IGraphicsStroke;
	import flash.geom.Point;

	public final class GraphicsUtil
	{
		private static const zeroPoint : Point = new Point();
		
		public function GraphicsUtil()
		{
		}
		
		public static function drawGraphicsPathData(pathData : String, graphicsContext : Graphics, registrationPoint : Point, fill : IGraphicsFill = null, fillColor : uint = 0x0, stroke : IGraphicsStroke = null, winding : String = GraphicsPathWinding.NON_ZERO, clearGraphicsContextFirst : Boolean = true):void
		{
			if(!registrationPoint)
				registrationPoint = zeroPoint;
			
			pathData = pathData.split("M").join(" _M_ ");
			pathData = pathData.split("C").join(" _C_ ");
			pathData = pathData.split("L").join(" _L_ ");
			pathData = pathData.split("Z").join(" _Z_ ");
			var pathDataPoints : Array = pathData.split(" ");
			
			// establish the fill properties
			/*var myFill:GraphicsGradientFill = new GraphicsGradientFill();
			myFill.colors = [0xEEFFEE, 0x0000FF];
			myFill.matrix = new Matrix();
			myFill.matrix.createGradientBox(100, 100, 0);*/
			
			if(!fill)
			{
				fill = new GraphicsSolidFill(fillColor);
			}
			
			// establish the path properties
			var pathCommands : Vector.<int> = new Vector.<int>();
			var pathCoordinates:Vector.<Number> = new Vector.<Number>();
			
			var coordinateCount : int = 0; 
			var lastCommandPushed : String;
			var commandPushed : Boolean = false;
			var commandPointCount : int = 0;
			for(var i : int = 0; i < pathDataPoints.length; i++)
			{
				var pathDataPoint : String = pathDataPoints[i];
				if(pathDataPoint == "" || pathDataPoint == null) continue;
				switch(pathDataPoint)
				{
					case "_M_":
						lastCommandPushed = pathDataPoint;
						commandPushed = true;
						pathCommands.push(GraphicsPathCommand.MOVE_TO);
						commandPointCount = 2; 
						break;
					case "_C_":
						lastCommandPushed = pathDataPoint;
						commandPushed = true;
						pathCommands.push(GraphicsPathCommand.CUBIC_CURVE_TO);
						commandPointCount = 6; 
						break;
					case "_L_":
						lastCommandPushed = pathDataPoint;
						commandPushed = true;
						pathCommands.push(GraphicsPathCommand.LINE_TO);
						commandPointCount = 2; 
						break;
					case "_Z_":
						pathCommands.push(GraphicsPathCommand.NO_OP);
						break;
					default:
						if(commandPushed)
							coordinateCount = 0;
							
						if(coordinateCount == commandPointCount){
							if(!commandPushed && lastCommandPushed == "_M_")
								pathCommands.push(GraphicsPathCommand.LINE_TO);
							else if(!commandPushed)
								pathCommands.push( pathCommands[pathCommands.length-1] );
							coordinateCount = 0;
						}
						var coordinateValue : Number = Number(pathDataPoints[i]);
						if(!isNaN(coordinateValue)){
							if((coordinateCount % 2) == 1)
								coordinateValue = coordinateValue - registrationPoint.x;
							if((coordinateCount % 2) == 0)
								coordinateValue = coordinateValue - registrationPoint.y;
							pathCoordinates.push( coordinateValue );
							coordinateCount++;
						}
						commandPushed = false;
						break;
				}
			}
			
			var graphicsPath:GraphicsPath = new GraphicsPath(pathCommands, pathCoordinates, winding);
			
			// populate the IGraphicsData Vector array
			var customPathDrawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			if(fill)
				customPathDrawing.push(fill);
			if(stroke)
				customPathDrawing.push(stroke);
			customPathDrawing.push( graphicsPath );
			
			// render the drawing
			graphicsContext.drawGraphicsData(customPathDrawing);
		}
		
	}
}