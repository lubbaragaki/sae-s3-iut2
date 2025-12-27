<?php

function get_credentials_from_db(): array {
	return array('mouedh' => 'd545e4d0faad52ff38fdd5686bb96169e37db59a30eeb1a466decc778463e1d2ba8dc53b0f7121b3e0c4098607925fdc6191b2b959861bc89a63b32dee95621a');
}

$data = file_get_contents('php://input'); 

// var_export with 'true' returns the value as a string
$login_attempt = var_export($data, true);
$login_attempt = explode(';', $login_attempt);
$login = explode(':', $login_attempt[0])[1];
$pass = rtrim(explode(':', $login_attempt[1])[1], "'");

$credentials = get_credentials_from_db();

error_log(print_r($login.":[".$pass."] ".hash('sha512', $pass)."\n", true));

session_start();

if(isset($credentials[$login])) {
	if(hash('sha512', $pass) == $credentials[$login]) {
		$_SESSION['connected'] = true;
		exit(0);
	}
}

echo "incorrect";

?>
