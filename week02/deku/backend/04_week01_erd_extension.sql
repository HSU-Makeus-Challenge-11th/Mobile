-- 1주차 ERD 확장 미션
-- 첨부한 가족 공간 ERD의 family_space, user, post, post_like 관계를 사용한다.
-- 요구사항: 특정 가족 공간의 게시글을 작성자 이름과 좋아요 수를 포함해
--          최신순으로 10개 조회한다.

-- 아래 스키마와 데이터는 확장 쿼리 실행 결과를 검증하기 위한 최소 구성이다.
CREATE DATABASE IF NOT EXISTS week01_family_space_demo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE week01_family_space_demo;

CREATE TABLE IF NOT EXISTS family_space (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  created_at DATETIME(6) NOT NULL,
  updated_at DATETIME(6) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `user` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  family_space_id BIGINT NOT NULL,
  birth_date DATE NULL,
  chat_alarm BIT(1) NOT NULL DEFAULT b'1',
  comment_alarm BIT(1) NOT NULL DEFAULT b'1',
  comment_reply_alarm BIT(1) NOT NULL DEFAULT b'1',
  event_alarm BIT(1) NOT NULL DEFAULT b'1',
  is_room_manager BIT(1) NOT NULL DEFAULT b'0',
  created_at DATETIME(6) NOT NULL,
  updated_at DATETIME(6) NOT NULL,
  email VARCHAR(255) NOT NULL,
  fcm_token VARCHAR(255) NULL,
  name VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  profile_image VARCHAR(255) NULL,
  social_id VARCHAR(255) NULL,
  role ENUM('role_guest', 'role_user') NOT NULL,
  social_type ENUM('google', 'kakao', 'local', 'naver') NOT NULL,
  CONSTRAINT fk_user_family_space
    FOREIGN KEY (family_space_id) REFERENCES family_space(id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS post (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  family_space_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  post_alarm BIT(1) NOT NULL DEFAULT b'1',
  created_at DATETIME(6) NOT NULL,
  updated_at DATETIME(6) NOT NULL,
  content VARCHAR(255) NOT NULL,
  CONSTRAINT fk_post_family_space
    FOREIGN KEY (family_space_id) REFERENCES family_space(id),
  CONSTRAINT fk_post_user
    FOREIGN KEY (user_id) REFERENCES `user`(id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS post_like (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  post_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  created_at DATETIME(6) NOT NULL,
  updated_at DATETIME(6) NOT NULL,
  CONSTRAINT uq_post_like UNIQUE (post_id, user_id),
  CONSTRAINT fk_post_like_post
    FOREIGN KEY (post_id) REFERENCES post(id),
  CONSTRAINT fk_post_like_user
    FOREIGN KEY (user_id) REFERENCES `user`(id)
) ENGINE = InnoDB;

INSERT IGNORE INTO family_space (id, created_at, updated_at) VALUES
  (1, '2026-09-01 09:00:00', '2026-09-01 09:00:00');

INSERT IGNORE INTO `user` (
  id,
  family_space_id,
  birth_date,
  created_at,
  updated_at,
  email,
  name,
  password,
  role,
  social_type
) VALUES
  (1, 1, '1995-03-12', '2026-09-01 09:10:00', '2026-09-01 09:10:00',
   'minseo@example.com', '민서', 'demo-password', 'role_user', 'local'),
  (2, 1, '1997-07-24', '2026-09-01 09:20:00', '2026-09-01 09:20:00',
   'suhyeon@example.com', '수현', 'demo-password', 'role_user', 'local');

INSERT IGNORE INTO post (
  id,
  family_space_id,
  user_id,
  created_at,
  updated_at,
  content
) VALUES
  (1, 1, 1, '2026-09-10 18:00:00', '2026-09-10 18:00:00',
   '가족 여행 사진을 공유합니다.'),
  (2, 1, 2, '2026-09-12 20:00:00', '2026-09-12 20:00:00',
   '이번 주말 저녁 메뉴를 정해요.');

INSERT IGNORE INTO post_like (
  id,
  post_id,
  user_id,
  created_at,
  updated_at
) VALUES
  (1, 1, 2, '2026-09-10 18:10:00', '2026-09-10 18:10:00'),
  (2, 2, 1, '2026-09-12 20:05:00', '2026-09-12 20:05:00'),
  (3, 2, 2, '2026-09-12 20:06:00', '2026-09-12 20:06:00');

-- 확장 조회 쿼리
-- 기준 테이블: post
-- JOIN 이유: 작성자 이름은 user에 있고, 좋아요 수는 post_like를 집계해야 한다.
-- 조건: family_space_id가 1인 게시글
-- 정렬·범위: created_at 내림차순, 같은 시간이면 id 내림차순, 최대 10개
SELECT
  p.id AS post_id,
  p.content,
  u.name AS writer_name,
  COUNT(pl.id) AS like_count,
  p.created_at
FROM post AS p
JOIN `user` AS u
  ON u.id = p.user_id
LEFT JOIN post_like AS pl
  ON pl.post_id = p.id
WHERE p.family_space_id = 1
GROUP BY
  p.id,
  p.content,
  u.name,
  p.created_at
ORDER BY
  p.created_at DESC,
  p.id DESC
LIMIT 10;

-- 결과 검증:
-- 가족 공간 1의 게시글이 최신순으로 조회되며,
-- 각 행에 작성자 이름과 게시글별 좋아요 수가 함께 표시된다.
