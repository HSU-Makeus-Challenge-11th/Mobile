# 7주차 필수 미션: 로그인한 사용자 구분

6주차 백엔드를 복사해 다음 API를 추가하거나 변경했습니다.

| API | 인증 | 결과 |
| --- | --- | --- |
| `POST /auth/login` | 불필요 | 닉네임과 accessToken |
| `GET /members/me` | Bearer JWT | 이메일, 닉네임, 가입일 |
| `PATCH /members/me` | Bearer JWT | 수정된 내 정보 |
| `POST /ratings` | Bearer JWT | 자신의 평점 등록, 201 |
| `PATCH /ratings/{ratingId}` | Bearer JWT | 자신의 평점 수정 |
| `DELETE /ratings/{ratingId}` | Bearer JWT | 자신의 평점 삭제, 200 및 `result: null` |

공개 목록 `GET /members/{memberId}/ratings`, 회원가입과 중복 확인은 유지합니다. 쓰기 API에서는 `memberId`를 URL이나 본문에서 받지 않고 토큰에서 추출합니다.

## 실행

`.env.example`을 참고해 `.env`의 DB 접속 정보와 **32바이트 이상**의 `JWT_SECRET`을 설정한 뒤 `./gradlew bootRun`을 실행합니다. `.env`는 Git에서 제외됩니다.

## 검증

- `./gradlew test`: H2 메모리 DB를 사용한 가입, 로그인, 내 정보, 평점 필수 9단계 통합 테스트와 인증 단위 테스트를 실행합니다.
- `postman collection run postman/week07-movielog-mandatory.postman_collection.json --no-report-events`: 실행 중인 서버를 대상으로 13개 요청과 26개 단언을 실행합니다. 기본 주소는 `http://localhost:18080`이며 컬렉션 변수 `baseUrl`로 변경할 수 있습니다.
- 2026-11-09 로컬 H2 서버에서 Postman 13개 요청 / 26개 단언 모두 통과했습니다. 실제 MySQL 환경은 검증하지 않았습니다.

Postman 컬렉션은 실행할 때마다 서로 다른 테스트 이메일을 사용합니다. 테스트 비밀번호와 발급 토큰은 컬렉션 변수에만 저장되며 Git에 저장되지 않습니다.
