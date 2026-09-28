-- UMC 2주차 공통 실습: 제공된 더미 데이터
USE week02_library;

INSERT INTO users (user_id, nickname) VALUES
  (1, '민서'),
  (2, '수현');

INSERT INTO category (category_id, name) VALUES
  (1, '문학'),
  (2, '과학');

INSERT INTO book (
  book_id,
  category_id,
  title,
  description,
  is_available
) VALUES
  (1, 1, '달빛 도서관', '소설', TRUE),
  (2, 1, '겨울의 편지', '에세이', FALSE),
  (3, 2, '우주를 읽는 법', '과학 교양', TRUE);

INSERT INTO rental (
  rental_id,
  user_id,
  book_id,
  rented_at,
  due_at,
  returned_at
) VALUES
  (1, 1, 2, '2026-08-10 10:00:00', '2026-08-17 10:00:00', NULL),
  (2, 2, 1, '2026-08-01 10:00:00', '2026-08-08 10:00:00', '2026-08-07 15:00:00');

INSERT INTO tag (tag_id, name) VALUES
  (1, '소설'),
  (2, '추천'),
  (3, '과학');

INSERT INTO book_tag (book_id, tag_id) VALUES
  (1, 1),
  (1, 2),
  (3, 3);

INSERT INTO book_like (user_id, book_id) VALUES
  (1, 1),
  (1, 3);

-- 더미 데이터 입력 확인
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental
UNION ALL
SELECT 'tag', COUNT(*) FROM tag
UNION ALL
SELECT 'book_tag', COUNT(*) FROM book_tag
UNION ALL
SELECT 'book_like', COUNT(*) FROM book_like;
