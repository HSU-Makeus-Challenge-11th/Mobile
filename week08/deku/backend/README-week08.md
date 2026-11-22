# 8주차 Spring Boot: 즐겨찾기와 영화 기록

7주차 백엔드를 `week08/deku/backend`로 복사하고, JWT로 식별한 회원의 즐겨찾기와 영화 기록 API를 추가했습니다. 요청 URL과 바디에는 `memberId`를 받지 않습니다.

| 요청 | 결과 |
| --- | --- |
| `POST /favorites` | 201, 등록한 `favoriteId`, `movieId`, `createdAt` |
| `GET /favorites` | 200, 내 즐겨찾기 배열(최신 등록순, 없으면 `[]`) |
| `GET /favorites/{movieId}` | 200, `isFavorite` |
| `DELETE /favorites/{movieId}` | 200, `result: null` |
| `POST /movie-records` | 201, `rating`과 선택적 `favorite` |

`POST /movie-records`에서 `addToFavorites: true`이면 `MovieRecordService.create()`의 단일 `@Transactional` 안에서 두 행을 저장합니다. 즐겨찾기 중복 등으로 뒤 작업이 실패하면 앞서 저장한 평점도 롤백됩니다. `false`이면 평점만 저장하고 `favorite: null`을 반환합니다.

## 검증

```bash
cd week08/deku/backend
./gradlew test
```

H2 통합 테스트를 포함한 35개 테스트가 통과했습니다. `Week08ScenarioTest`는 무토큰 401, 입력 오류 400, 즐겨찾기 중복 409, 회원 간 목록 분리, 최신순, 삭제 200/미존재 404, 영화 기록 성공 및 롤백을 검증합니다. 실제 MySQL 서버와 Postman 화면 캡처는 별도로 확인해야 합니다.

## Postman 캡처 순서

1. 서버를 실행하고 `POST /auth/login`으로 토큰을 발급받습니다. 응답 토큰은 캡처에서 가립니다.
2. `Authorization: Bearer {accessToken}`을 설정합니다.
3. `POST /favorites`에 `{"movieId":550}`을 보내 201을 캡처합니다.
4. 같은 요청을 반복해 409 `FAVORITE409_1`을 캡처합니다.
5. `GET /favorites`의 목록과 `GET /favorites/550`의 `isFavorite: true`를 캡처합니다.
6. `DELETE /favorites/550`의 200/`result: null`을 캡처합니다. 이어서 여부 조회 `false`와 빈 목록 `[]`를 확인합니다.
7. 다른 영화 ID(예: 238)로 `POST /movie-records`에 `{"movieId":238,"score":5,"comment":"다시 보고 싶은 영화입니다.","addToFavorites":true}`를 보내 `rating`과 `favorite`가 모두 있는 201 응답을 캡처합니다.
8. `MovieRecordService.create()`의 `@Transactional` 및 두 저장 부분을 캡처합니다.

같은 영화 ID를 이미 사용한 계정에서는 3번 또는 7번의 성공 응답 대신 중복 오류가 납니다. 캡처 전에 해당 ID의 기존 평점·즐겨찾기 여부를 확인하거나 새로운 영화 ID를 사용하세요.
