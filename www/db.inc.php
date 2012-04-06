<?php

define('DBCONFIG_FILENAME', '/home/autch/.foodrad.json');

function db_connect()
{
    $db_cfg = json_decode(file_get_contents(DBCONFIG_FILENAME));

	$mysqli = new mysqli($db_cfg->host, $db_cfg->username, $db_cfg->password, $db_cfg->db);
    $mysqli->query("SET NAMES utf8");
    $mysqli->query("SET CHARACTER SET utf8");

    return $mysqli;
}
