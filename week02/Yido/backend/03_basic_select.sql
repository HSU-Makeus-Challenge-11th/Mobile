USE umc_week2;

-- 대여 가능한 책의 제목과 설명을 최신순으로 조회 (단일 테이블)
SELECT book_id, title, description
FROM book
WHERE is_available = TRUE
ORDER BY book_id DESC;
