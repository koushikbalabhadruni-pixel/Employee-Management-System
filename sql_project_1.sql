create database management_database;

use management_database;

select * from employee;
describe employee;
alter table employee modify FirstName varchar(100);

alter table employee modify FirstName varchar(50),modify LastName varchar(50),modify Gender varchar(10),
modify ContactAddress varchar(100),modify EmpEmail varchar(100),modify EmpPass varchar(50);

alter table employee add primary key (EmpID);
alter table employee modify column EmpID int auto_increment;

alter table employee add CONSTRAINT fk_employee_job FOREIGN KEY (JobID)
        REFERENCES JobDepartment(JobID)
        ON DELETE SET NULL
        ON UPDATE CASCADE;




describe jobdepartment;
select * from jobdepartment;
alter table jobdepartment modify JobDept varchar(100), modify Name varchar(50),modify SalaryRange varchar(100);
alter table jobdepartment add primary key(JobID);




describe leaves;
select * from leaves;
alter table leaves modify Date date;
alter table leaves add primary key(LeaveID);
alter table leaves add CONSTRAINT fk_leave_emp FOREIGN KEY (empID) REFERENCES Employee(empID)
        ON DELETE CASCADE ON UPDATE CASCADE;



describe payroll;
select * from payroll;
alter table payroll modify Date date; 
alter table payroll modify TotalAmount decimal(10,2);      
alter table payroll add primary key(PayrollID);
alter table payroll add CONSTRAINT fk_payroll_emp FOREIGN KEY (empID) REFERENCES Employee(empID)
        ON DELETE CASCADE ON UPDATE CASCADE;
alter table payroll add CONSTRAINT fk_payroll_job FOREIGN KEY (jobID) REFERENCES JobDepartment(jobID)
        ON DELETE CASCADE ON UPDATE CASCADE;
alter table payroll add CONSTRAINT fk_payroll_salary FOREIGN KEY (SalaryID) REFERENCES salary_bonus(SalaryID)
        ON DELETE CASCADE ON UPDATE CASCADE;
alter table payroll add CONSTRAINT fk_payroll_leave FOREIGN KEY (leaveID) REFERENCES Leaves(leaveID)
        ON DELETE SET NULL ON UPDATE CASCADE;

describe qualification;
select * from qualification;
alter table qualification modify Position varchar(100),modify Requirements varchar(100), modify Date_In date;
alter table qualification add primary key(QualID);
alter table qualification add CONSTRAINT fk_qualification_emp FOREIGN KEY (EmpID)
        REFERENCES Employee(empID)
        ON DELETE CASCADE
        ON UPDATE CASCADE;



describe salary_bonus;
select * from salary_bonus;
alter table salary_bonus modify Amount decimal(10,2),modify Annual decimal(10,2),modify Bonus decimal(10,2);
alter table salary_bonus add primary key(SalaryID);
alter table salary_bonus add  CONSTRAINT fk_salary_job FOREIGN KEY (jobID) REFERENCES JobDepartment(JobID)
        ON DELETE CASCADE ON UPDATE CASCADE;


-- Analysis Questions
-- 1. EMPLOYEE INSIGHTS
-- 1. How many unique employees are currently in the system?
select count(distinct empID) as unique_employees from employee;

-- 2. Which departments have the highest number of employees?
SELECT jd.jobdept AS Department_Name, COUNT(e.empID) AS Number_of_Employees FROM Employee e    
JOIN JobDepartment jd ON e.JobID = jd.JobID GROUP BY jd.jobdept ORDER BY Number_of_Employees DESC;

-- 3. What is the average salary per department?
 SELECT jd.jobdept AS Department,ROUND(AVG(sb.amount), 2) AS Average_Salary FROM JobDepartment jd JOIN 
    salary_bonus sb ON jd.JobID = sb.JobID GROUP BY jd.jobdept ORDER BY Average_Salary DESC;

-- 4. Who are the top 5 highest-paid employees?
SELECT e.empID,CONCAT(e.firstname, ' ', e.lastname) AS Employee_Name,jd.jobdept AS Department,jd.name AS Job_Title,
sb.amount AS Base_Salary,sb.bonus AS Bonus,(sb.amount + sb.bonus) AS Total_Pay FROM Employee e
JOIN JobDepartment jd ON e.JobID = jd.JobID JOIN salary_bonus sb ON jd.JobID = sb.JobID ORDER BY Total_Pay DESC LIMIT 5;


-- 5. What is the total salary expenditure across the company?
SELECT ROUND(SUM(sb.amount + sb.bonus), 2) AS Total_Salary_Expenditure
FROM Employee e JOIN salary_bonus sb ON e.JobID = sb.JobID;




-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- 1. How many different job roles exist in each department?
SELECT jobdept AS Department,COUNT(DISTINCT name) AS Total_Job_Roles
FROM JobDepartment GROUP BY jobdept ORDER BY Total_Job_Roles DESC;


