-- ============================================================
-- VBIS-Chapter3-SQL : Additional queries
-- Exercises: 3.26, 3.27, 3.28, 3.31, 3.32, 3.33, 3.34, 3.35
-- DBMS: PostgreSQL, University schema
-- ============================================================


-- Exercise 3.26
-- Bir kursu ən azı 3 dəfə (yəni ən azı 2 dəfə təkrarən) götürən tələbələr:
-- kurs ID və tələbə ID, kurs ID sırası ilə, təkrarsız
SELECT course_id, ID
FROM takes
GROUP BY course_id, ID
HAVING COUNT(*) >= 3
ORDER BY course_id;


-- Exercise 3.27
-- Ən azı 3 fərqli kursu ən azı 2 dəfə götürmüş tələbələrin ID-ləri
SELECT ID
FROM (SELECT ID, course_id
      FROM takes
      GROUP BY ID, course_id
      HAVING COUNT(*) >= 2) AS repeated
GROUP BY ID
HAVING COUNT(*) >= 3;


-- Exercise 3.28
-- Öz departamentində tədris olunan BÜTÜN kursları tədris edən müəllimlər
-- (ada görə sıralanmış)
SELECT i.ID, i.name
FROM instructor i
WHERE NOT EXISTS (
    (SELECT course_id
     FROM course
     WHERE dept_name = i.dept_name)
    EXCEPT
    (SELECT course_id
     FROM teaches
     WHERE ID = i.ID)
)
ORDER BY i.name;


-- Exercise 3.31
-- Tədris etdiyi heç bir kursda "A" qiyməti verməyən müəllimlər
-- (heç kurs tədris etməyənlər də daxildir)
SELECT i.ID, i.name
FROM instructor i
WHERE NOT EXISTS (
    SELECT 1
    FROM teaches t
    JOIN takes k ON t.course_id = k.course_id
                AND t.sec_id    = k.sec_id
                AND t.semester  = k.semester
                AND t.year      = k.year
    WHERE t.ID = i.ID
      AND k.grade = 'A'
);


-- Exercise 3.32
-- 3.31-in dəyişdirilmiş variantı: yalnız ən azı bir qeyri-null qiymət vermiş müəllimlər
SELECT i.ID, i.name
FROM instructor i
WHERE NOT EXISTS (
    SELECT 1
    FROM teaches t
    JOIN takes k ON t.course_id = k.course_id
                AND t.sec_id    = k.sec_id
                AND t.semester  = k.semester
                AND t.year      = k.year
    WHERE t.ID = i.ID
      AND k.grade = 'A'
)
AND EXISTS (
    SELECT 1
    FROM teaches t
    JOIN takes k ON t.course_id = k.course_id
                AND t.sec_id    = k.sec_id
                AND t.semester  = k.semester
                AND t.year      = k.year
    WHERE t.ID = i.ID
      AND k.grade IS NOT NULL
);


-- Exercise 3.33
-- Günortadan sonra (12:00 və ya daha gec) bitən ən azı bir bölməsi olan
-- "Comp. Sci." kurslarının ID və adı (təkrarsız)
SELECT DISTINCT c.course_id, c.title
FROM course c
JOIN section s    ON c.course_id = s.course_id
JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
WHERE c.dept_name = 'Comp. Sci.'
  AND ts.end_hr >= 12;


-- Exercise 3.34
-- Hər bölmədəki tələbələrin sayı (0 tələbəli bölmələr göstərilmir)
SELECT course_id, sec_id, year, semester, COUNT(ID) AS num
FROM takes
GROUP BY course_id, sec_id, year, semester;


-- Exercise 3.35
-- Maksimum qeydiyyatı olan bölmə(lər)
WITH sec_enrollment AS (
    SELECT course_id, sec_id, year, semester, COUNT(ID) AS num
    FROM takes
    GROUP BY course_id, sec_id, year, semester
)
SELECT course_id, sec_id, year, semester, num
FROM sec_enrollment
WHERE num = (SELECT MAX(num) FROM sec_enrollment);
