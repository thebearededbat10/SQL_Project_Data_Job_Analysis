-- UNION Example
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs
UNION
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs
UNION
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;

-- UNION ALL Example
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs
UNION ALL
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs
UNION ALL
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs;


-- UNION Problem 1
WITH quarter_one AS(
    SELECT
        job_id,
        job_posted_date,
        salary_year_avg
    FROM 
        january_jobs
    UNION ALL
    SELECT
        job_id,
        job_posted_date,
        salary_year_avg
    FROM
        february_jobs
    UNION ALL
    SELECT
        job_id,
        job_posted_date,
        salary_year_avg
    FROM
        march_jobs
)
    
SELECT
    qo.job_id,
    sd.skills,
    sd.type AS skill_type,
    SUM(qo.salary_year_avg) AS qtr_salary
FROM
    quarter_one qo LEFT JOIN skills_job_dim sjd
    ON qo.job_id = sjd.job_id JOIN
    skills_dim sd
    ON sjd.skill_id = sd.skill_id
GROUP BY
    qo.job_id, sd.skills, skill_type
HAVING
    SUM(qo.salary_year_avg) > 70000;
    

-- UNION Problem
WITH quarter_one AS(
    SELECT *
    FROM 
        january_jobs
    UNION ALL
    SELECT *
    FROM
        february_jobs
    UNION ALL
    SELECT *
    FROM
        march_jobs
)
    
SELECT
    qo.job_title_short,
    qo.job_location,
    qo.job_via,
    qo.job_id,
    qo.job_posted_date::DATE,
    SUM(qo.salary_year_avg) AS qtr_salary
FROM
    quarter_one qo
GROUP BY
    qo.job_title_short, qo.job_location, qo.job_via, qo.job_id, qo.job_posted_date::DATE
HAVING
    SUM(qo.salary_year_avg) > 70000;

-- UNION Problem with Subquery

SELECT
    quarter_one.job_title_short,
    quarter_one.job_location,
    quarter_one.job_via,
    quarter_one.job_id,
    quarter_one.job_posted_date::DATE,
    quarter_one.salary_year_avg
FROM (
    SELECT *
    FROM 
        january_jobs
    UNION ALL
    SELECT *
    FROM
        february_jobs
    UNION ALL
    SELECT *
    FROM
        march_jobs
) AS quarter_one
WHERE 
    quarter_one.salary_year_avg > 70000 AND 
    quarter_one.job_title_short = 'Data Analyst'
ORDER BY
    quarter_one.salary_year_avg DESC;