-- 2. What is the average salary range per department?
SELECT jd.jobdept AS Department,ROUND(AVG(sb.amount), 2) AS Average_Salary FROM JobDepartment jd
JOIN salary_bonus sb  ON jd.JobID = sb.JobID  GROUP BY jd.jobdept ORDER BY Average_Salary DESC;


-- 3. Which job roles offer the highest salary?
SELECT jd.name AS Job_Role,jd.jobdept AS Department,sb.amount AS Base_Salary,sb.bonus AS Bonus,(sb.amount + sb.bonus) AS Total_Salary
FROM JobDepartment jd JOIN salary_bonus sb ON jd.JobID = sb.JobID ORDER BY Total_Salary DESC;

-- 4. Which departments have the highest total salary allocation?
SELECT jd.jobdept AS Department,ROUND(SUM(sb.amount + sb.bonus), 2) AS Total_Salary_Allocation FROM Employee e
JOIN JobDepartment jd ON e.JobID = jd.JobID
JOIN salary_bonus sb ON e.JobID = sb.JobID GROUP BY jd.jobdept ORDER BY Total_Salary_Allocation DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- 1. How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT EmpID) AS Employees_With_Qualification FROM qualification;

-- 2. Which positions require the most qualifications?
SELECT Position,COUNT(QualID) AS Number_of_Qualifications FROM qualification GROUP BY Position ORDER BY Number_of_Qualifications DESC;

-- 3. Which employees have the highest number of qualifications?
SELECT e.empID,CONCAT(e.FirstName, ' ', e.LastName) AS Employee_Name,COUNT(q.QualID) AS Number_of_Qualifications FROM Employee e
JOIN qualification q ON e.EmpID = q.EmpID GROUP BY e.empID, e.FirstName, e.LastName ORDER BY Number_of_Qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS

-- 1. Which year had the most employees taking leaves?
SELECT YEAR(Date) AS Leave_Year,COUNT(DISTINCT EmpID) AS Number_of_Employees
FROM leaves GROUP BY YEAR(Date) ORDER BY Number_of_Employees DESC LIMIT 1;

-- 2. What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept AS Department,ROUND(IFNULL(COUNT(l.LeaveID), 0) / COUNT(DISTINCT e.EmpID),2) AS Average_Leave_Days FROM Employee e
JOIN JobDepartment jd ON e.JobID = jd.JobID LEFT JOIN leaves l ON e.EmpID = l.EmpID
GROUP BY jd.jobdept ORDER BY Average_Leave_Days DESC;


-- 3. Which employees have taken the most leaves?
SELECT e.EmpID,CONCAT(e.FirstName, ' ', e.LastName) AS Employee_Name,COUNT(l.LeaveID) AS Total_Leaves FROM Employee e
LEFT JOIN leaves l ON e.EmpID = l.EmpID GROUP BY e.EmpID, e.FirstName, e.LastName ORDER BY Total_Leaves DESC;


-- 4. What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS Total_Leave_Days FROM leaves;

-- 5. How do leave days correlate with payroll amounts?
SELECT e.EmpID,CONCAT(e.FirstName, ' ', e.LastName) AS Employee_Name,COUNT(l.LeaveID) AS Total_Leave_Days,
SUM(sb.amount + sb.bonus) AS Total_Pay FROM Employee e LEFT JOIN leaves l ON e.EmpID = l.EmpID
JOIN salary_bonus sb ON e.JobID = sb.JobID GROUP BY e.EmpID, e.FirstName, e.LastName ORDER BY Total_Leave_Days DESC;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- 1. What is the total monthly payroll processed?
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month,ROUND(SUM(TotalAmount), 2) AS Total_Monthly_Payroll FROM Payroll
    GROUP BY DATE_FORMAT(Date, '%Y-%m') ORDER BY Month ASC;

-- 2. What is the average bonus given per department?
SELECT jd.JobDept AS Department,ROUND(AVG(sb.Bonus), 2) AS Average_Bonus FROM JobDepartment jd
JOIN Salary_Bonus sb ON jd.JobID = sb.JobID GROUP BY jd.JobDept ORDER BY Average_Bonus DESC;


-- 3. Which department receives the highest total bonuses?
SELECT jd.JobDept AS Department,ROUND(SUM(sb.Bonus), 2) AS Total_Bonuses FROM JobDepartment jd 
JOIN Salary_Bonus sb ON jd.JobID = sb.JobID GROUP BY jd.JobDept ORDER BY Total_Bonuses DESC LIMIT 1;

-- 4. What is the average value of total_amount after considering leave deductions?
SELECT ROUND(AVG(TotalAmount), 2) AS Average_Net_Payroll FROM Payroll;







