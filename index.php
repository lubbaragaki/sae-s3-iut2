<?php

$page_name = "login.js";

session_start();

if (isset($_SESSION['connected'])) {
	if($_SESSION['connected'] == true) {
		$page_name = "home.js";
	}
}

$main = ($page_name == "home.js") ? "HomePage" : "Login";

?>
<!DOCTYPE HTML>
<html style="margin: 0; padding: 0;">
<head>
  <meta charset="UTF-8">
  <title>Main</title>
<script src="<?php echo $page_name ?>"></script>
</head>
<body style="margin: 0; padding: 0;">

<div id="elm-node"></div>
<script>
var app = Elm.<?php echo $main ?>.init({
    node: document.getElementById('elm-node')
  });
</script>

</body>
</html>
