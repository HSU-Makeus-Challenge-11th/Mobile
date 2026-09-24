-- 특정 사용자가 아직 반납하지 않은 책을 반납 예정일 순으로 조회합니다.
-- 기준 테이블, JOIN한 이유, WHERE 조건, 정렬·목록 기준을 설명
-- 기준 테이블: rental
-- JOIN 한 이유: 기준 테이블인 rental에는 도서의 이름이 없으므로 rental->book 으로 JOIN
-- WHERE 조건: 특정 사용자를 user_id 1인 사용자로 가정하고, 반납하지 않은 책은 반납한 시간이 없으므로 NULL인지 확인
-- 정렬 기준: 조건인 반납 예정일 순으로 빠른 날짜가 오도록 오름차순 정렬

USE mydb;

SELECT
    b.title,
    r.rented_at,
    r.due_at
FROM rental r
JOIN book b ON b.book_id = r.book_id
WHERE r.user_id = 1
  AND r.returned_at IS NULL
ORDER BY r.due_at ASC;