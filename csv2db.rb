#!/usr/bin/ruby1.9.1
# -*- coding: utf-8; -*-
#
# CSV ファイルを DB に入れる
#
# csv2db.rb filename.csv filename.csv ...
#
# 引数に CSV ファイル名を指定する。
# CSV 列から DB 列への変換基準はファイル名のパターンで決めている。
#
# 何かあるとすぐ例外を吐いてトランザクションをロールバックする。
# 同じ CSV ファイルを二度入れるようなチェックをしていないので、
# ダブったら DB 直編集で修正する。

require 'mysql'
require 'csv'
require 'yaml'

require_relative 'csv2db_inserters.rb'

# DB の列。スキーマを直したらここも修正する必要がある。
COLUMNS = %w(id csv_filename csv_num reporter performer performer_bureau home_pref home_city home_minor sold memo category item_name item_name_minor inspector inspect_method on_gather_raw on_result_raw on_publish_raw i131_raw i131_nd i131 cs134_raw cs134_nd cs134 cs137_raw cs137_nd cs137 cs_total_raw cs_total_nd cs_total)

DBCONFIG_FILENAME = "/home/autch/.foodrad.json"
db_cfg = YAML.load_file(DBCONFIG_FILENAME)

mysql = Mysql.new(db_cfg['host'], db_cfg['username'], db_cfg['password'], db_cfg['db'])
db_cfg = nil
begin
  mysql.query("SET CHARACTER SET utf8")
  mysql.query("SET NAMES utf8")

  # CSV -> DB を担当するクラス
  inserters = {
    :old_mhlw => OldMHLWInserter.new,
    :new_mhlw => NewMHLWInserter.new,
    :yasaikensa => YasaikensaInserter.new
  }

  mysql.query("START TRANSACTION")
  begin
    sql = sprintf("INSERT INTO foodrad (%s) VALUES (%s)",
                  COLUMNS.map{|i| i.to_s }.join(', '), (['?'] * COLUMNS.count).join(', '))
    stmt = mysql.prepare(sql)
    begin
      ARGV.each do |filename|
        header = ""

        # ファイル名のパターンで CSV の形式を推定
        case filename
        when /a\d+\.csv$/
          # 厚生労働省新形式
          inserter = inserters[:new_mhlw]
        when /\d+\.csv$/
          # 厚生労働省旧形式、2012.03.31 まで
          inserter = inserters[:old_mhlw]
        when /yasaikensa.csv$/
          # 対応しない
          # inserter = inserters[:yasaikensa]
          next
        else
          next
        end

        print filename, " => ", inserter.class, "\n"

        options = { :encoding => 'UTF-8', :headers => true, :return_headers => false, :skip_blanks => false }
        inserter.csv_filename = File.basename(filename)
        CSV.foreach(filename, options) do |row|
          # CSV 列から DB 列へ変換したあと、
          hash = inserter.convert(row)
          # 最終的に DB に入れる hash を作成
          values = hash.values_at(*COLUMNS)
          begin
            stmt.execute(*values)
          rescue
            p values
            raise
          end
        end
      end
    ensure
      stmt.close
    end
    mysql.commit
  rescue
    mysql.rollback
    raise
  end
ensure
  mysql.close
end
