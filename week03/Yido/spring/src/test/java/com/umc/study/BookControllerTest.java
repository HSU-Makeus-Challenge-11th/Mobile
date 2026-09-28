package com.umc.study;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.umc.study.controller.BookController;
import com.umc.study.service.BookService;
import java.util.List;
import java.util.Map;
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
    void returnsBooksWithDatabaseSnakeCaseKeys() throws Exception {
        when(bookService.getBooks()).thenReturn(List.of(Map.of("book_id", 1, "category_id", 1, "title", "클린 코드")));

        mockMvc.perform(get("/books"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].book_id").value(1))
                .andExpect(jsonPath("$[0].category_id").value(1));
    }

    @Test
    void passesCategoryIdToService() throws Exception {
        when(bookService.getBooksByCategory(1L)).thenReturn(List.of());

        mockMvc.perform(get("/books/category/1"))
                .andExpect(status().isOk());

        verify(bookService).getBooksByCategory(1L);
    }

    @Test
    void createsBookFromRequestBody() throws Exception {
        mockMvc.perform(post("/books")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"categoryId\":1,\"title\":\"클린 코드\",\"description\":\"좋은 코드 작성법\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("도서 등록에 성공했습니다."));

        verify(bookService).createBook(Map.of(
                "categoryId", 1,
                "title", "클린 코드",
                "description", "좋은 코드 작성법"));
    }
}
