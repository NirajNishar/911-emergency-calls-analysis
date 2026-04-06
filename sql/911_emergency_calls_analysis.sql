-- ==================================================
-- PROJECT: 911 Emergency Calls Analysis
-- TOOL: PostgreSQL
-- DATASET: 911.csv
-- ==================================================

-- ==================================================
-- 1. PROJECT OBJECTIVE
-- --------------------------------------------------
-- Analyze 911 emergency call data to identify:
-- - Most common emergency reasons
-- - Peak call hours
-- - Daily and monthly trends
-- - Weekend vs weekday patterns
-- - Busiest hour for each emergency type
-- ==================================================


-- ==================================================
-- 2. TABLE CREATION
-- --------------------------------------------------
-- Create table to store raw emergency call data
-- ==================================================

CREATE TABLE emergency_calls (
    lat FLOAT,                 -- Latitude of the incident location
    lng FLOAT,                 -- Longitude of the incident location
    description TEXT,          -- Full description of the emergency call
    zip INT,                   -- ZIP code where the call was recorded
    title TEXT,                -- Title field containing the emergency reason and extra detail
    timeStamp TIMESTAMP,       -- Date and time when the call was made
    township TEXT,             -- Township name associated with the call
    address TEXT,              -- Street address or location description
    dummy INT                  -- Extra column present in the source dataset
);


-- ==================================================
-- 3. DATA LOADING
-- --------------------------------------------------
-- Import CSV data into PostgreSQL table
-- NOTE: Update file path based on your system
-- ==================================================

-- NOTE: Update this path based on your system location
COPY emergency_calls
FROM 'path_to_your_file/911.csv'          -- File path of the source CSV file
DELIMITER ','                   -- Values in the file are separated by commas
CSV HEADER;                     -- The first row contains column names, so skip it during import


-- ==================================================
-- 4. INITIAL DATA CHECK
-- --------------------------------------------------
-- Verify that data has been loaded correctly
-- ==================================================

SELECT *
FROM emergency_calls
LIMIT 10;                       -- Show only 10 rows so the output stays manageable


-- ==================================================
-- 5. FEATURE ENGINEERING: EXTRACT EMERGENCY REASON
-- --------------------------------------------------
-- Extract category (EMS, Fire, Traffic) from 'title'
-- ==================================================

-- The title column usually contains text in the format:
-- "EMS: BACK PAINS/INJURY"
-- "Fire: VEHICLE ACCIDENT"
-- We extract the part before the colon as the reason.
ALTER TABLE emergency_calls
ADD COLUMN reason TEXT;         -- Create a new column to store the extracted reason

-- Populate the new reason column for every row
UPDATE emergency_calls
SET reason = TRIM(SPLIT_PART(title, ':', 1));
-- SPLIT_PART(title, ':', 1) gets the text before the first colon
-- TRIM(...) removes any leading or trailing spaces


-- ==================================================
-- 6. FEATURE ENGINEERING: TIME-BASED COLUMNS
-- --------------------------------------------------
-- Extract hour, month, and day of week from timestamp
-- ==================================================

ALTER TABLE emergency_calls
ADD COLUMN hour INT,            -- Stores the hour of the day (0 to 23)
ADD COLUMN month INT,           -- Stores the month number (1 to 12)
ADD COLUMN day_of_week INT;     -- Stores the day of week as a number

-- Populate all three time-related columns from the timestamp
UPDATE emergency_calls
SET
    hour = EXTRACT(HOUR FROM timeStamp),          -- Extracts the hour from the timestamp
    month = EXTRACT(MONTH FROM timeStamp),        -- Extracts the month from the timestamp
    day_of_week = EXTRACT(DOW FROM timeStamp);    -- Extracts the day of week (0 = Sunday, 6 = Saturday)


-- ==================================================
-- 7. FEATURE ENGINEERING: WEEKEND FLAG
-- --------------------------------------------------
-- Mark calls as weekend (Saturday/Sunday) or weekday
-- ==================================================

ALTER TABLE emergency_calls
ADD COLUMN is_weekend BOOLEAN;  -- Boolean column to store whether the call occurred on a weekend

