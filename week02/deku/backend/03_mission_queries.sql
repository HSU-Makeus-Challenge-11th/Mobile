-- UMC 2주차 공통 미션 3개
USE week02_library;

-- 접속 및 버전 확인
SELECT VERSION() AS mysql_version;

-- 미션 1
-- 요구사항: 문학 카테고리에서 대여 가능한 도서를 최신순으로 10권 조회한다.
-- 기준 테이블: book
-- JOIN 이유: 카테고리 이름은 category 테이블에 있으므로 category_id로 연결한다.
-- 조건: 문학 카테고리이며 대여 가능한 도서
-- 정렬·범위: book_id 내림차순, 최대 10개
SELECT
  b.title AS book_title,
  b.description,
  c.name AS category_name
FROM book AS b
JOIN category AS c
  ON c.category_id = b.category_id
WHERE c.name = '문학'
  AND b.is_available = TRUE
ORDER BY b.book_id DESC
LIMIT 10;

-- 결과 검증:
-- 문학 카테고리에 속하면서 is_available이 TRUE인 도서만 최신순으로 조회된다.

-- 미션 2
-- 요구사항: 사용자 1이 아직 반납하지 않은 책을 반납 예정일 순으로 조회한다.
-- 기준 테이블: rental
-- JOIN 이유: 대여 기록에는 제목이 없으므로 book_id로 book을 연결한다.
-- 조건: user_id가 1이고 returned_at이 NULL인 대여 기록
-- 정렬: due_at 오름차순
SELECT
  b.title AS book_title,
  r.rented_at,
  r.due_at
FROM rental AS r
JOIN book AS b
  ON b.book_id = r.book_id
WHERE r.user_id = 1
  AND r.returned_at IS NULL
ORDER BY r.due_at ASC;

-- 결과 검증:
-- 사용자 1이 아직 반납하지 않은 '겨울의 편지'가 반납 예정일 순으로 조회된다.

-- 미션 3
-- 요구사항: 책 1의 태그 목록과 사용자 1의 좋아요 여부를 함께 조회한다.
-- 기준 테이블: book
-- JOIN 이유: 태그는 book_tag를 거쳐 tag와 연결하고,
--           좋아요하지 않은 경우도 조회하기 위해 book_like는 LEFT JOIN한다.
-- 조건: book_id가 1이고 좋아요 사용자는 user_id 1로 제한
-- 정렬: tag_id 오름차순
SELECT
  b.title AS book_title,
  t.name AS tag_name,
  CASE
    WHEN bl.user_id IS NULL THEN '좋아요 안 함'
    ELSE '좋아요'
  END AS like_status
FROM book AS b
JOIN book_tag AS bt
  ON bt.book_id = b.book_id
JOIN tag AS t
  ON t.tag_id = bt.tag_id
LEFT JOIN book_like AS bl
  ON bl.book_id = b.book_id
 AND bl.user_id = 1
WHERE b.book_id = 1
ORDER BY t.tag_id ASC;

-- 결과 검증:
-- '달빛 도서관'의 '소설', '추천' 태그와 사용자 1의 좋아요 상태가 함께 조회된다.

-- LIMIT/OFFSET 추가 확인
-- 첫 번째 페이지는 OFFSET 0, 두 번째 페이지는 OFFSET 10을 사용한다.
SELECT
  book_id,
  title,
  description
FROM book
ORDER BY book_id DESC
LIMIT 10 OFFSET 0;
