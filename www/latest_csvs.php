<?php
# DB に入っている CSV ファイル名のリストを返す。
#
# callback([
#   { "csv_filename": "a361.csv", /* CSV ファイル名 */
#     "count": 100           /* このファイル名で DB に入っている検査結果の総数 */
#   },
#   ...
# ])
#

require_once 'db.inc.php';
require_once 'jsonp.inc.php';

$sql = "SELECT csv_filename, COUNT(*) AS count FROM foodrad GROUP BY csv_filename ORDER BY csv_filename";

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