UPDATE emergency_calls
SET is_weekend = CASE
    WHEN day_of_week IN (0, 6) THEN TRUE   -- Sunday (0) and Saturday (6) are weekend days
    ELSE FALSE                              -- All other days are weekdays
END;


-- ==================================================
-- 8. ANALYSIS QUERIES
-- ==================================================

-- --------------------------------------------------
-- 8.1 Most common emergency reasons
-- --------------------------------------------------
SELECT
    reason,                          -- Grouping field: emergency reason
    COUNT(*) AS total_calls          -- Count how many calls fall under each reason
FROM emergency_calls
GROUP BY reason                    -- Aggregate rows by reason
ORDER BY total_calls DESC;         -- Show the most frequent reasons first


-- --------------------------------------------------
-- 8.2 Peak call hours
-- --------------------------------------------------
SELECT
    hour,                            -- Grouping field: hour of the call
    COUNT(*) AS total_calls          -- Total calls recorded in each hour
FROM emergency_calls
GROUP BY hour                      -- Aggregate by hour
ORDER BY total_calls DESC;         -- Show the busiest hours first


-- --------------------------------------------------
-- 8.3 Calls by day of week (0 = Sunday, 6 = Saturday)
-- --------------------------------------------------
SELECT
    day_of_week,                     -- Grouping field: day number from EXTRACT(DOW ...)
    COUNT(*) AS total_calls          -- Total calls for each day of week
FROM emergency_calls
GROUP BY day_of_week                -- Aggregate by day of week
ORDER BY day_of_week;               -- Display in natural day order


-- --------------------------------------------------
-- 8.4 Weekend vs weekday comparison
-- --------------------------------------------------
SELECT
    is_weekend,                      -- TRUE for weekend calls, FALSE for weekday calls
    COUNT(*) AS total_calls          -- Total calls in each category
FROM emergency_calls
GROUP BY is_weekend                 -- Group rows into weekend and weekday
ORDER BY is_weekend DESC;           -- Put TRUE first so weekend appears before weekday


-- --------------------------------------------------
-- 8.5 Monthly call trends
-- --------------------------------------------------
SELECT
    month,                           -- Grouping field: month number
    COUNT(*) AS total_calls          -- Total calls in each month
FROM emergency_calls
GROUP BY month                     -- Aggregate by month
ORDER BY month;                    -- Show months in chronological order


-- ==================================================
-- 9. ADVANCED ANALYSIS
-- ==================================================

-- --------------------------------------------------
-- 9.1 Busiest hour for each emergency type
-- --------------------------------------------------
SELECT
    reason,                          -- Emergency reason category
    hour,                            -- Hour being analyzed
    total_calls                      -- Total calls for that reason and hour
FROM (
    SELECT
        reason,                      -- Group by reason first
        hour,                        -- Then group by hour
        COUNT(*) AS total_calls,     -- Count calls for each reason-hour combination

        -- Rank hours within each emergency reason based on call volume.
        -- RANK() assigns the same rank to tied values.
        RANK() OVER (
            PARTITION BY reason      -- Restart ranking separately for each reason
            ORDER BY COUNT(*) DESC   -- Highest call count gets rank 1
        ) AS rnk

    FROM emergency_calls
    GROUP BY reason, hour            -- Build one row per reason and hour
) t
WHERE rnk = 1;                       -- Keep only the busiest hour(s) for each reason


-- --------------------------------------------------
-- 9.2 Monthly running total of calls
-- --------------------------------------------------
SELECT
    month,                           -- Month number
    COUNT(*) AS total_calls,         -- Total calls in that month

    -- Running total adds the monthly counts in order of month.
    -- This gives a cumulative total from the first month onward.
    SUM(COUNT(*)) OVER (
        ORDER BY month               -- Accumulate month by month
    ) AS running_total

FROM emergency_calls
GROUP BY month;                      -- Create one row per month


-- ==================================================
-- 10. PROJECT SUMMARY (INSIGHTS)
-- --------------------------------------------------
-- This project helps identify:
-- - Most frequent emergency types
-- - Peak hours of emergency activity
-- - Weekly and monthly patterns
-- - Weekend vs weekday behavior
-- - Busiest hour per emergency category
-- - Overall growth trend using running totals
-- ==================================================