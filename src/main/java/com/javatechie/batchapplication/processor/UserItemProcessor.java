package com.javatechie.batchapplication.processor;

import com.javatechie.batchapplication.entity.User;
import org.springframework.batch.item.ItemProcessor;

public class UserItemProcessor implements ItemProcessor<User, User> {
    @Override
    public User process(User user) throws Exception {
        // Here you could add some validation or logging
        // For now, just pass the user through
        return user;
    }
}


