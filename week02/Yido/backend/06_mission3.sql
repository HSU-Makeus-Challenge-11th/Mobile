USE umc_week2;

-- 미션 3. 특정 책(book_id = 1)의 태그 목록과 특정 사용자(user_id = 1)의 좋아요 여부 조회
-- 기준 테이블: book / JOIN: book -> book_tag -> tag로 태그, book -> book_like로 좋아요
-- 좋아요가 없어도 태그는 보여야 하므로 book_like는 LEFT JOIN, 사용자 조건은 ON에 둔다
SELECT b.title,
       t.name AS tag_name,
       bl.user_id IS NOT NULL AS is_liked
FROM book b
JOIN book_tag bt ON b.book_id = bt.book_id
JOIN tag t ON bt.tag_id = t.tag_id
LEFT JOIN book_like bl ON b.book_id = bl.book_id AND bl.user_id = 1
WHERE b.book_id = 1
ORDER BY t.tag_id ASC;
