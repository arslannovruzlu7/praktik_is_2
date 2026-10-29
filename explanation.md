# Explanation

> Qeyd: Bu mətn qaralamadır. Təhvil verməzdən əvvəl öz təcrübənizə uyğun düzəldin.

## 1. Ən çətin hesab etdiyim SQL sorğusu hansı oldu?

Ən çətin sorğu 3.15(a) oldu: "Brooklyn"-də yerləşən hər bir filialda hesabı olan müştərilərin tapılması. Burada adi JOIN kifayət etmir, çünki müştərinin yalnız bir Brooklyn filialında deyil, bütün Brooklyn filiallarında hesabı olmalıdır. Bu, relyasiya cəbrində "bölmə" (division) əməliyyatına uyğundur. Mən bunu `NOT EXISTS` və `EXCEPT` ilə həll etdim: Brooklyn filialları çoxluğundan müştərinin hesab açdığı filialları çıxdım və nəticə boşdursa, müştəri şərti ödəyir. Eyni məntiq 3.28-də (öz departamentinin bütün kurslarını tədris edən müəllimlər) də lazım oldu.

## 2. Hansı sorğu üçün alt sorğu (subquery) istifadə etdim?

Bir neçə sorğuda alt sorğu istifadə etdim:

- **3.25:** Philosophy departamentinin büdcəsini skalyar alt sorğu ilə tapıb digər departamentlərin büdcəsi ilə müqayisə etdim.
- **3.11(b):** `NOT IN (SELECT ID FROM takes WHERE year < 2017)` ilə 2017-dən əvvəl kurs götürənləri çıxdım.
- **3.11(d):** `FROM` hissəsində alt sorğu ilə hər departamentin maksimum maaşını hesablayıb xaricdən `MIN` tətbiq etdim. PostgreSQL-də bu alt sorğuya ad (alias) vermək məcburidir.
- **3.15(c):** `> SOME (SELECT ...)` ilə Brooklyn filiallarının aktivləri ilə müqayisə etdim.
- **3.35:** `WITH` ifadəsi və maksimumu tapmaq üçün alt sorğu birlikdə işlədildi.

## 3. JOIN istifadə etdiyim bir nümunənin izahı

3.24-də üç cədvəli birləşdirdim: `student`, `advisor` və `instructor`. `student` ilə `advisor` `s_ID` üzrə, `advisor` ilə `instructor` isə `i_ID` üzrə bağlanır. Beləliklə hər tələbəni onun məsləhətçisi ilə əlaqələndirdim. Sonra `WHERE` ilə tələbənin departamentinin Accounting, müəllimin departamentinin isə Physics olmasını yoxladım. Cədvəllərin adlarını ayrı-ayrı yazmaq əvəzinə `JOIN ... ON` istifadə etmək sorğunu oxunaqlı edir və birləşmə şərtini filtr şərtindən ayırır. Təkrarlanan sətirlərin qarşısını almaq üçün `DISTINCT` əlavə etdim.

## 4. Qarşılaşdığım problem və həlli

3.31 və 3.32-də `grade` sütunu `NULL` ola bildiyi üçün çətinlik yarandı. Əvvəlcə `grade <> 'A'` kimi yazmaq istədim, lakin `NULL` ilə müqayisə həmişə `UNKNOWN` verir və belə sətirlər nəticədən düşür. Bundan əlavə, heç kurs tədris etməyən müəllimlər də 3.31-də nəticəyə daxil olmalı idi. Problemi `NOT EXISTS` ilə həll etdim: müəllimin tədris etdiyi bölmədə "A" almış tələbə varmı deyə yoxlayıram. Tələbə yoxdursa (hətta müəllim heç kurs tədris etməyibsə) müəllim nəticəyə düşür. 3.32-də isə əlavə olaraq `EXISTS (... grade IS NOT NULL)` şərtini qoydum. Bu halda müəllimin ən azı bir qeyri-null qiymət vermiş olması tələb olunur.

Digər problem `takes` və `teaches` cədvəllərini birləşdirərkən idi. Bunu yalnız `course_id` üzrə bağlasam, fərqli semestr və illərin bölmələri qarışır. Düzgün nəticə üçün `course_id`, `sec_id`, `semester` və `year` dörd sütununun hamısı üzrə birləşdirmək lazımdır.
