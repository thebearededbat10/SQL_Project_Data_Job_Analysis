-- Date Function Example
SELECT 
    COUNT(job_id) AS job_posted_count,
    DATE_TRUNC('month', job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EDT') AS job_posted_month
FROM 
    job_postings_fact
WHERE 
    job_posted_date >= '2023-01-01' AND job_posted_date < '2024-01-01'
GROUP BY 
    job_posted_month
ORDER BY 
    job_posted_month;

-- Date Function Porblem
SELECT 
    c.name AS company_name,
    jpf.job_health_insurance,
    EXTRACT(YEAR FROM jpf.job_posted_date) AS job_posted_year,
    EXTRACT(QUARTER FROM jpf.job_posted_date) AS job_posted_quarter
FROM 
    job_postings_fact jpf JOIN company_dim c
    ON jpf.company_id = c.company_id
WHERE jpf.job_health_insurance = 'TRUE'
GROUP BY company_name
HAVING job_posted_year = 2023;

-- Date Function Problem
SELECT 
  c.name AS company_name,
  COUNT(jpf.job_health_insurance) AS jobs_with_insurance,
  EXTRACT(YEAR FROM jpf.job_posted_date) AS job_posted_year,
  EXTRACT(QUARTER FROM jpf.job_posted_date) AS job_posted_quarter
FROM 
  job_postings_fact jpf
JOIN 
  company_dim c
  ON jpf.company_id = c.company_id
WHERE 
  jpf.job_health_insurance = 'TRUE'
  AND EXTRACT(YEAR FROM jpf.job_posted_date) = 2023
  AND EXTRACT(QUARTER FROM jpf.job_posted_date) = 2
GROUP BY 
  c.name,
  job_posted_year,
  job_posted_quarter
ORDER BY 
  c.name,
  job_posted_year,
  job_posted_quarter;


-- Creating Tables for firsdt three months of the year
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

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

-- Subquery Example
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

-- CTE Example
WITH january_jobs AS(
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)

SELECT *
FROM january_jobs;


-- Subqueries Problem
SELECT
    jpf.company_id,
    c.name,
    jpf.job_no_degree_mention
FROM
    job_postings_fact jpf JOIN company_dim c
    ON jpf.company_id = c.company_id
WHERE
    jpf.job_no_degree_mention = true;

SELECT
    name AS company_name,
    company_id
FROM
    company_dim
WHERE
    company_id IN(
        SELECT company_id
        FROM job_postings_fact
        WHERE job_no_degree_mention = true
    );

-- CTE with Join Problem
WITH job_postings_per_company_id AS(
    SELECT 
        COUNT(job_id) AS job_count,
        company_id
    FROM job_postings_fact
    GROUP BY company_id
)

SELECT 
    name AS company_name,
    jppci.job_count
FROM
    company_dim c JOIN job_postings_per_company_id jppci
    ON c.company_id = jppci.company_id
ORDER BY 
    jppci.job_count DESC;



-- CTE with JOINs Problem
WITH highest_skill_id AS(
    SELECT 
    skill_id,
    COUNT(job_id) AS job_count
FROM 
    skills_job_dim
GROUP BY
    skill_id
ORDER BY
    skill_id
LIMIT 5
)

SELECT 
    s.skills,
    hsi.job_count
FROM
    skills_dim s JOIN highest_skill_id hsi
    ON s.skill_id = hsi.skill_id;

-- CTE with Case Expression Problem
WITH jobs_per_company AS(
    SELECT
        COUNT(job_id) AS job_postings_count,
        company_id
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT
    c.name,
    jpc.size_category
FROM
    company_dim c JOIN (
            SELECT
                CASE
                    WHEN job_postings_count < 10 THEN 'Small'
                    WHEN job_postings_count BETWEEN 10 and 50 THEN 'Medium'
                    ELSE 'Large'
                END AS size_category,
                company_id
            FROM jobs_per_company
    )jpc
    ON c.company_id = jpc.company_id;


-- CTE Problem 
WITH remote_jobs AS(
    SELECT
        COUNT(*) AS skill_count,
        sjd.skill_id
    FROM
        job_postings_fact jpf JOIN skills_job_dim sjd
        ON jpf.job_id = sjd.job_id
    WHERE
        jpf.job_work_from_home = True AND jpf.job_title_short = 'Data Analyst'
    GROUP BY
        sjd.skill_id
)

SELECT
    rj.skill_id,
    sd.skills,
    rj.skill_count
FROM
    remote_jobs rj JOIN skills_dim sd
    ON rj.skill_id = sd.skill_id
ORDER BY
    rj.skill_count DESC
LIMIT 5;

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


















