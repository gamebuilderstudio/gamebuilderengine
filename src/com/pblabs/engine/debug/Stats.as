/**
 * Hi-ReS! Stats
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 *
 *	addChild( new Stats() );
 *
 * version log:
 *
 *	08.12.14		1.4		Mr.doob			+ Code optimisations and version info on MOUSE_OVER
 *	08.07.12		1.3		Mr.doob			+ Some speed and code optimisations
 *	08.02.15		1.2		Mr.doob			+ Class renamed to Stats (previously FPS)
 *	08.01.05		1.2		Mr.doob			+ Click changes the fps of flash (half up increases,
 *											  half down decreases)
 *	08.01.04		1.1		Mr.doob and Theo	+ Log shape for MEM
 *											+ More room for MS
 *											+ Shameless ripoff of Alternativa's FPS look :P
 * 	07.12.13		1.0		Mr.doob			+ First version
 **/

package com.pblabs.engine.debug
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getTimer;
    
    public class Stats extends Sprite
    {
        public function Stats()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private var fps:int, timer:int, ms:int, msPrev:int = 0;

        private var fpsText:TextField, msText:TextField, memText:TextField, verText:TextField, format:TextFormat;

        private var graph:BitmapData;

        private var mem:Number = 0;

        private var rectangle:Rectangle;

        private var ver:Sprite;

        private function onAddedToStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            graphics.beginFill(0x33);
            graphics.drawRect(0, 0, 65, 40);
            graphics.endFill();

            ver = new Sprite();
            ver.graphics.beginFill(0x33);
            ver.graphics.drawRect(0, 0, 65, 30);
            ver.graphics.endFill();
            ver.y = 90;
            ver.visible = false;
            addChild(ver);

            verText = new TextField();
            fpsText = new TextField();
            msText = new TextField();
            memText = new TextField();

            format = new TextFormat("_sans", 9);

            verText.defaultTextFormat = fpsText.defaultTextFormat = msText.defaultTextFormat = memText.defaultTextFormat = format;
            verText.width = fpsText.width = msText.width = memText.width = 65;
            verText.selectable = fpsText.selectable = msText.selectable = memText.selectable = false;

            verText.textColor = 0xFFFFFF;
            verText.text = Capabilities.version.split(" ")[0] + "\n" + Capabilities.version.split(" ")[1];
            ver.addChild(verText);

            fpsText.textColor = 0xFFFF00;
            fpsText.text = "FPS: ";
            addChild(fpsText);

            msText.y = 10;
            msText.textColor = 0x00FF00;
            msText.text = "MS: ";
            addChild(msText);

            memText.y = 20;
            memText.textColor = 0x00FFFF;
            memText.text = "MEM: ";
            addChild(memText);

            graph = new BitmapData(65, 50, false, 0x33);
            var gBitmap:Bitmap = new Bitmap(graph);
            gBitmap.y = 40;
            addChild(gBitmap);

            rectangle = new Rectangle(0, 0, 1, graph.height);

            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(Event.ENTER_FRAME, update);
        }

        private function onClick(event:MouseEvent):void
        {
            (this.mouseY > this.height * .35) ? stage.frameRate-- : stage.frameRate++;
            fpsText.text = "FPS: " + fps + " / " + stage.frameRate;
        }

        private function onMouseOut(event:MouseEvent):void
        {
            ver.visible = false;
        }

        private function onMouseOver(event:MouseEvent):void
        {
            ver.visible = true;
        }

        private function update(e:Event):void
        {
            timer = getTimer();
            fps++;

            if (timer - 250 > msPrev)
            {
                msPrev = timer;
                mem = Number((System.totalMemory * 0.000000954).toFixed(3));

                var fpsGraph:int;
                if (stage)
                    fpsGraph = Math.min(50, 50 / stage.frameRate * fps);
                var memGraph:Number = Math.min(50, Math.sqrt(Math.sqrt(mem * 5000))) - 2;

                graph.scroll(1, 0);

                graph.fillRect(rectangle, 0x33);

                // Do a vertical line if the time was over 100ms
                if (timer - ms > 100)
                    for (var i:int = 0; i < graph.height; i++)
                        graph.setPixel32(0, graph.height - i, 0xFF0000);

                graph.setPixel32(0, graph.height - fpsGraph, 0xFFFF00);
                graph.setPixel32(0, graph.height - ((timer - ms) >> 1), 0x00FF00);
                graph.setPixel32(0, graph.height - memGraph, 0x00FFFF);

                if (stage)
                    fpsText.text = "FPS: " + (fps * 4) + " / " + stage.frameRate;
                memText.text = "MEM: " + mem;

                fps = 0;
            }

            msText.text = "MS: " + (timer - ms);
            ms = timer;
        }
    }
}