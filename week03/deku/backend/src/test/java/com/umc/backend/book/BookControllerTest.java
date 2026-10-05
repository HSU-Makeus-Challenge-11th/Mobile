package com.umc.backend.book;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class BookControllerTest {

    @Mock
    private BookService bookService;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(new BookController(bookService)).build();
    }

    @Test
    void 카테고리별_도서_목록을_JSON으로_반환한다() throws Exception {
        when(bookService.getBooksByCategory(1L))
                .thenReturn(List.of(Map.of("book_id", 1, "category_id", 1, "title", "달빛 도서관")));

        mockMvc.perform(get("/books/category/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].book_id").value(1))
                .andExpect(jsonPath("$[0].category_id").value(1))
                .andExpect(jsonPath("$[0].title").value("달빛 도서관"));
    }
}
