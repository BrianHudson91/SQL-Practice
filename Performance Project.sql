/* 

Today I will be creating a new database, tables, data sets, then formatting and modifying data.

*/

--1. Create Database

Create Database test_db
USE test_db
GO

--2. Creating new tables

Create table test1
(
ID int IDENTITY(1,1) NOT NULL Primary Key,
lastname varchar(50) UNIQUE ,
firstname varchar(50),
jobtitle varchar(50),
company varchar(50),
salary int,
sucessfull_shipments varchar(50),  --wrong data type
pe_rating varchar(50)              --Wrong data type
);


--3.  Create our dataset for our table


INSERT INTO test1 VALUES
('torres', 'jose', 'salesman','RooferSelect', 42000, 187, 4), 
('Piccard', 'David', 'salesman','RooferSelect', 39000, 106, 3), 
('Chesla', 'Randall', 'salesman','RooferSelect', 43350, 195, 5), 
('Hanson', 'Barbara', 'salesman','RooferSelect', 55000, 224, 5), 
('Mackey', 'Tim', 'salesman','RooferSelect', 34000, 87, 3), 
('Scott', 'Micheal', 'salesman','RooferSelect', 42000, 187, 4), 
('Beasley', 'Pam', 'manager','RooferSelect', 67000, 56, 4), 
('Schrute', 'Tom', 'manager','RooferSelect', 62000, 15, 3), 
('Thailkill', 'Tyler', 'manager','RooferSelect', 71000, 75, 5)
;

--3.a Create our Second table w/data set for the competitor company


Create table test2
(
ID int IDENTITY(1,1) NOT NULL Primary Key,   --Both tables start at value 1- that is a problem
lastname varchar(50) UNIQUE ,
firstname varchar(50),
jobtitle varchar(50),
company varchar(50),
salary int,
sucessfull_shipments varchar(50),			--Wrong data type
pe_rating varchar(50)					    --Wrong data type
);

INSERT INTO test2 VALUES
('Tarmak', 'John', 'salesman','ContractCore', 45000, 205, 4), 
('Sarcely', 'Angel', 'salesman','ContractCore', 43000, 168, 3),  
('Tarlin', 'Paul', 'salesman','ContractCore', 52000, 160, 4), 
('Hudson', 'Mike', 'manager','ContractCore', 82000, 356, 5),  
('Rivera', 'Yartiza', 'manager','ContractCore', 67000, 284, 4); 


/*

 4. Formatting and Modifying


 Since there are duplicate IDs and we want to combine the data permanently, we will insert 
 the data from the second into the first, excluding IDs since it will auto populate
 
*/

INSERT INTO test1 (lastname,firstname,jobtitle,company,salary,sucessfull_shipments,pe_rating)
SELECT lastname, firstname, jobtitle, company, salary, sucessfull_shipments, pe_rating
FROM test2;



--Modify the name_case for continuity across the rows

UPDATE test1
SET lastname = 'Torres', firstname = 'Jose'
WHERE ID = 1



/* 
There are two ways we can go about creating the salary performence data:
1. If you don't want a permanent table, we can create a CTE with a Join to show the new salary increase with the partition data - much less code
2. If we want a p/table, we can create t/tables and join them to create a final product.

Below is the the CTE method with a Join statement

*/
--1.

With avg_shipments (ID, successfull_shipments, avg_shipments_by_company) as
		(SELECT id, sucessfull_shipments, AVG(cast(sucessfull_shipments AS INT)) 
		     OVER (Partition BY company) as avg_shipments_by_company from test1)

SELECT t.ID, t.company, t.lastname, t.firstname, t.jobtitle, t.sucessfull_shipments, av.avg_shipments_by_company, t.pe_rating, t.salary,
CASE
	WHEN sucessfull_shipments > av.avg_shipments_by_company AND pe_rating > 4
		THEN salary + (Salary * .05)
	WHEN sucessfull_shipments > av.avg_shipments_by_company AND pe_rating > 3
		THEN salary + (Salary * .04)
	ELSE salary + (Salary * .02)
END AS 'new_salary'
FROM test1 t
JOIN avg_shipments av ON
	t.id = av.id
ORDER BY t.company, t.lastname
	




--2. Below is the t/table(s) method before joining to create a final table

/*

Categorize by performance to find salary increase
and create a t/table so we may use the partition data

*/


SELECT ID, company, lastname, firstname, sucessfull_shipments,
	AVG(cast(sucessfull_shipments AS INT)) OVER (Partition BY company) AS avg_shipments_by_company, salary, pe_rating
INTO #temp_pe
FROM test1

/* 

 We will now create another t/table with new salary adjustments by using
 the partition data set in a case statement to create our final table.
 

*/

SELECT ID, company, lastname, firstname, sucessfull_shipments, avg_shipments_by_company, pe_rating, salary,
CASE
	WHEN sucessfull_shipments > avg_shipments_by_company AND pe_rating > 4
		THEN salary + (Salary * .05)
	WHEN sucessfull_shipments > avg_shipments_by_company AND pe_rating > 3
		THEN salary + (Salary * .04)
	ELSE salary + (Salary * .02)
END AS 'new_salary'
INTO #combined_employees
FROM #temp_pe


DROP TABLE #temp_pe;   ---We are removing the earlier temp table as it is no longer needed


/*

We are now creating our final table.

*/

Select co.ID, co.company, co.lastname, co.firstname, test1.jobtitle, co.sucessfull_shipments, co.pe_rating, co.salary, co.new_salary
INTO Final_table
from #combined_employees co
JOIN test1	
	ON co.id = test1.ID;

DROP Table #combined_employees; --remove last temp table, no longer needed


--Completed final table
Select *
FROM Final_table
Order by 1;




