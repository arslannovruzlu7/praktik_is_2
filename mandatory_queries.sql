-- ============================================================
-- VBIS-Chapter3-SQL : Mandatory queries
-- Exercises: 3.11, 3.15, 3.24, 3.25
-- DBMS: PostgreSQL
-- Universitet sxemi (3.11, 3.24, 3.25) və Bank sxemi (3.15)
-- ============================================================


-- ============================================================
-- Exercise 3.11 (University schema)
-- ============================================================

-- Exercise 3.11(a)
-- Ən azı bir "Comp. Sci." kursu almış tələbələrin ID və adı (təkrarsız)
SELECT DISTINCT s.ID, s.name
FROM student s
JOIN takes t  ON s.ID = t.ID
JOIN course c ON t.course_id = c.course_id
WHERE c.dept_name = 'Comp. Sci.';


-- Exercise 3.11(b)
-- 2017-ci ildən əvvəl təklif olunan heç bir kursu almayan tələbələrin ID və adı
-- (heç bir kurs almayan tələbələr də nəticəyə düşür)
SELECT ID, name
FROM student
WHERE ID NOT IN (SELECT ID
                 FROM takes
                 WHERE year < 2017);


-- Exercise 3.11(c)
-- Hər departament üzrə müəllimlərin maksimum maaşı
SELECT dept_name, MAX(salary) AS max_salary
FROM instructor
GROUP BY dept_name;


-- Exercise 3.11(d)
-- (c)-də hesablanmış maksimum maaşlar arasından ən aşağısı
SELECT MIN(max_salary) AS lowest_of_max_salaries
FROM (SELECT dept_name, MAX(salary) AS max_salary
      FROM instructor
      GROUP BY dept_name) AS dept_max;


-- ============================================================
-- Exercise 3.15 (Bank schema, Figure 3.18)
-- branch(branch_name, branch_city, assets)
-- customer(ID, customer_name, customer_street, customer_city)
-- loan(loan_number, branch_name, amount)
-- borrower(ID, loan_number)
-- account(account_number, branch_name, balance)
-- depositor(ID, account_number)
-- ============================================================

-- Exercise 3.15(a)
-- "Brooklyn"-də yerləşən HƏR BİR filialda hesabı olan müştərilər
-- (bölmə / division: Brooklyn filialları çoxluğundan müştərinin
--  hesab açdığı filiallar çıxıldıqda boş çoxluq qalmalıdır)
SELECT c.ID, c.customer_name
FROM customer c
WHERE NOT EXISTS (
    (SELECT branch_name
     FROM branch
     WHERE branch_city = 'Brooklyn')
    EXCEPT
    (SELECT a.branch_name
     FROM depositor d
     JOIN account a ON d.account_number = a.account_number
     WHERE d.ID = c.ID)
);


-- Exercise 3.15(b)
-- Bankdakı bütün kredit məbləğlərinin ümumi cəmi
SELECT SUM(amount) AS total_loan_amount
FROM loan;


-- Exercise 3.15(c)
-- "Brooklyn"-də yerləşən ən azı bir filialdan daha çox aktivi olan filialların adları
SELECT branch_name
FROM branch
WHERE assets > SOME (SELECT assets
                     FROM branch
                     WHERE branch_city = 'Brooklyn');


-- ============================================================
-- Exercise 3.24 (University schema)
-- ============================================================

-- Exercise 3.24
-- Fizika (Physics) departamentindəki müəllim tərəfindən məsləhət verilən
-- Mühasibatlıq (Accounting) tələbələrinin adı və ID-si
SELECT DISTINCT s.name, s.ID
FROM student s
JOIN advisor a    ON s.ID = a.s_ID
JOIN instructor i ON a.i_ID = i.ID
WHERE s.dept_name = 'Accounting'
  AND i.dept_name = 'Physics';


-- ============================================================
-- Exercise 3.25 (University schema)
-- ============================================================

-- Exercise 3.25
-- Büdcəsi Philosophy departamentinin büdcəsindən yüksək olan departamentlər (əlifba sırası ilə)
SELECT dept_name
FROM department
WHERE budget > (SELECT budget
                FROM department
                WHERE dept_name = 'Philosophy')
ORDER BY dept_name;
