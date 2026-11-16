package com.umc.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:week07;MODE=MySQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=0123456789abcdef0123456789abcdef",
        "jwt.access-expiration=3600000"
})
@AutoConfigureMockMvc
class Week07ScenarioTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;

    @Test
    void 필수_9단계_시나리오와_내_정보_API() throws Exception {
        String suffix = Long.toString(System.nanoTime());
        String emailA = "a-" + suffix + "@umc.com";
        String emailB = "b-" + suffix + "@umc.com";
        assertStatus(post("/members").contentType(MediaType.APPLICATION_JSON)
                .content(signup(emailA, "회원A")), 201, "COMMON201");
        assertStatus(post("/members").contentType(MediaType.APPLICATION_JSON)
                .content(signup(emailB, "회원B")), 201, "COMMON201");

        String tokenA = result(post("/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(login(emailA)), 200, "COMMON200").path("result").path("accessToken").asText();
        String tokenB = result(post("/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(login(emailB)), 200, "COMMON200").path("result").path("accessToken").asText();
        assertThat(tokenA).isNotBlank();
        assertThat(tokenB).isNotBlank();

        JsonNode me = result(get("/members/me").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result");
        assertThat(me.path("email").asText()).isEqualTo(emailA);
        assertThat(me.path("nickname").asText()).isEqualTo("회원A");
        assertThat(me.path("createdAt").asText()).isNotBlank();
        assertStatus(get("/members/me"), 401, "AUTH401_2");
        assertStatus(patch("/members/me").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content("{\"nickname\":\"변경A\"}"),
                200, "COMMON200");
        assertThat(result(get("/members/me").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").path("nickname").asText()).isEqualTo("변경A");

        String create = "{\"movieId\":550,\"score\":5,\"comment\":\"좋아요\"}";
        long ratingId = result(post("/ratings").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(create),
                201, "COMMON201").path("result").path("ratingId").asLong();
        assertThat(ratingId).isPositive();
        assertStatus(post("/ratings").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(create), 409, "RATING409_1");
        String update = "{\"score\":4,\"comment\":\"다시 봐도 좋아요\"}";
        assertStatus(patch("/ratings/{ratingId}", ratingId).header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(update), 200, "COMMON200");
        assertStatus(patch("/ratings/{ratingId}", ratingId).header("Authorization", bearer(tokenB))
                .contentType(MediaType.APPLICATION_JSON).content(update), 403, "RATING403_1");
        assertStatus(patch("/ratings/{ratingId}", ratingId)
                .contentType(MediaType.APPLICATION_JSON).content(update), 401, "AUTH401_2");
        assertStatus(delete("/ratings/99999").header("Authorization", bearer(tokenA)),
                404, "RATING404_1");
        JsonNode deleted = result(delete("/ratings/{ratingId}", ratingId)
                .header("Authorization", bearer(tokenA)), 200, "COMMON200");
        assertThat(deleted.path("result").isNull()).isTrue();
    }

    private JsonNode result(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
                            int status, String code) throws Exception {
        MvcResult response = mvc.perform(request).andReturn();
        assertThat(response.getResponse().getStatus()).isEqualTo(status);
        JsonNode json = mapper.readTree(response.getResponse().getContentAsByteArray());
        assertThat(json.path("code").asText()).isEqualTo(code);
        return json;
    }

    private void assertStatus(org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder request,
                              int status, String code) throws Exception {
        result(request, status, code);
    }

    private String bearer(String token) { return "Bearer " + token; }
    private String login(String email) { return "{\"email\":\"" + email + "\",\"password\":\"Password!1\"}"; }
    private String signup(String email, String nickname) {
        return "{\"email\":\"" + email + "\",\"password\":\"Password!1\",\"nickname\":\"" + nickname + "\"}";
    }
}
