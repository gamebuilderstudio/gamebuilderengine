package com.pblabs.rendering2D
{
    import flash.display.BitmapData;
    import flash.geom.Matrix;

    public interface ICopyPixelsRenderer
    {
        function drawPixels(objectToScreen:Matrix, renderTarget:BitmapData):void;
    }
}