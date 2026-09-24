-- 문학 카테고리의 대여 가능한 도서를 최신순으로 10개 조회합니다.
-- 기준 테이블, JOIN한 이유, WHERE 조건, 정렬·목록 기준을 설명
-- 기준 테이블: book
-- JOIN한 이유: 문학 카테고리가 category 테이블에 있기 때문에 book->category로 JOIN함
-- WHERE 조건: 카테고리의 이름이 "문학"이고 book의 대여가능으로 조건을 구성
-- 정렬기준: 먼저 등록된 책이 낮은 숫자의 book_id를 가져간다는 가정을 하고 내림차순으로 정렬

USE mydb;

SELECT 
    b.title AS book_title ,
    b.description, 
    c.name AS book_category
FROM 
    book b
JOIN
    category c
ON 
    b.category_id = c.category_id 
WHERE
     c.name = "문학" AND b.is_available
ORDER BY 
    b.book_id DESC
LIMIT 10;