package com.umc.study.service;

import com.umc.study.repository.RentalRepository;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class RentalService {
    private final RentalRepository rentalRepository;

    public RentalService(RentalRepository rentalRepository) {
        this.rentalRepository = rentalRepository;
    }

    public void createRental(Map<String, Object> request) {
        rentalRepository.save(
                ((Number) request.get("userId")).longValue(),
                ((Number) request.get("bookId")).longValue());
    }
}
