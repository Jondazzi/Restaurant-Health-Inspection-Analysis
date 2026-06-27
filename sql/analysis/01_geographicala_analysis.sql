-- Geographical Analysis

-- Score distribution analysis by city (min 50 inspections)
-- Southeast LA and San Gabriel Valley have the lowest scores on average
-- These two areas have the lowest minimums by city (58-70) & highest STD (5-6+), outliers pulling them down
-- Every city has restaurants scoring 99-100 (perfect scores)

SELECT 
    facility_city, 
    ROUND(AVG(score), 2) AS average_score,
    MIN(score) AS lowest_score,
    MAX(score) AS highest_score,
    ROUND(STDDEV(score), 2) as standard_deviation,
    COUNT(*) AS total_inspections
FROM inspections
GROUP BY facility_city
HAVING COUNT(*) >= 50
ORDER BY AVG(score) ASC
LIMIT 30;

-- Los Angeles is the most inspected city by a landslide (15x)
-- The Southeast LA & San Gabriel Valley cities aren't among the most inspected
-- Less inspections = lower standards? More issues arise between inspections?
SELECT 
    facility_city,
COUNT(*) AS total_inspections
FROM inspections
GROUP BY facility_city
ORDER BY total_inspections DESC
LIMIT 30;

-- Average score and violations per inspection (grouped by how many inspections each restaurant got)
-- Average violations per inspection and average score is roughly the same across different groups
-- Conclusion: The number of times a restaurant is inspected doesn't have a meaningful effect.
WITH restaurant_stats AS (
    SELECT
        i.facility_name,
        COUNT(DISTINCT i.serial_number) AS total_inspections,
        ROUND(AVG(i.score), 2) AS avg_score,
        ROUND(COUNT(v.violation_code)::NUMERIC / COUNT(DISTINCT i.serial_number), 2) AS violations_per_inspection
    FROM inspections i
    JOIN violations v ON v.serial_number = i.serial_number
    GROUP BY i.facility_name
)
SELECT
    CASE 
        WHEN total_inspections = 1 THEN '1 inspection'
        WHEN total_inspections = 2 THEN '2 inspections'
        WHEN total_inspections = 3 THEN '3 inspections'
        When total_inspections = 4 THEN '4 inspections'
        ELSE '5+ inspections'
    END AS inspection_groups,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(violations_per_inspection), 2) AS avg_violations_per_inspection,
    ROUND(AVG(avg_score), 2) AS avg_score
FROM restaurant_stats
GROUP BY inspection_groups
ORDER BY MIN(total_inspections);


-- Calculating the violations per inspection for each city
-- More violations per inspection directly explains lower scores
-- Lower scores = higher violation severity on average (violations worth more points)
-- Conclusion: Southeast LA and San Gabriel Valley restaurants have more violations per visit AND higher violation severity ON AVERAGE
WITH city_scores AS (
    SELECT 
        facility_city, 
        ROUND(AVG(score), 2) AS avg_score, 
        COUNT(*) AS total_inspections 
    FROM inspections
    GROUP BY facility_city
    HAVING COUNT(*) >= 50
), city_violations AS (
    SELECT 
        i.facility_city, 
        COUNT(*) AS total_violations,
        ROUND(AVG(v.points), 2) AS avg_violation_severity
    FROM violations v
    JOIN inspections i on i.serial_number = v.serial_number
    GROUP BY i.facility_city
)
SELECT 
    cs.facility_city, 
    cs.avg_score,
    cv.avg_violation_severity, 
    ROUND((cv.total_violations::NUMERIC / cs.total_inspections), 2) AS violation_per_inspection
FROM city_scores cs
JOIN city_violations cv on cv.facility_city = cs.facility_city
ORDER BY cs.avg_score ASC;


-- Grade distribution by city (min 50 inspections)
-- Southeast LA and San Gabriel Valley cities cluster at the bottom A rates
-- The differentiation between cities is almost entirely A vs B rate 
-- C rates are uniform (1-4%) across all average scores
-- San Marino anomaly: 87% A rate despite being one of LA's wealthiest cities, though small sample (68 inspections)
-- Newhall, Agoura Hills, Stevenson Ranch, Porter Ranch all have 100% A rate (smaller wealthy suburbs)
-- Lower scoring cities are not failing miserably, but just have a bit more mediocre restaurants
SELECT 
    facility_city,
    COUNT(*) AS total_inspections,
    ROUND(AVG(CASE WHEN GRADE = 'A' THEN 1 ELSE 0 END), 2) AS A_rate,
    ROUND(AVG(CASE WHEN GRADE = 'B' THEN 1 ELSE 0 END), 2) AS B_rate,
    ROUND(AVG(CASE WHEN GRADE = 'C' THEN 1 ELSE 0 END), 2) AS C_rate
FROM inspections
GROUP BY facility_city
HAVING COUNT(*) >= 50
ORDER BY AVG(score);

-- Most common violations bringing low-scoring cities down (50+ inspections)
-- Top violations are consistent across all low scoring cities
-- 1) F044 -- Floors, walls, or ceilings not properly built, maintained, or clean
-- 2) F035 -- Equipment/utensils not approved, installed, clean, or in good repair
-- 3) F033 -- Non food contact surfaces unclean or in poor repair (shelves, handles, refrigerators)
-- 4) F040 -- Plumbing not in good repair or missing proper backflow devices
-- 5) F037 -- Inadequate ventilation, lighting, or improper designated area use
-- Key insight: top violations are facility maintenance issues

SELECT
    v.violation_code,
    COUNT(*) AS total_frequency,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT i.facility_city), 1) AS avg_per_city
FROM inspections i
INNER JOIN violations v ON v.serial_number = i.serial_number
WHERE i.facility_city IN (
    SELECT facility_city
    FROM inspections
    GROUP BY facility_city
    HAVING AVG(score) < 93 AND COUNT(*) >= 50
)
GROUP BY v.violation_code
ORDER BY total_frequency DESC;

-- GEOGRAPHIC ANALYSIS SUMMARY
-- Southeast LA and San Gabriel Valley consistently underperform in avg score, grade, and violations per inspection
-- Every city has both exceptional (99-100) and very poor (58-70) scoring restaurants 
-- Bad cities simply have more mediocre restaurants pulling their average down, reflected in higher B rates not C rates
-- A B grade still means a restaurant failed to meet health standards, in food service that's still not acceptable
-- The root cause of lower scores is poor facility maintenance (floors, equipment, plumbing) not food safety failures
-- Increased inspections don't improve outcomes, violation rates stay flat regardless of how often a restaurant is visited