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