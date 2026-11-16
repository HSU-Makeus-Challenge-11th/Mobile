package com.umc.backend.member;

import com.umc.backend.common.ApiExceptionHandler;
import com.umc.backend.member.dto.AvailabilityResponse;
import com.umc.backend.member.dto.MemberCreateRequest;
import com.umc.backend.member.dto.MemberCreateResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.umc.backend.common.ApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class MemberControllerTest {

    @Mock
    private MemberService memberService;

    private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        LocalValidatorFactoryBean validator = new LocalValidatorFactoryBean();
        validator.afterPropertiesSet();

        mockMvc = MockMvcBuilders.standaloneSetup(new MemberController(memberService))
                .setControllerAdvice(new ApiExceptionHandler())
                .setValidator(validator)
                .build();
    }

    @Test
    void 닉네임_중복_여부를_응답한다() throws Exception {
        when(memberService.checkNickname("수현")).thenReturn(new AvailabilityResponse(false));

        mockMvc.perform(get("/members/nickname/{nickname}", "수현"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.result.available").value(false));
    }

    @Test
    void 이메일_중복_여부를_응답한다() throws Exception {
        when(memberService.checkEmail("new@umc.com")).thenReturn(new AvailabilityResponse(true));

        mockMvc.perform(get("/members/email/{email}", "new@umc.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.result.available").value(true));
    }

    @Test
    void 회원가입에_성공하면_201과_비밀번호를_제외한_정보를_응답한다() throws Exception {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "Umc!1234", "moviefan");
        when(memberService.createMember(request))
                .thenReturn(new MemberCreateResponse(1L, "umc@example.com", "moviefan"));

        mockMvc.perform(post("/members")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.result.memberId").value(1))
                .andExpect(jsonPath("$.result.password").doesNotExist());
    }

    @Test
    void 비밀번호_규칙을_지키지_않으면_400_공통_오류를_응답한다() throws Exception {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "password", "moviefan");

        mockMvc.perform(post("/members")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("COMMON400"))
                .andExpect(jsonPath("$.result").isEmpty());
    }

    @Test
    void 중복_이메일은_409_공통_오류를_응답한다() throws Exception {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "Umc!1234", "moviefan");
        when(memberService.createMember(request)).thenThrow(new ApiException(
                HttpStatus.CONFLICT,
                "MEMBER4091",
                "이미 사용 중인 이메일입니다."
        ));

        mockMvc.perform(post("/members")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("MEMBER4091"))
                .andExpect(jsonPath("$.result").isEmpty());
    }
}
