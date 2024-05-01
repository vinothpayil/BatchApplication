package com.javatechie.batchapplication.repository;

import com.javatechie.batchapplication.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
}
