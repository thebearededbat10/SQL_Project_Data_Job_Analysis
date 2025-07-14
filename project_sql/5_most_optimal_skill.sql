/*
Question: What are the most optimal skills to learn ?
- Identify skills in high demand and associated with high average salary.
- Concentrates on remote positions with specified salaries.
- WHY? Targets skills that offer job security (high demand) and high pay, offering strategic insights for career development in data analyst positions.
*/

WITH demand_skills AS(
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM
        job_postings_fact INNER JOIN skills_job_dim
        ON job_postings_fact.job_id = skills_job_dim.job_id
        INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL AND
        job_work_from_home = True
    GROUP BY
        skills_dim.skill_id
), top_paying_skill AS(
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary
    FROM
        job_postings_fact INNER JOIN skills_job_dim
        ON job_postings_fact.job_id = skills_job_dim.job_id
        INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_postings_fact.job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL AND
        job_work_from_home = True
    GROUP BY 
        skills_dim.skill_id
)

SELECT 
    demand_skills.skill_id,
    top_paying_skill.skills,
    demand_skills.demand_count,
    top_paying_skill.avg_salary
FROM
    demand_skills JOIN top_paying_skill
    ON demand_skills.skill_id = top_paying_skill.skill_id
WHERE
    demand_skills.demand_count > 10
ORDER BY
    top_paying_skill.avg_salary DESC,
    demand_skills.demand_count DESC
LIMIT 25;

-- Rewritting the same above query more concisely:

SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary
FROM
    job_postings_fact INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = True
GROUP BY 
        skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
