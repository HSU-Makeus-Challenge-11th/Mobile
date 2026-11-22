package com.umc.movie.controller.docs;

/**
 * Swagger 문서에 보여 줄 실패 응답 예시 모음입니다.
 * 여러 API가 같은 실패 응답을 쓰기 때문에 한곳에 모아 두고 가져다 씁니다.
 * 애너테이션에는 상수만 넣을 수 있어서 static final 문자열로 둡니다.
 */
final class DocsExamples {

    private DocsExamples() {
    }

    static final String AUTH401_2 = """
            {
              "isSuccess": false,
              "code": "AUTH401_2",
              "message": "로그인이 필요한 요청입니다.",
              "result": null
            }
            """;

    static final String AUTH401_3 = """
            {
              "isSuccess": false,
              "code": "AUTH401_3",
              "message": "유효하지 않은 토큰입니다.",
              "result": null
            }
            """;

    static final String AUTH401_4 = """
            {
              "isSuccess": false,
              "code": "AUTH401_4",
              "message": "토큰이 만료되었습니다. 다시 로그인해주세요.",
              "result": null
            }
            """;

    static final String COMMON4001_MOVIE_ID = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "영화 ID는 양수여야 합니다.",
              "result": null
            }
            """;

    static final String COMMON4001_SCORE = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "별점은 5점 이하여야 합니다.",
              "result": null
            }
            """;

    static final String MEMBER404_1 = """
            {
              "isSuccess": false,
              "code": "MEMBER404_1",
              "message": "해당 회원을 찾을 수 없습니다.",
              "result": null
            }
            """;

    static final String FAVORITE404_1 = """
            {
              "isSuccess": false,
              "code": "FAVORITE404_1",
              "message": "즐겨찾기한 영화를 찾을 수 없습니다.",
              "result": null
            }
            """;

    static final String FAVORITE409_1 = """
            {
              "isSuccess": false,
              "code": "FAVORITE409_1",
              "message": "이미 이 영화를 즐겨찾기하셨습니다.",
              "result": null
            }
            """;

    static final String RATING409_1 = """
            {
              "isSuccess": false,
              "code": "RATING409_1",
              "message": "이미 이 영화에 평점을 남기셨습니다.",
              "result": null
            }
            """;
}
