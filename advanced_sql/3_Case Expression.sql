-- Case Expression Example
SELECT
    COUNT(job_id) AS job_posted_count,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY location_category;

-- Case Expression Problem
SELECT
    (salary_year_avg) AS max_salary
FROM
    job_postings_fact;

SELECT
    COUNT(job_id) AS job_posted_count,
    CASE
        WHEN salary_year_avg = NULL THEN 'Null'
        WHEN salary_year_avg BETWEEN 15000 AND 100000 THEN 'Low'
        WHEN salary_year_avg BETWEEN 100000 AND 300000 THEN 'Standard'
        ELSE 'High'
    END AS salary_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY salary_category;