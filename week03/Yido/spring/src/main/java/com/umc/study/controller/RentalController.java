package com.umc.study.controller;

import com.umc.study.service.RentalService;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/rentals")
public class RentalController {
    private final RentalService rentalService;

    public RentalController(RentalService rentalService) {
        this.rentalService = rentalService;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> createRental(@RequestBody Map<String, Object> request) {
        rentalService.createRental(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "도서 대여에 성공했습니다."));
    }
}
