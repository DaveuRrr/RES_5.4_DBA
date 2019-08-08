// ******************************************************************************************************
// This is a stored procedure developed by David Bahena
// Syntax is for SAP Sybase SQLAnywhere 16
// ******************************************************************************************************

// ******************************************************************************************************
// Creating a Table for new prices to reference for later
// ******************************************************************************************************

CREATE TABLE IF NOT EXISTS ambrosia_pr (
	// File variables
	sicom		INTEGER,
	micros		INTEGER,
	name		VARCHAR(50),
	tier		VARCHAR(50),
	amt			MONEY12,
	// Micros variables needed to make my life easier
	mi_seq		SEQ_NUM,
	tier_seq	SEQ_NUM,
);

// ******************************************************************************************************
// Delete all previous data from ambrosia_pr
// ******************************************************************************************************

TRUNCATE TABLE ambrosia_pr;

// ******************************************************************************************************
// Delete all previous data from gbmo_rsi_out table
// ******************************************************************************************************

INPUT INTO ambrosia_pr FROM 'D:\\new_prices.csv';

// ******************************************************************************************************
// Updating the missing information
// ******************************************************************************************************

UPDATE ambrosia_pr
   SET "mi_seq"   = m.mi_seq
  FROM micros.mi_def 			as m
 WHERE "micros" = m.obj_num;

UPDATE ambrosia_pr
   SET "tier_seq" = t.price_tier_seq
  FROM micros.price_tier_def	as t
 WHERE "tier" = t.name;

// ******************************************************************************************************
// Update prices
// ******************************************************************************************************

UPDATE micros.mi_price_def
   SET "preset_amt_1" = a.amt, 
       "preset_amt_2" = a.amt, 
       "preset_amt_3" = a.amt,
       "preset_amt_4" = a.amt,
       "preset_amt_5" = a.amt,
       "preset_amt_6" = a.amt,
       "preset_amt_7" = a.amt,
       "preset_amt_8" = a.amt,
       "preset_amt_9" = a.amt,
       "preset_amt_10" = a.amt 
  FROM ambrosia_pr 			as a,
  	   micros.mi_price_def 	as mi
 WHERE a.mi_seq = mi.mi_seq
   AND a.tier_seq = mi.price_tier_seq;
