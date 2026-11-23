# MovieLog — UMC 11기 Flutter 9주차 (jiel)

8주차의 토큰 기반 인증 위에 즐겨찾기, 영화 목록 더 보기, 영화 검색을 추가했습니다.
MovieLog API는 `/v8` 경로를 사용합니다(8주차에 연동한 API는 계약이 같고 경로만 `/v7` → `/v8`).

## 9주차에 추가한 것

| 기능 | 화면 / 경로 | API |
| --- | --- | --- |
| 즐겨찾기 버튼 | 영화 상세 제목 옆 북마크 | `GET·DELETE /v8/favorites/{movieId}`, `POST /v8/favorites` |
| 내 즐겨찾기 | 마이페이지 → `/my/favorites` | `GET /v8/favorites` + TMDB `GET /movie/{id}`(최대 5개씩 보충) |
| 더 보기 | 영화 목록 `/movies` | TMDB `GET /discover/movie?page=` |
| 영화 검색 | 영화 목록 앱바 검색 아이콘 → `/movies/search` | TMDB `GET /search/movie?query=&page=` |

- 즐겨찾기는 서버 성공을 확인한 뒤에만 북마크를 바꿉니다. 409(`FAVORITE409_1`)·404(`FAVORITE404_1`)는 POST를 반복하지 않고 여부 GET으로 화면을 맞춥니다.
- 영화 목록·검색은 `PagedMoviesViewModel`을 각자 별도 인스턴스로 씁니다. 다음 page 실패 시 `nextPage`를 올리지 않아 같은 page를 다시 요청하고, 장르·검색어가 바뀌면 요청 generation을 올려 이전 조건의 늦은 응답을 버립니다.
- `AuthSessionBridge`가 `AuthViewModel`의 세션 변화를 `SessionGuard`에 전달하고, 사용자별 Route의 Provider에 `ValueKey(email:generation)`을 지정해 로그아웃·계정 전환 뒤 이전 계정의 즐겨찾기가 남지 않게 합니다.
- 회원가입·닉네임/이메일 중복 확인은 기존 `/v6` 경로를 그대로 둡니다.

아래는 8주차에 정리한 인증·평점 설명입니다. 본문에서 v7이라고 쓴 계약은 `/v8` 경로에서도 같습니다.

## 실행

```bash
flutter pub get
flutter run
```

`.env`에 `TMDB_ACCESS_TOKEN`이 필요합니다(`.env.example` 참고).

## 인증 흐름

| 상태 | 화면 | 진입 조건 |
| --- | --- | --- |
| `initializing` | Splash(인디케이터) | 앱 시작, 저장소 확인·GET me 검증 중 |
| `retryRequired` | Splash(다시 시도) | 네트워크 등으로 세션 확인 실패 — **토큰은 지우지 않음** |
| `signedOut` | 로그인/회원가입만 허용 | 토큰 없음, 로그아웃, AUTH401_2/3/4 만료 |
| `authenticating` | 로그인(버튼 로딩) | 로그인 요청 중 |
| `signedIn` | 홈·영화·마이 | 신규 로그인(토큰 저장 후) / 재시작 시 GET me 성공 후 |

- 화면 이동은 `GoRouter.redirect` + `refreshListenable: AuthViewModel` 한 곳에서만 결정합니다.
- 로그아웃·만료·회원 전환마다 `sessionVersion`을 올려, 이전 세션에서 늦게 도착한 응답을 버립니다.

## Client 분리

| Client | Authorization | 용도 |
| --- | --- | --- |
| TMDB | `Bearer {TMDB_READ_ACCESS_TOKEN}` | 영화 목록·상세·장르 |
| 워크북 공개 | 없음 | 로그인, 회원가입, 중복 체크, 공개 유저별 평점 조회 |
| 워크북 보호 | `Bearer {MOVIELOG_JWT}` (AuthInterceptor) | `/v8/members/me`, `/v8/ratings`, `/v8/ratings/{id}`, `/v8/favorites`, `/v8/favorites/{movieId}` |

`AuthInterceptor`는 host가 `workbook.devnoco.com`이고 위 보호 path일 때만 토큰을 붙입니다.
디버그 로그(`MovieLogLoggingInterceptor`)는 Authorization·password·accessToken을 `***`로 가립니다.

## 평점 API v6 → v7

| 동작 | v6 | v7 |
| --- | --- | --- |
| 등록 | `POST /v6/members/{memberId}/ratings` → 201, result 미확정 | `POST /v7/ratings` → 201, result = Rating |
| 수정 | `PATCH /v6/members/{memberId}/ratings/{ratingId}` → result null | `PATCH /v7/ratings/{ratingId}` → 200, result = Rating |
| 삭제 | `DELETE …/{ratingId}` → 204, body 없음 | `DELETE /v7/ratings/{ratingId}` → 200, wrapper(result null) |
| 사용자 식별 | path의 memberId | `Authorization: Bearer …` |
| 오류 code | COMMON 계열 | AUTH401_1~4 / MEMBER404_1·409_1 / RATING403_1·404_1·409_1 / COMMON400 |

## 오류 처리

| code | 처리 |
| --- | --- |
| `AUTH401_1` | 로그인 Form 아래 "이메일 또는 비밀번호를 확인해 주세요." (세션 처리 없음) |
| `AUTH401_2/3/4` | 토큰 삭제 → signedOut → /login + "로그인이 만료됐어요" Snackbar(1회) |
| `RATING403_1` | 안내만, 로그아웃하지 않음 |
| `RATING404_1` / `MEMBER404_1` | 안내 + 화면 목록에서 정리 |
| `RATING409_1` | "이미 이 영화에 평점을 남겼어요" 안내 |
| `MEMBER409_1` | 닉네임 필드 아래 오류, 입력값 유지 |
| `COMMON400` | 서버 message를 필드/Dialog에 표시 |
| 네트워크 실패 | 재시도 안내, **자동 로그아웃·토큰 삭제 없음** |

## API 한계 (내 평점 전체 복원)

- v7 로그인·내 정보 응답에는 `memberId`가 없고, 토큰 기반 "내 평점 목록 GET"도 없습니다.
- 그래서 "내가 등록한 평점" 화면은 **현재 로그인 세션에서 등록 response로 받은 Rating**만 보여주고,
  그 Rating을 v7 PATCH/DELETE로 수정·삭제합니다.
- 앱 재시작 후 기존 내 평점 전체 복원은 계약이 확인되기 전까지 **완료 기능으로 표시하지 않습니다.**
  JWT payload에서 memberId를 추정하지 않습니다.
- 로그아웃·만료 시 세션 평점 목록도 함께 비웁니다(TMDB 영화 목록은 유지).

## 보안 저장

- 토큰: `flutter_secure_storage` (Android Keystore 기반 암호화) — key `movielog.access_token`
- 비밀번호: 저장하지 않음
- `shared_preferences`는 장르 같은 비민감 값에만 사용
