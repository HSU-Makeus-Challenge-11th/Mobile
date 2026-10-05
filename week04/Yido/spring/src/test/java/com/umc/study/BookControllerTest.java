package com.umc.study;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.umc.study.controller.BookController;
import com.umc.study.dto.BookResponse;
import com.umc.study.dto.CreateBookRequest;
import com.umc.study.exception.CategoryNotFoundException;
import com.umc.study.service.BookService;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(BookController.class)
class BookControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private BookService bookService;

    @Test
    void returnsBooksAsCamelCaseDto() throws Exception {
        when(bookService.getBooks()).thenReturn(List.of(
                new BookResponse(3L, "우주를 읽는 법", "과학 교양", "과학", true)));

        mockMvc.perform(get("/books"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].bookId").value(3))
                .andExpect(jsonPath("$[0].categoryName").value("과학"))
                .andExpect(jsonPath("$[0].isAvailable").value(true))
                .andExpect(jsonPath("$[0].book_id").doesNotExist());
    }

    @Test
    void createsBookAndReturns201() throws Exception {
        when(bookService.createBook(new CreateBookRequest(1L, "클린 코드", "좋은 코드 작성법")))
                .thenReturn(new BookResponse(4L, "클린 코드", "좋은 코드 작성법", "문학", true));

        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"categoryId\":1,\"title\":\"클린 코드\",\"description\":\"좋은 코드 작성법\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.bookId").value(4))
                .andExpect(jsonPath("$.categoryName").value("문학"));
    }

    @Test
    void rejectsBlankTitleWith400() throws Exception {
        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"categoryId\":1,\"title\":\" \"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("제목은 비어 있을 수 없습니다."));

        verify(bookService, never()).createBook(any());
    }

    @Test
    void returns404ForUnknownCategory() throws Exception {
        when(bookService.createBook(any())).thenThrow(new CategoryNotFoundException(999L));

        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"categoryId\":999,\"title\":\"없는 카테고리\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("존재하지 않는 카테고리입니다. categoryId=999"));
    }
}
