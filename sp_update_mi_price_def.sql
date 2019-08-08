// ******************************************************************************************************
// This is a stored procedure developed by David Bahena
// Syntax is for SAP Sybase SQLAnywhere 16
//
// Purpose : Updates all the empty cells when adding in new price tiers so they do not have to be 
//              manually entered via GUI.
// ******************************************************************************************************
BEGIN

DECLARE @nprice MONEY12;    // This is to update the Nulls
DEClARE @bool   BIT;        // This is to check if the record is there
DECLARE @entry  INT;        // This is for the Max record from mi_seq
DECLARE @i INT;             // For Loop

// Pulls the last Entry
SET @entry = (SELECT TOP 1 "mi_seq"
                FROM micros.mi_price_def
            ORDER BY mi_seq DESC);

SET @i = 1;

// Loop Starts here
tier: WHILE @i < @entry LOOP

    SET @nprice = (SELECT TOP 1 "preset_amt_1"
                     FROM micros.mi_price_def
                    WHERE "mi_seq" = @i
                      AND "price_tier_seq" = 44);

    IF @nprice IS NOT NULL THEN
        UPDATE "micros"."mi_price_def" 
           SET "preset_amt_1"= @nprice, 
               "preset_amt_2"= @nprice, 
               "preset_amt_3"= @nprice,
               "preset_amt_4"= @nprice,
               "preset_amt_5"= @nprice,
               "preset_amt_6"= @nprice,
               "preset_amt_7"= @nprice,
               "preset_amt_8"= @nprice,
               "preset_amt_9"= @nprice,
               "preset_amt_10"= @nprice 
         WHERE "mi_seq"=@i
           AND "price_tier_seq" >= 52;
    END IF;

    SET @i = @i + 1;    // ADD 1
    SET @nprice = NULL; // Removes the previous value

END LOOP tier;
END