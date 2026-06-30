-- Violation Analysis

-- Most common violations overall:
-- Same common violations as low scoring cities (mostly maintenece such as walls, plumbing, etc)
SELECT 
    violation_code,
    COUNT(*) AS frequency
FROM violations
GROUP BY violation_code
ORDER BY frequency DESC;


-- Most severe violations by average points (min 10 occurrences)
-- High severity (2-4+ pts): F007 temp control, F014 food contact surfaces, F023, F006 handwashing  (food safety violations)
-- Low severity (1 pt): F044, F033, F035 the most frequent violations are low severity maintenance issues
-- Scores are dragged down by volume of minor violations, not severity
-- F049, F050, F051, F151, F152 show 0 points -- these are administrative codes (impoundments, permit suspensions)
-- 423,336 total violation records across the dataset
SELECT
    violation_code,
    ROUND(AVG(points), 2) AS average_points,
    COUNT(*) as frequency
FROM violations
GROUP BY violation_code
HAVING COUNT(*) >= 10
ORDER by average_points DESC;

SELECT COUNT(*) FROM violations;

-- Violations associated with low scores
-- When a specific violation is present, what is the average score of an inspection?
-- Violations split into two clear tiers: maintenance codes (F044, F033, F035) appear most often but barely affect scores (92-94 avg), while food safety and administrative codes (F007, F014, F054) appear less but tank scores (78-90 avg)
-- Maintenance violations hurt through volume, food safety violations hurt through severity

SELECT
    v.violation_code,
    ROUND(AVG(i.score), 2) AS average_score,
    COUNT(*) AS frequency
FROM violations v
LEFT JOIN inspections i ON i.serial_number = v.serial_number
GROUP BY v.violation_code
HAVING COUNT(*) >= 10
ORDER BY average_score DESC;


-- Which violations often occur together?
-- Maintenance violations (F033, F035, F044, F040) dominate the top co-occurring pairs
-- If a restaurant gets one maintenance violation, they almost certainly have others
SELECT 
    v1.violation_code AS violation_1,
    v2.violation_code AS violation_2,
    COUNT(*) AS co_occurrences
FROM violations v1
JOIN violations v2 ON v1.serial_number = v2.serial_number
    AND v1.violation_code < v2.violation_code
GROUP BY v1.violation_code, v2.violation_code
ORDER BY co_occurrences DESC
LIMIT 20;
