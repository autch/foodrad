<?php
# 都道府県リストの JSON を返す。
#
# callback([
#   { "home_pref": "北海道", /* 都道府県名。CSV に現れる名前なので
#                               全部で 47 個というわけではない */
#     "count": 100           /* この都道府県名でマッチした検査結果の総数  */
#   },
#   ...
# ])
#

require_once 'db.inc.php';
require_once 'jsonp.inc.php';

$sql = "SELECT home_pref, COUNT(*) AS count FROM foodrad GROUP BY home_pref ORDER BY home_pref";

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
