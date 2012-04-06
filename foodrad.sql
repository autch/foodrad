
CREATE TABLE foodrad (
       id		BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
       csv_filename	VARCHAR(16) NOT NULL COMMENT '元CSVファイル名',
       csv_num		BIGINT NOT NULL COMMENT '元CSVファイル中の番号',
       reporter		VARCHAR(255) NULL COMMENT '報告自治体',
       performer	VARCHAR(255) NULL COMMENT '実施主体',
       performer_bureau	VARCHAR(255) NULL COMMENT '実施主体 部局',
       home_pref	VARCHAR(255) NULL COMMENT '産地 都道府県',
       home_city	VARCHAR(255) NULL COMMENT '産地 市町村',
       home_minor	VARCHAR(255) NULL COMMENT '産地 その他',
       sold		VARCHAR(255) NULL COMMENT '非流通品/流通品',
       memo		TEXT NULL COMMENT '備考',
       category		VARCHAR(255) NULL COMMENT '食品カテゴリ',
       item_name	VARCHAR(255) NOT NULL COMMENT '品目 品目名',
       item_name_minor	VARCHAR(255) NULL COMMENT '品目 その他',
       inspector	VARCHAR(255) NULL COMMENT '検査機関',
       inspect_method	VARCHAR(255) NULL COMMENT '検査法 (Ge/NaI)',
       on_gather_raw	VARCHAR(255) NULL COMMENT '採取日の生CSV内容',
       on_result_raw	VARCHAR(255) NULL COMMENT '判明日の生CSV内容',
       on_publish_raw	VARCHAR(255) NULL COMMENT '発表日の生CSV内容',

       i131_raw		VARCHAR(255) NULL COMMENT 'I131 の生 CSV 内容',
       i131_nd		BOOLEAN NOT NULL COMMENT 'I131 の ND',
       i131		DOUBLE NULL COMMENT 'I131 [Bq/kg] ND時は検出限界値',
       cs134_raw	VARCHAR(255) NULL COMMENT 'Cs134 の生 CSV 内容',
       cs134_nd		BOOLEAN NOT NULL COMMENT 'Cs134 の ND',
       cs134		DOUBLE NULL COMMENT 'Cs134 [Bq/kg] ND時は検出限界値',
       cs137_raw	VARCHAR(255) NULL COMMENT 'Cs137 の生 CSV 内容',
       cs137_nd		BOOLEAN NOT NULL COMMENT 'Cs137 の ND',
       cs137		DOUBLE NULL COMMENT 'Cs137 [Bq/kg] ND時は検出限界値',
       cs_total_raw	VARCHAR(255) NULL COMMENT '総 Cs の生 CSV 内容',
       cs_total_nd	BOOLEAN NOT NULL COMMENT '総 Cs の ND',
       cs_total		DOUBLE NULL COMMENT '総 Cs [Bq/kg] ND時は検出限界値'
) ENGINE=InnoDB CHARACTER SET utf8 AUTO_INCREMENT = 1;

CREATE INDEX foodrad_prefecture ON foodrad (home_pref);
CREATE INDEX foodrad_category_name ON foodrad (category, item_name);
CREATE INDEX foodrad_i131 ON foodrad (i131_nd, i131);
CREATE INDEX foodrad_cs134 ON foodrad (cs134_nd, cs134);
CREATE INDEX foodrad_cs137 ON foodrad (cs137_nd, cs137);
CREATE INDEX foodrad_cs_total1 ON foodrad (cs_total_nd, cs_total);
