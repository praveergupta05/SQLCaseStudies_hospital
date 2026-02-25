select * from dim_department
select * from dim_patient

--data cleaning dim_patient table

create table dim_patient_clean (
  PatientID varchar(20) PRIMARY KEY,
  FullName varchar(50),
  Gender varchar(10),
  DOB date,
  City varchar(150),
  state varchar(150),
  country varchar(150)
)
drop table dim_patient_clean

insert into dim_patient_clean (patientid,FullName,Gender,DOB,City,state,country)
select 
p.patientid,upper(left(ltrim(rtrim(p.firstname)),1)) + 
lower(substring(ltrim(rtrim(p.firstname)),2,len(ltrim(rtrim(p.firstname))))) + ' ' + 
upper(left(ltrim(rtrim(p.lastname)),1)) + 
lower(substring(ltrim(rtrim(p.lastname)),2,len(ltrim(rtrim(p.lastname)))))
as fullname,
case
	when p.gender = 'M' then 'Male'
	when p.gender = 'F' then 'Female'
	else p.gender
end as Gender,
p.dob,
parsename(replace(p.citystatecountry,',','.'),3) as city,
parsename(replace(p.citystatecountry,',','.'),2) as state,
parsename(replace(p.citystatecountry,',','.'),1) as country
from dim_patient p
where p.firstname is not  null

select * from dim_patient_clean

--data cleaning dim_department table

select * from dim_department

CREATE TABLE Dim_Department_clean (
  DepartmentID varchar(20) PRIMARY KEY,
  DepartmentName varchar(100),
  DepartmentCategory varchar(100)
);

insert into Dim_Department_clean (DepartmentID,DepartmentName,DepartmentCategory)
select d.departmentid,d.specialization as departmentname,d.departmentcategory
from dim_department d
where d.departmentcategory is not null

select * from dim_department_clean

--data cleaning patient visits table

select * from patientvisits_2020_2021

CREATE TABLE PatientVisits (
  VisitID varchar(20) PRIMARY KEY,
  PatientID varchar(20),
  DoctorID varchar(20),
  DepartmentID varchar(20),
  DiagnosisID varchar(20),
  TreatmentID varchar(20),
  PaymentMethodID varchar(20),
  VisitDate date,
  VisitTime time,
  DischargeDate date,
  BillAmount decimal(18,2),
  InsuranceAmount decimal(18,2),
  SatisfactionScore integer,
  WaitTimeMinutes integer,
FOREIGN KEY (PatientID) REFERENCES Dim_Patient_clean(PatientID),
FOREIGN KEY (DoctorID) REFERENCES Dim_Doctor(DoctorID),
FOREIGN KEY (DepartmentID) REFERENCES Dim_Department_clean(DepartmentID),
FOREIGN KEY (DiagnosisID) REFERENCES Dim_Diagnosis(DiagnosisID),
FOREIGN KEY (TreatmentID) REFERENCES Dim_Treatment(TreatmentID),
FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod(PaymentMethodID)
);

insert into patientvisits (
VisitID,PatientID,DoctorID,DepartmentID,DiagnosisID,TreatmentID,PaymentMethodID,VisitTime,DischargeDate,
BillAmount,InsuranceAmount,SatisfactionScore,WaitTimeMinutes
)

select
VisitID,PatientID,DoctorID,DepartmentID,DiagnosisID,TreatmentID,PaymentMethodID,VisitTime,DischargeDate,
BillAmount,InsuranceAmount,SatisfactionScore,WaitTimeMinutes from PatientVisits_2020_2021

union all

select
VisitID,PatientID,DoctorID,DepartmentID,DiagnosisID,TreatmentID,PaymentMethodID,VisitTime,DischargeDate,
BillAmount,InsuranceAmount,SatisfactionScore,WaitTimeMinutes from PatientVisits_2022_2023

union all

select
VisitID,PatientID,DoctorID,DepartmentID,DiagnosisID,TreatmentID,PaymentMethodID,VisitTime,DischargeDate,
BillAmount,InsuranceAmount,SatisfactionScore,WaitTimeMinutes from PatientVisits_2024

union all

select
VisitID,PatientID,DoctorID,DepartmentID,DiagnosisID,TreatmentID,PaymentMethodID,VisitTime,DischargeDate,
BillAmount,InsuranceAmount,SatisfactionScore,WaitTimeMinutes from PatientVisits_2025

	





	