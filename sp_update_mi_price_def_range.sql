// ******************************************************************************************************
// This is a stored procedure developed by David Bahena
// Syntax is for SAP Sybase SQLAnywhere 16
//
// Purpose : Updates all the empty cells when adding in new price tiers so they do not have to be 
//              manually entered via GUI. This is specifically for range updated instead of the whole
//              table.
// ******************************************************************************************************
BEGIN

DECLARE @np MONEY12;  // Price Variable
DECLARE @sobj INT;    // This is for the Max record from mi_seq
DECLARE @lobj INT;    // For End Loop
DECLARE @obj  INT;    // For Start Loop
DECLARE @i    INT;

SET @obj = 7000;    // Start Loop Object Number
SET @lobj = 7806;   // End Loop Object Number

// Loop Starts here
tier: WHILE @obj < @lobj LOOP
    SET @np =   (SELECT TOP 1 mp.preset_amt_1 
                  FROM micros.mi_price_def mp, micros.mi_def mi
                 WHERE obj_num = @obj
                   AND mi.mi_seq = mp.mi_seq
                   AND mp.price_tier_seq = 44);

    IF @np IS NOT NULL THEN
        UPDATE "micros"."mi_price_def" 
           SET "preset_amt_1"= @np, 
               "preset_amt_2"= @np, 
               "preset_amt_3"= @np,
               "preset_amt_4"= @np,
               "preset_amt_5"= @np,
               "preset_amt_6"= @np,
               "preset_amt_7"= @np,
               "preset_amt_8"= @np,
               "preset_amt_9"= @np,
               "preset_amt_10"= @np
          FROM micros.mi_price_def mip, micros.mi_def m
         WHERE obj_num = @obj
           AND m.mi_seq = mip.mi_seq
           AND mip.price_tier_seq >= 52
     END IF;

    SET @obj = @obj + 1;    // ADD 1
    SET @np = NULL; // Removes the previous value

END LOOP tier;
END

//17410
