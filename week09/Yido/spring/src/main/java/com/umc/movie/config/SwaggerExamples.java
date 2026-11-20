package com.umc.movie.config;

/**
 * Swagger 문서에 보여 줄 응답 예시.
 * 애노테이션 값은 상수여야 하므로 여러 API가 같이 쓰는 실패 응답을 여기 모은다.
 */
public final class SwaggerExamples {

    private SwaggerExamples() {
    }

    public static final String AUTH401_2 = """
            {
              "isSuccess": false,
              "code": "AUTH401_2",
              "message": "로그인이 필요한 요청입니다.",
              "result": null
            }
            """;

    public static final String AUTH401_3 = """
            {
              "isSuccess": false,
              "code": "AUTH401_3",
              "message": "유효하지 않은 토큰입니다.",
              "result": null
            }
            """;

    public static final String AUTH401_4 = """
            {
              "isSuccess": false,
              "code": "AUTH401_4",
              "message": "토큰이 만료되었습니다. 다시 로그인해주세요.",
              "result": null
            }
            """;

    public static final String MOVIE_ID_400 = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "영화 ID는 양수여야 합니다.",
              "result": null
            }
            """;

    public static final String FAVORITE_CREATED = """
            {
              "isSuccess": true,
              "code": "COMMON201",
              "message": "즐겨찾기를 등록했습니다.",
              "result": { "favoriteId": 1, "movieId": 550, "createdAt": "2026-11-20T21:00:00" }
            }
            """;

    public static final String FAVORITE409_1 = """
            {
              "isSuccess": false,
              "code": "FAVORITE409_1",
              "message": "이미 이 영화를 즐겨찾기하셨습니다.",
              "result": null
            }
            """;
}
