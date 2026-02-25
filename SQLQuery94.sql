--Q1 for each doctor, count how many distinct patients they have treated


with CTE as (
select doctorID,count(*) [patients_treated] from
(select DoctorID,rank() over(partition by doctorid order by patientid) [rk] from patientvisits) p
group by doctorid
)

select a.doctorid,b.firstname + ' ' + b.lastname [doctorname],a.patients_treated from 
CTE a left join dim_doctor b on a.doctorid = b.doctorid
order by patients_treated desc

--Q2 show the revenue split by each payment method, along with total visits


with CTE as (
select paymentmethodid,count(*) [totalvisits],SUM(billamount) [revenue] from patientvisits
group by paymentmethodid
)

select a.paymentmethodid,b.paymentmethod,totalvisits,revenue from 
CTE a left join dim_paymentmethod b on a.paymentmethodid = b.paymentmethodid

--Q3 Categorize patients into age groups and calculate the avg bill amount for each age band 
--assume age at the time of visit based on visit date 


select agegroup,cast(AVG(billamount) as decimal(18,2))[avgbillAmt] from 
(select *,
case
	when age < 18 then '<18'
	when age between 18 and 35 then '18-35'
	when age between 35 and 55 then '35-55'
	else '>55'
end [agegroup] from 
(select p.patientid,c.fullname,datediff(year,c.dob,p.dischargedate) [age],p.billamount from patientvisits p left join dim_patient_clean c 
on p.patientid = c.patientid) r) z
group by agegroup

--Q4 find total revenue and no of visits for each department


select a.departmentid,c.departmentname,a.no_of_visits,a.revenue from 
(select departmentid,count(*) [no_of_visits],SUM(billamount) [Revenue] from patientvisits
group by departmentid) a left join dim_department_clean c on a.departmentid = c.departmentid
order by no_of_visits desc

--Q5 rank departments based on their total revenue within each department category



select a.departmentID,b.departmentname,a.revenue,rank() over(order by revenue desc) [rk] from
(select departmentid,SUM(billamount) [revenue] from patientvisits
group by departmentid) a left join dim_department_clean b on a.departmentid = b.departmentid


--Q6 for each department, find the avg satisfaction score and avg wait time

select a.departmentid,b.departmentname,a.avg_satisfactionscore,a.avg_waittime from
(select departmentid,AVG(satisfactionscore) [avg_satisfactionscore],AVG(waittimeminutes) [avg_waittime]
from patientvisits
group by departmentid) a left join dim_department_clean b on a.departmentid = b.departmentid
order by avg_waittime desc

--Q7 Compare the total no of hospital visits on weekdays vs weekends

select visitday,count(*) [totalvisits] from
(select visitid,
case
	when datename(weekday,dischargedate) = 'saturday' then 'weekend'
	when datename(weekday,dischargedate) = 'sunday' then 'weekend'
	else 'weekday'
end as [visitday]		
from patientvisits) z
group by visitday	


--Q8 for each month, calculate total visits and running cumulative total of visits


select Monthname,countvisits,SUM(countvisits) over(order by month) as [cumulative_visits] from
(
select MONTH(dischargedate) [Month],datename(month,dischargedate) [Monthname],count(*) [countvisits] from patientvisits
group by month(dischargedate),datename(month,dischargedate)) p


--Q9 find the doctors with the highest avg satisfaction score (min 100 visits)


select b.firstname + ' ' + b.lastname as [doctorname],a.avgsatis_score,a.countvisits from
(select doctorid,AVG(satisfactionscore) [avgsatis_score],count(*) [countvisits] from patientvisits
group by doctorid
having count(*) >= 100) a left join dim_doctor b on a.doctorid = b.doctorid

--Q10 Identify the most commonly prescribed treatment for each diagnosis


with CTE as (
select diagnosisname,treatmentname,treatmentcount,rank() over(partition by diagnosisname order by treatmentcount desc) [rk]
from
(select d.DiagnosisName,t.TreatmentName,COUNT(*) [treatmentcount] from patientvisits p left join dim_diagnosis d on p.diagnosisid = d.diagnosisid left join dim_treatment t on
p.treatmentid = t.treatmentid
group by diagnosisname,treatmentname) z
)

select * from CTE where rk = 1


