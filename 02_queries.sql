Task 2.1
+++++++++++++++++++++++++++++++
select count(*) from appointments;
insert into appointments (appointment_id) values ('A0001');

DataBase: sqlite
Error: SQLITE_CONSTRAINT_NOTNULL: sqlite3 result code 1299: NOT NULL constraint failed: appointments.patient_id
Response language en



Task 2.2
+++++++++++++++++++++++++++++++
select clinic_name, city, count(appointment_id) appointments,
count(no_show), ROUND(100.0 * SUM(no_show) / COUNT(*), 1) no_show_pct
FROM
appointments a, clinics c
where a.clinic_id=c.clinic_id
group by clinic_name, city
having count(appointment_id) >=95
order by no_show_pct desc



Task 2.3
+++++++++++++++++++++++++++++++
select 
case when lead_days >= 1 and lead_days<= 7 then '1-7' 
 when lead_days >= 8 and lead_days<= 14 then '8-14' 
 when lead_days >= 15 and lead_days<= 30 then '15-30' 
 when lead_days >= 31 then '30+' 
end leaddays, count(appointment_id) appointments,sum(no_show) no_show,
ROUND(100.0 * SUM(no_show) / COUNT(*), 1) no_show_pct 
FROM
appointments a, clinics c
where a.clinic_id=c.clinic_id
group by leaddays
order by min(leaddays) 


Task 2.4
+++++++++++++++++++++++++++++++++++
with monthly AS
(select SUBSTR(appt_date,1,7) month,count(appointment_id),
 ROUND(100.0 * SUM(no_show) / COUNT(*), 1) no_show_pct  
 from appointments
group by month
)
select *,ROUND(
        no_show_pct
        - LAG(no_show_pct) OVER (ORDER BY month),
        2
    ) AS pct_point_change from monthly




Task 2.5
+++++++++++++++++++++++++++++++++++
with clinic_rates AS
(select c.clinic_name,city,ROUND(100.0 * SUM(no_show) / COUNT(*), 1) no_show_pct 
from 
appointments a, clinics c
where a.clinic_id=c.clinic_id
 group by clinic_name,city
)
select (SELECT AVG(no_show_pct) FROM clinic_rates) 'overall rate',
*,
RANK() OVER (
        PARTITION BY city
        ORDER BY no_show_pct DESC
    ) AS rank_in_city,
     CASE
        WHEN no_show_pct > (
            SELECT AVG(no_show_pct)
            FROM clinic_rates
        ) THEN 'above'
        WHEN no_show_pct < (
            SELECT AVG(no_show_pct)
            FROM clinic_rates
        ) THEN 'below'
        ELSE 'equal'
    END AS vs_overall
    from clinic_rates
    ORDER BY city, rank_in_city;