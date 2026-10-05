package com.umc.backend.book;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import com.umc.backend.book.dto.BookResponse;
import com.umc.backend.book.dto.CreateBookRequest;
import com.umc.backend.common.ApiExceptionHandler;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

class BookControllerTest {

    @Mock
    private BookService bookService;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        LocalValidatorFactoryBean validator = new LocalValidatorFactoryBean();
        validator.afterPropertiesSet();

        mockMvc = MockMvcBuilders.standaloneSetup(new BookController(bookService))
                .setControllerAdvice(new ApiExceptionHandler())
                .setValidator(validator)
                .build();
    }

    @Test
    void 도서_목록을_최신순_응답_DTO로_반환한다() throws Exception {
        when(bookService.getBooks()).thenReturn(List.of(
                new BookResponse(3L, "코스모스", "우주를 이해하는 과학 교양서", "과학", true),
                new BookResponse(2L, "작별하지 않는다", "기억과 사랑에 관한 소설", "문학", true)
        ));

        mockMvc.perform(get("/books"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].bookId").value(3))
                .andExpect(jsonPath("$[0].title").value("코스모스"))
                .andExpect(jsonPath("$[0].categoryName").value("과학"))
                .andExpect(jsonPath("$[0].isAvailable").value(true));
    }

    @Test
    void 도서를_등록하고_201을_반환한다() throws Exception {
        when(bookService.createBook(any(CreateBookRequest.class)))
                .thenReturn(new BookResponse(4L, "스프링 입문", "ORM 실습 도서", "과학", true));

        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "categoryId": 2,
                                  "title": "스프링 입문",
                                  "description": "ORM 실습 도서"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.bookId").value(4))
                .andExpect(jsonPath("$.categoryName").value("과학"))
                .andExpect(jsonPath("$.isAvailable").value(true));
    }

    @Test
    void 빈_제목은_400을_반환한다() throws Exception {
        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "categoryId": 1,
                                  "title": "   "
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("title: 제목은 필수입니다."));

        verify(bookService, never()).createBook(any(CreateBookRequest.class));
    }
}
