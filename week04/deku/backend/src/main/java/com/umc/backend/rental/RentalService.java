package com.umc.backend.rental;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RentalService {

    private final RentalRepository rentalRepository;

    public Map<String, Object> createRental(Map<String, Object> body) {
        long userId = requiredLong(body, "userId");
        long bookId = requiredLong(body, "bookId");
        int affectedRows = rentalRepository.create(userId, bookId);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", "대여 기록이 생성되었습니다.");
        response.put("userId", userId);
        response.put("bookId", bookId);
        response.put("affectedRows", affectedRows);
        return response;
    }

    private long requiredLong(Map<String, Object> body, String key) {
        Object value = body.get(key);
        if (value == null) {
            throw new IllegalArgumentException(key + "는 필수입니다.");
        }
        try {
            long parsedValue = Long.parseLong(value.toString());
            if (parsedValue <= 0) {
                throw new NumberFormatException();
            }
            return parsedValue;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(key + "는 1 이상의 숫자여야 합니다.");
        }
    }
}
