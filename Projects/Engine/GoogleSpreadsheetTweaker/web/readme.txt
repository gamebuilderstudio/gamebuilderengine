PHP PROXY SCRIPT README

To quote Adan Forshaw's blog post "Using Google Spreadsheet forms with Flash"
<http://www.adenforshaw.co.uk/?p=4>:

   Unfortunately the google spreadsheets crosssdomain.xml does not allow flash
   content to access the spreadsheets url but by using a fairly simple php proxy
   we can easily get round this.

   So the LoadVars/URLLoader calls the local GoogleSpreadsheetProxy.php passing
   all the vars and the url for submitting the spreadsheet and simply proxys the 
   request via the url passed.

Although our script does not use a form, Adan's proxy script works very nicely.
You can actually use any proxy script, this one doesn't do anything unique. But
Adan very nicely released it for free use, so here it is. :)

Put the PHP script wherever you like on your web server (ideally in the same 
directory as your SWF). You will need PHP with libcurl installed.

There are two crossdomain.xml files included. root_crossdomain.xml goes in the
root of your domain. Rename it to crossdomain.xml. indir_crossdomain.xml goes in
the same directory as the GoogleSpreadSheetProxy.php. Rename indir_crossdomain.xml
to crossdomain.xml as well.

http://www.adobe.com/devnet/flashplayer/articles/fplayer9_security.html discusses
crossdomain.xml more fully. You may want to customize your security based on your
individual needs.

Make sure you can access the following files from your web browser:
   * The root crossdomain.xml (at yourdomain.com/crossdomain.xml).
   * The directory crossdomain.xml (if your proxy script is at 
     yourdomain.com/game/GoogleSpreadsheetProxy.php, then the directory 
     crossdomain.xml should be at yourdomain.com/game/crossdomain.xml).
   * The proxy script (ie at yourdomain.com/game/GoogleSpreadsheetProxy.php).

