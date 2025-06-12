create database SQL_DB;
use SQL_DB;

-- Table 1: Job Department

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from employee;
select * from jobdepartment;
select * from payroll;
select * from salarybonus;
select * from qualification;
select * from leaves ;

-- 1. EMPLOYEE INSIGHTS
-- a). How many unique employees are currently in the system?
select distinct count(concat(firstname,lastname)) from employee ;

-- b). Which departments have the highest number of employees? 
select count(E1.firstname) as 'Count' from employee E1 left join jobdepartment D1 
on E1.job_id = D1.job_id group by jobdept;

-- c).  What is the average salary per department?
select D1.jobdept as 'Department' ,avg(total_amount) as 'AVG-SALARY' from payroll P1 left join jobdepartment D1 on 
D1.job_id = P1.job_id group by jobdept;

-- d).  Who are the top 5 highest-paid employees?
select P1.total_amount as Salary , concat_ws(' ',firstname,lastname) as 'Employee Name' from employee E1 inner join payroll P1 
on E1.emp_id = P1.emp_id order by P1.total_amount desc limit 5 ;

-- e). What is the total salary expenditure across the company?
select sum(total_amount) as 'Total salary expenditure' from payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- a)  How many different job roles exist in each department?
select distinct name from jobdepartment group by name ;

--  b) What is the average salary range per department?
select jobdept as department ,avg(
(replace(substring_index(salaryrange,'-',1),'$',"")+replace(substring_index(salaryrange,'-',-1),'$','')) /2) 
 as avg  from jobdepartment group by jobdept order by jobdept;

-- c) Which job roles offer the highest salary?
select name as "Role" , max(cast(replace(substring_index(salaryrange,'-',-1),'$','') as unsigned)) as Highestsalary 
from jobdepartment group by name order by highestsalary Desc limit 1;

-- d) Which departments have the highest total salary allocation?
select D1.jobdept as Department , Sum(S1.annual) as 'total salary allocation' from jobdepartment D1 join salarybonus S1 
on D1.job_id = S1.job_id group by D1.jobdept order by 'total salary allocation' limit 1;

--  3. QUALIFICATION AND SKILLS ANALYSIS
-- a) How many employees have at least one qualification listed?
select count(emp_id) as "employees" from qualification where substring(requirements,1,6) in ('B.tech','M.tech');

-- b) Which positions require the most qualifications?
select position, requirements
from qualification
order by
  case
    when requirements like '%chartered accountant%' then 1
    when requirements like '%llb%' then 2
    when requirements like '%m.sc%' or requirements like '%m.com%' then 3
    when requirements like '%mba%' then 4
    else 5
  end 
  limit 5;

--  4. LEAVE AND ABSENCE PATTERNS
-- a) Which year had the most employees taking leaves?
select year(date) from leaves group by year(date) ;

-- b) What is the average number of leave days taken by its employees per department?
select jd.jobdept ,count(l.date) as leave_days from employee e
join JobDepartment as jd on e.job_ID=jd.job_ID
join leaves as l on e.emp_ID=l.emp_ID  group by jd.jobdept ;

-- c) Which employees have taken the most leaves?
select E1.firstname , count(L1.date) from employee E1 right join leaves L1 on E1.emp_id = L1.emp_id group by E1.firstname, L1.date;

-- d) What is the total number of leave days taken company-wide?
select count(L1.leave_id) as TotalLeaves  from leaves L1 join  employee E1  on  L1.emp_id = E1.emp_id  
join jobdepartment D1 on E1.job_id = D1.job_id;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- a) What is the total monthly payroll processed
select sum(total_amount) as TotalProcessedPayroll from payroll;

-- b) What is the average bonus given per department?
select avg(S1.bonus) ,D1.jobdept from jobdepartment D1 join salarybonus S1 on D1.job_id = S1.job_id group by D1.jobdept;

-- c) Which department receives the highest total bonuses?
select  max(E1.bonus),D1.jobdept as Departments  from jobdepartment D1 right join salarybonus E1 on 
D1.job_id = E1.job_id group by D1.jobdept order by max(E1.bonus) desc limit 1; 

-- d) What is the average net salary after all deductions?
select avg(total_amount) as 'Average net Salary' from payroll;

-- 6. EMPLOYEE PERFORMANCE AND GROWTH
-- Which year had the highest number of employee promotions?
select 
    year(date_in) as promotion_year, 
    count(*) as total_promotions
from qualification group by promotion_year order by total_promotions desc
limit 5;

