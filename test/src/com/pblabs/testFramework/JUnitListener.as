package com.pblabs.testFramework
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.fscommand;
	
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
		
		private var successes:Array = new Array();
		private var ignores:Array = new Array();
		
		private var file:File;
        private var outputPath:String;
        
        private var exitOnComplete:Boolean;
		
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
		
		public function JUnitListener(outputPath:String, exitOnComplete:Boolean)
		{
		    this.outputPath = outputPath;
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
			
			initFile();
			createXMLReports();
			exit();
		}
		
		override public function testFailure( failure:Failure ):void 
		{
			// Add failing method to proper TestCase in the proper TestSuite
			lastFailedTest = failure.description;
			
			var descriptor : Descriptor = getDescriptorFromDescription( failure.description );
			
			var report : TestSuiteReport = getReportForTestSuite( descriptor.path + "." + descriptor.suite );
			report.failures++;
			report.tests++;
			report.methods.push( failure );
		}
		
		private function initFile( ) : void
		{
		    file = new File(outputPath);

		    if (file.exists)
		        file.deleteFile();
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
			/**
			 * JAdkins - 7/27/09 - Removed duplicate console report
			 */
			
		    var fs:FileStream = new FileStream();
		    fs.open(file, FileMode.WRITE);

            fs.writeUTFBytes("<testsuites>");
			for each ( var testSuiteReport : TestSuiteReport in testSuiteReports )
			{
				// Create the XML report.
				var xml : XML = createXMLTestSuite( testSuiteReport );
				
				// Send the XML report.
                fs.writeUTFBytes(xml.toXMLString());				
			}
			
            fs.writeUTFBytes("</testsuites>");
			fs.close();
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
				{ message }
				</failure>;
			
			return xml;
		}
		
		/**
		 * Exit the test runner and close the player.
		 */
		private function exit() : void
		{
		    if (!exitOnComplete) return;
		    
		    //do we ewant to exit with an error code if any of the tests fail?
		    NativeApplication.nativeApplication.exit();
		}
	}
}