<?php 

$file = fopen("../tests.track.json", "r") or die ("Error: unable to open file 'tests.track.json'");

$file_contents = fread($file, filesize("../tests.track.json"));

// Remove after testing
header("Access-Control-Allow-Origin: *");
//
header("Content-Type: application/json");

echo $file_contents;

fclose($file);

?>
