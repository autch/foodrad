<?php

require_once 'db.inc.php';
require_once 'jsonp.inc.php';

$sql = "SELECT category, item_name, COUNT(*) AS count FROM foodrad " .
    "GROUP BY item_name, category ORDER BY category, item_name";

$callback = get_jsonp_callback();

$mysqli = db_connect();
if($result = $mysqli->query($sql))
{
    header("Content-Type: application/javascript");

    $categories = array();
    while($row = $result->fetch_assoc())
    {
        $categories[$row['category']]['items'][] = $row['item_name'];
        $categories[$row['category']]['count'] += intval($row['count']);
    }

    print jsonp_begin($callback);
    print json_encode($categories);
    print jsonp_end($callback);
    print "\n";
}

$mysqli->close();
