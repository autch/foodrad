<?php

require_once 'db.inc.php';
require_once 'jsonp.inc.php';

$where = array();

if(!empty($_REQUEST['home_pref']))
    $where[] = sprintf("home_pref LIKE '%s%%'", trim($_REQUEST['home_pref']));
if(!empty($_REQUEST['category']))
    $where[] = sprintf("category LIKE '%s%%'", trim($_REQUEST['category']));
if(!empty($_REQUEST['item_name']))
    $where[] = sprintf("item_name LIKE '%s%%'", trim($_REQUEST['item_name']));
if(isset($_REQUEST['cs_total']))
{
    $cs_total = floatval($_REQUEST['cs_total']);

    if($cs_total > 0) {
        $where[] = "cs_total_nd <> 1";
        $where[] = sprintf("cs_total >= %f", $cs_total);
    }
}

if(!empty($where))
    $sql = sprintf("SELECT * FROM foodrad WHERE %s", join(' AND ', $where));
else
    $sql = "SELECT * FROM foodrad";

$callback = get_jsonp_callback();

$mysqli = db_connect();
if($result = $mysqli->query($sql))
{
    header("Content-Type: application/javascript");

    print jsonp_begin($callback);
    print "[\n";
    while($row = $result->fetch_assoc())
    {
        print json_encode($row);
        print ",\n";
    }
    print "]";
    print jsonp_end($callback);
    print "\n";
}
$mysqli->close();
