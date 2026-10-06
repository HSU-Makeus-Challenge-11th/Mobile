// src/main/java/.../repository/CategoryRepository.java
package com.umc.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.umc.backend.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}
