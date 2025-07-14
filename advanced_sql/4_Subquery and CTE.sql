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