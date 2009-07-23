<?php
	/**
	* A little poxy proxy for Aden and his Flash, SH 2008-07-28
	* Take incoming POST vars and pass them on
	* Coded for Google spreadsheet -> Flash demo on www.AdenForshaw.com
	*/
	/* Only proxy to URLs matching this */
	$sProxyUrlRegex = '#^http://spreadsheets.google.com/#';


	/**
	* Make a simple status/error page
	*/
	function showErrorStatus ($iCode=500, $sText='Internal Server Error')
	{

		header('HTTP/1.1 ' . $iCode  . ' ' . $sText);
		header('Status: ' . $iCode . ' ' . $sText);

		echo "<html><head><title>Oops</title></head><body><h1>" . $sText . "</h1></body></html";

	}


	/**
	* Replacement for curl_setopt which only exists in PHP>=5.1.3
	*
	* @param resource $rCh
	* @param array $aCurlOpt
	*
	* @return boolean
	*/
	function local_curl_setopt_array ($rCh, $aCurlOpt)
	{

		foreach ($aCurlOpt as $sKey=>$sVal) {

			if (!curl_setopt($rCh, $sKey, $sVal)) {
				return false;
			}

		}

		return true;

	}

	/* Set cURL options */

	$aCurlOpt = array (

		CURLOPT_FAILONERROR		=> true, // Fail on non-200 responses
		CURLOPT_POST			=> false,
		CURLOPT_RETURNTRANSFER	=> true,
		CURLOPT_TIMEOUT			=> 60,
		CURLOPT_HEADER			=> false, // Don't include header in response
		CURLOPT_USERAGENT		=> 'Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)',
		CURLOPT_FOLLOWLOCATION	=> true,
		CURLOPT_MAXREDIRS		=> 5

	);

	/* Check URL is specified */

	if (!isset($_POST['_url']) || empty($_POST['_url'])) {

		showErrorStatus(400, 'No URL specified');
		exit;

	}

	/* Set cURL URL and remove from POST before forwarding */

	$sCurlUrl = $_POST['_url'];

	unset($_POST['_url']);

	/* Make POST string */

	$aPostData = array();

	foreach ($_POST as $sKey=>$sVal) {

		$sKey = str_replace('_', '.', $sKey); // Revert PHP conversion nonsense
		$aPostData[] = urlencode($sKey) . '=' . urlencode($sVal);

	}

	$sPostData = join('&', $aPostData);

	/* Do cURL stuff */

	if (false == preg_match($sProxyUrlRegex, $sCurlUrl)) {

		showErrorStatus(401, 'Naughty, you can\'t proxy to ' . $sCurlUrl);

	} else if (!$rCh = curl_init($sCurlUrl)) {

		showErrorStatus(NULL, 'Couldn\'t initialize cURL to ' . $sCurlUrl);

	} else if (false == local_curl_setopt_array($rCh, $aCurlOpt)) {

		showErrorStatus(NULL, 'Couldn\'t set cURL options');

	} else if (false == ($sResponse = curl_exec($rCh))) {

		showErrorStatus(NULL, 'Response was false' . curl_error($rCh));

	} else {

		/* All good */

		echo $sResponse;

	}

	exit;