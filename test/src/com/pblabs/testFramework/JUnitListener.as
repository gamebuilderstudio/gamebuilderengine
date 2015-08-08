/**
 * This is based on code from the FlexUnit library. 
 * 
 * Copyright (c) 2003-2008. Adobe Systems Incorporated.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this 
 * list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * - Neither the name of Adobe Systems Incorporated nor the names of its contributors 
 * may be used to endorse or promote products derived from this software without 
 * specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.pblabs.testFramework
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.flexunit.runner.Descriptor;
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunListener;

	public class JUnitListener extends RunListener
	{
		private var logger:ILogger = Log.getLogger("org.flexunit.internals.listeners.JUnitListener");
		
		private var lastFailedTest:IDescription;
		
		private var successes:Array = [];
		private var ignores:Array = [];
		
		private var outputDir:File;
        
        private var exitOnComplete:Boolean;
        
        private var exitCode:int;
		
		/**
		 * <String, TestSuiteReport >
		 */
		private var testSuiteReports : Object = new Object(); 
		
		//--------------------------------------------------------------------------
		//
		//  RunListener methods
		//
		//--------------------------------------------------------------------------
		/*override public function testStarted( description:Description ):void
		{
		var descriptor : Descriptor = getDescriptorFromDescription( description );
		var report : TestSuiteReport = getReportForTestSuite( descriptor.path + "." + descriptor.suite );
		report.tests++;
		}*/
		
		public function JUnitListener(outputDir:String, exitOnComplete:Boolean)
		{
		    this.outputDir = new File(outputDir);
		    this.exitOnComplete = exitOnComplete;
		}
		
		override public function testFinished( description:IDescription ):void 
		{
			// Add failing method to proper TestCase in the proper TestSuite
			/**
			 * JAdkins - 7/27/09 - Now checks if test is not a failure.  If test is not a failure
			 * Adds to the finished tests
			 */
			if(!lastFailedTest || description.displayName != lastFailedTest.displayName) {
				var descriptor : Descriptor = getDescriptorFromDescription( description );
				
				var report : TestSuiteReport = getReportForTestSuite( descriptor.path + "." + descriptor.suite );
				report.tests++;
				report.methods.push( descriptor );	
			}
		}
		
		override public function testRunFinished( result:Result ):void 
		{
			this.result = result;
			
			logger.debug("test run finished.");
			
			createXMLReports();
			exit();
		}
		
		override public function testFailure( failure:Failure ):void 
		{
			// Add failing method to proper TestCase in the proper TestSuite
			lastFailedTest = failure.description;
			
			var descriptor : Descriptor = getDescriptorFromDescription( failure.description );
			
			var report : TestSuiteReport = getReportForTestSuite( descriptor.path + "." + descriptor.suite );
			exitCode++;
			report.failures++;
			report.tests++;
			report.methods.push( failure );
		}
		
		private function errorHandler(event:Event):void
		{
			logger.error("unable to connect to flexUnit ant task to send results. {0}", event.type );
			throw new Error("unable to connect to flex builder to send results: " + event.type);
		}
		
		private function getDescriptorFromDescription(description:IDescription ):Descriptor
		{
			// reads relavent data from descriptor
			/**
			 * JAdkins - 7/27/07 - FXU-53 - Listener was returning a null value for the test class
			 * causing no data to be returned.  If length of array is greater than 1, then class is
			 * not in the default package.  If array length is 1, then test class is default package
			 * and formats accordingly.
			 **/
			var descriptor:Descriptor = new Descriptor();
			var descriptionArray:Array = description.displayName.split("::");
			var classMethod:String;
			if ( descriptionArray.length > 1 ) {
				descriptor.path = descriptionArray[0];
				classMethod =  descriptionArray[1];
			} else {
				classMethod =  descriptionArray[0];
			}
			var classMethodArray:Array = classMethod.split(".");
			descriptor.suite = ( descriptor.path == "" ) ?  "" : 
				classMethodArray[0];
			descriptor.method = classMethodArray[1];
			
			return descriptor;
		}
		
		private function getReportForTestSuite( testSuite : String ) : TestSuiteReport
		{
			var report : TestSuiteReport;
			
			if( !(testSuite in testSuiteReports ))
			{
				testSuiteReports[ testSuite ] = new TestSuiteReport();	
			}  
			
			report = TestSuiteReport( testSuiteReports[ testSuite ]);
			report.name = testSuite;
			
			return report; 	
		}
		
		/*
		* Internal methods
		*/
		private function createXMLReports () : void
		{
		    if (outputDir.exists)
		        outputDir.deleteDirectory(true);
		        
		    outputDir.createDirectory();
			
			for each ( var testSuiteReport : TestSuiteReport in testSuiteReports )
			{
				// Create the XML report for this suite.
				var xml : XML = createXMLTestSuite(testSuiteReport);
				
				// Write the XML report.
    		    var fs:FileStream = new FileStream();
    		    fs.open(outputDir.resolvePath(testSuiteReport.name + ".xml"), FileMode.WRITE);
    		    try
    		    {
                    fs.writeUTFBytes(xml.toXMLString());
    		    }
    		    finally
    		    {
        		    fs.close();
    		    }
			}
		}
		
		protected function createXMLTestSuite( testSuiteReport:TestSuiteReport ) : XML 
		{
			var name : String = testSuiteReport.name;
			var errors : uint = testSuiteReport.errors;
			var failures : uint = testSuiteReport.failures;
			var tests : uint = testSuiteReport.tests;
			var time : Number = testSuiteReport.time;
			
			var xml : XML =
				<testsuite
					errors={ errors }						 
				failures={ failures }
				name={ name }
				tests={ tests }
				time={ time } > </testsuite>; 
			
			for each ( var result : * in testSuiteReport.methods )
			{
				xml.appendChild( createTestCase( result ));	
			}
			
			return xml;
		}
		
		
		/**
		 * Create the test case XML.
		 * @return the XML.
		 */
		private function createTestCase( result : * ) : XML
		{
			// result can be Failure or Descriptor
			var isDescriptor : Boolean = result is Descriptor;
			var descriptor : Descriptor = isDescriptor ? Descriptor( result ) : getDescriptorFromDescription( Failure(result).description );
			var classname : String = descriptor.path + "." + descriptor.suite;
			var name : String = descriptor.method;
			var time : Number = 0; 
			
			var xml : XML =
				<testcase
					classname={ classname }
				name={ name }
				time={ time } />;
			
			return isDescriptor ? xml : xml.appendChild( createFailure( Failure(result)));
		}
		
		/**
		 * Create the failure XML.
		 * @return the XML.
		 */
		private function createFailure( failure : Failure ) : XML
		{
			var descriptor : Descriptor = getDescriptorFromDescription( failure.description );
			var type : String = failure.testHeader;
			var message : String;
			if ( failure.stackTrace != null )
			{
				message = failure.description + failure.stackTrace;
			}
			else
			{
				message = String(failure.description);
			}
			
			var xml : XML =
				<failure type={ "" }>
				{ message.toString() }
				</failure>;
			
			return xml;
		}
		
		/**
		 * Exit the test runner and close the player.
		 */
		private function exit() : void
		{
		    if (!exitOnComplete) return;

		    NativeApplication.nativeApplication.exit(exitCode);
		}
	}
}