# -*- coding: utf-8; -*-

class CSVInserter
  attr_accessor :csv_filename

  def convert(row)
    values = row.fields.map{|i| i == "-" ? nil : i }
    out_hash = Hash[*csv_columns.zip(values).flatten]
    out_hash.default = nil
    out_hash["csv_filename"] = @csv_filename
    fill_missing(row, out_hash)
    out_hash
  end

  def set_values(hash, key_stem)
    if hash[key_stem + '_raw'].nil? || /-/ =~ hash[key_stem + '_raw'] then
      hash[key_stem + '_nd'] = 1
      hash[key_stem] = nil
    elsif /^< ?(.*)$/ =~ hash[key_stem + '_raw'] then
      hash[key_stem + '_nd'] = 1
      hash[key_stem] = $1.to_f
    else
      hash[key_stem + '_nd'] = 0
      hash[key_stem] = hash[key_stem + '_raw'].to_f
    end
  end

  def set_cs_total(hash)
    if hash['cs134_nd'] || hash['cs137_nd'] then
      hash['cs_total_nd'] = 1
      hash['cs_total'] = nil
    elsif hash['cs134'].nil? || hash['cs137'].nil? then
      hash['cs_total_nd'] = 0
      hash['cs_total'] = nil
    else
      hash['cs_total_nd'] = 0
      hash['cs_total'] = hash['cs137'] + hash['cs134']
    end
  end
end

class OldMHLWInserter < CSVInserter
  CSV_HEADER = "No,報告自治体,実施主体_主体,実施主体_部局,産地_都道府県,産地_市町村,非流通品/流通品,備考,食品カテゴリ,品目,検査機関,検査法(Ge/NaI),採取日(購入日),結果判明日,I131(Bq/kg),Cs134(Bq/kg),Cs137(Bq/kg)"
  CSV_COLUMNS = %w(csv_num reporter performer performer_bureau home_pref home_city sold memo category item_name inspector inspect_method on_gather_raw on_result_raw i131_raw cs134_raw cs137_raw)

  def csv_columns
    CSV_COLUMNS
  end

  def fill_missing(row, out_hash)
    set_values(out_hash, 'i131')
    set_values(out_hash, 'cs134')
    set_values(out_hash, 'cs137')
    set_cs_total(out_hash)
  end
end

class NewMHLWInserter < CSVInserter
  CSV_HEADER = "No,報告自治体,実施主体,産地_都道府県,産地_市町村,産地_その他,非流通品/流通品,食品カテゴリ,品目_品目名,品目_その他,検査機関,検査法,採取日(購入日),結果判明日,Cs134(Bq/kg),Cs137(Bq/kg),Cs合計(Bq/kg)"
  CSV_COLUMNS = %w(csv_num reporter performer home_pref home_city home_minor sold category item_name item_name_minor inspector inspect_method on_gather_raw on_result_raw cs134_raw cs137_raw cs_total_raw)

  def csv_columns
    CSV_COLUMNS
  end

  def fill_missing(row, out_hash)
    set_values(out_hash, 'i131')
    set_values(out_hash, 'cs134')
    set_values(out_hash, 'cs137')
    set_values(out_hash, 'cs_total')
  end
end

class YasaikensaInserter < CSVInserter
  CSV_HEADER = "No,実施主体,都道府県,市町村,採取,食品分類,品目,検査機関,採取日,判明日,公開日,ヨウ素131,セシウム134,セシウム137,セシウム"
  CSV_COLUMNS = %w(csv_num performer home_pref home_city sold category item_name inspector on_gather_raw on_result_raw on_publish_raw i131_raw cs134_raw cs137_raw cs_total_raw)

  def csv_columns
    CSV_COLUMNS
  end

  def fill_missing(row, out_hash)
    set_values(out_hash, 'i131')
    set_values(out_hash, 'cs134')
    set_values(out_hash, 'cs137')
    set_values(out_hash, 'cs_total')
  end
end
