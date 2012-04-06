#!/usr/bin/ruby1.9.1
# -*- coding: utf-8; -*-

require 'mysql'
require 'csv'
require 'yaml'

require_relative 'csv2db_inserters.rb'

COLUMNS = %w(id csv_filename csv_num reporter performer performer_bureau home_pref home_city home_minor sold memo category item_name item_name_minor inspector inspect_method on_gather_raw on_result_raw on_publish_raw i131_raw i131_nd i131 cs134_raw cs134_nd cs134 cs137_raw cs137_nd cs137 cs_total_raw cs_total_nd cs_total)

DBCONFIG_FILENAME = "/home/autch/.foodrad.json"
db_cfg = YAML.load_file(DBCONFIG_FILENAME)

mysql = Mysql.new(db_cfg['host'], db_cfg['username'], db_cfg['password'], db_cfg['db'])
db_cfg = nil
begin
  mysql.query("SET CHARACTER SET utf8")
  mysql.query("SET NAMES utf8")

  inserters = {
    :old_mhlw => OldMHLWInserter.new,
    :new_mhlw => NewMHLWInserter.new,
    :yasaikensa => YasaikensaInserter.new
  }

  mysql.query("START TRANSACTION")
  begin
    sql = sprintf("INSERT INTO foodrad (%s) VALUES (%s)",
                  COLUMNS.map{|i| i.to_s }.join(', '), (['?'] * COLUMNS.count).join(', '))
    puts sql
    stmt = mysql.prepare(sql)
    begin
      ARGV.each do |filename|
        header = ""

        case filename
        when /a\d+\.csv$/
          inserter = inserters[:new_mhlw]
        when /\d+\.csv$/
          inserter = inserters[:old_mhlw]
        when /yasaikensa.csv$/
          inserter = inserters[:yasaikensa]
        else
          next
        end

        print filename, " => ", inserter.class, "\n"

        options = { :encoding => 'UTF-8', :headers => true, :return_headers => false, :skip_blanks => false }
        inserter.csv_filename = File.basename(filename)
        CSV.foreach(filename, options) do |row|
          hash = inserter.convert(row)
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
