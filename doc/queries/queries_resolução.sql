-- Desafio de Projeto DIO: Processamento de dados  
-- Transformando Dados
-- 1. Verifique os cabeçalhos e tipos de dados
SELECT * FROM azure_company.department;
SELECT * FROM azure_company.dependent;
SELECT * FROM azure_company.dept_locations;
SELECT * FROM azure_company.employee;
SELECT * FROM azure_company.project;
SELECT * FROM azure_company.works_on;

-- 2. Modifique os valores monetários para o tipo double precision
UPDATE azure_company.employee
SET salary = salary::double precision;

-- 3. Verifique a existência dos nulos e análise sua remoção
SELECT *
FROM azure_company.employee
WHERE super_ssn IS NULL; -- Este provavelmente é o gerente

SELECT *
FROM azure_company.department AS dep
LEFT JOIN azure_company.employee AS emp
	ON dep.mgr_ssn = emp.ssn; -- Aqui identificamos que o super_ssn faltante é do gerente
	
UPDATE azure_company.employee
SET super_ssn = '888665555'
WHERE super_ssn IS NULL; -- Correção do super_ssn do gerente 
-- 4. Verifique o número de horas dos projetos
SELECT pname, pnumber, SUM(hours) hours_count
FROM azure_company.project AS pro
LEFT JOIN azure_company.works_on AS wor
	ON pro.pnumber = wor.pno
GROUP BY pname, pnumber
ORDER BY hours_count DESC;

-- 5. Separar colunas complexas 
-- 6. JOINS de department, employee e dpt_locations
WITH new_address AS 
(
SELECT
	ssn,
	SPLIT_PART(address, '-', 1) AS house_number,
	SPLIT_PART(address, '-', 2) AS street,
	SPLIT_PART(address, '-', 3) AS city,
	SPLIT_PART(address, '-', 4) AS state
FROM azure_company.employee
),

new_employee AS
(
SELECT 
	emp.fname,
	emp.lname,
	emp.ssn,
	new_address.house_number,
	new_address.street,
	new_address.city,
	new_address.state,
	emp.sex,
	emp.salary,
	emp.super_ssn,
	emp.dno
FROM azure_company.employee as emp
LEFT JOIN new_address
	ON emp.ssn = new_address.ssn
)

SELECT 
	new_employee.*,
	dep.dname AS department_name,
	dep.mgr_ssn
INTO temp_tables.azure_employee
FROM new_employee
LEFT JOIN azure_company.department as dep
	ON new_employee.dno = dep.dnumber

-- Criação de azure_company.employee_new
SELECT
	emp.ssn,
	emp.fname || ' ' || emp.lname AS full_name,
	CASE
		WHEN emp.city = 'Houston' AND emp.department_name = 'Research' THEN 'Houston Research'
		WHEN emp.city = 'Houston' AND emp.department_name = 'Headquarters' THEN 'Houston Headquarters'
		WHEN emp.city = 'Bellaire' AND emp.department_name = 'Research' THEN 'Bellaire Research'
		WHEN emp.department_name = 'Administration' THEN 'Stafford Administration'
		ELSE 'Sugarland Research' END AS dept_locname,
	emp.sex,
	CASE 
		WHEN emp.super_ssn = '888665555' THEN 'James Borg'
		WHEN emp.super_ssn = '987654321' THEN 'Jennifer Wallace'
		WHEN emp.super_ssn = '333445555' THEN 'Franklin Wong'
		END AS mgr_name,
	emp.city,
	emp.state,
	emp.salary
INTO azure_company.employee_new
FROM temp_tables.azure_employee AS emp

-- Correção de City e State 
SELECT * FROM azure_company.employee_new
SELECT * FROM temp_tables.azure_employee

UPDATE azure_company.employee_new
SET city = 'Oak Humble'
WHERE city = 'Oak'

UPDATE azure_company.employee_new
SET state = 'TX'
WHERE state = 'Humble'

-- 7. Quantos colaboradores existem por gerente
SELECT 
	mgr_name,
	COUNT(ssn) AS employee_count
FROM azure_company.employee_new
GROUP BY mgr_name
ORDER BY employee_count DESC

SELECT * FROM azure_company.employee_new