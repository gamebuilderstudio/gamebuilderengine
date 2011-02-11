/*
Copyright (c) 2008 Christopher Martin-Sperry (audiofx.org@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package org.audiofx.mp3
{
	import flash.net.FileReference;

	/**
	 * Class for loading MP3 files from a FileReference
	 * @author spender
	 * @see flash.net.FileReference
	 */
	public class MP3FileReferenceLoader extends MP3Loader
	{
		
		/**
		 * Constructs an new MP3FileReferenceLoader instance 
		 * 
		 */
		public function MP3FileReferenceLoader()
		{
			super();			
		}
		/**
		 * Once a FileReference instance has been obtained, and the user has browsed to a file, call getSound to start loading the MP3 data.
		 * When the data is ready, an <code>MP3SoundEvent.COMPLETE</code> event is emitted.
		 * @param fr A reference to a local file.
		 * @see MP3SoundEvent
		 */
		public function getSoundFromFile(fr:FileReference):void
		{
			mp3Parser.loadFileRef(fr);
		}
	}
}