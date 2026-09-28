-- 특정 책의 태그 목록과 특정 사용자의 좋아요 여부를 조회
-- 기준 테이블, JOIN한 이유, WHERE 조건, 정렬·목록 기준을 설명
-- 기준 테이블: book
-- JOIN한 이유: book테이블에서 tag테이블까지 JOIN해야하는데, N:M으로 중간 테이블인 book_tag를 경유
--             특정 책이 tag가 없어도 검색하기 위해 LEFT JOIN으로 연결
-- WHERE 조건: 특정 책과 특정 사용자의 id를 1로 가정하고 book_like의 테이블에 user_id가 1이라면 좋아요를 누른것으로 표시


USE mydb;

SELECT
    b.book_id,
    b.title,
    GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ', ') AS tags,
    EXISTS (
        SELECT 1 FROM book_like l
        WHERE l.book_id = b.book_id AND l.user_id = 1
    ) AS is_liked
FROM book b
LEFT JOIN book_tag bt ON b.book_id = bt.book_id
LEFT JOIN tag t       ON bt.tag_id   = t.tag_id
WHERE b.book_id = 1
GROUP BY b.book_id, b.title;


