#!/usr/bin/ruby1.9.1
# -*- coding: utf-8; -*-
#
# CSV ファイル更新チェック
#
# 一日一回 cron でこのスクリプトを回せば更新チェックできるようになっている。
#

require 'yaml'
require 'mysql'

dir = File.dirname(File.expand_path(__FILE__))
DATA_DIR = File.join(dir, "data")

# 更新チェック
abort("Download failed") unless system(File.join(dir, "get_csv.sh"), DATA_DIR)

DBCONFIG_FILENAME = "/home/autch/.foodrad.json"
db_cfg = YAML.load_file(DBCONFIG_FILENAME)

mysql = Mysql.new(db_cfg['host'], db_cfg['username'], db_cfg['password'], db_cfg['db'])
db_cfg = nil
begin
  mysql.query("SET CHARACTER SET utf8")
  mysql.query("SET NAMES utf8")

  # DB に入っているファイル名を集める
  files_in_db = []
  mysql.query("SELECT DISTINCT csv_filename FROM foodrad") do |res|
    res.each{|row| files_in_db << row[0] }
  end

  # data ディレクトリにあるファイル名を集める
  files_in_dir = Dir.glob(File.join(DATA_DIR, "*.csv"))
  files_in_dir.reject!{|f| /yasaikensa.csv$/ =~ f}
  # ディレクトリにあって DB にないファイルを調べる
  files_in_dir.reject!{|f| files_in_db.include?(File.basename(f)) }

  # あとは実行するだけ
  csv2db = File.join(dir, "csv2db.rb")
  print csv2db, " ", files_in_dir.join(" "), "\n"
  system(csv2db, *files_in_dir)
ensure
  mysql.close
end
