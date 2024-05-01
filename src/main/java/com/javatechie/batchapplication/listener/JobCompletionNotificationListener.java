package com.javatechie.batchapplication.listener;

import com.javatechie.batchapplication.repository.UserRepository;
import org.springframework.batch.core.BatchStatus;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.batch.core.StepExecutionListener;
import org.springframework.batch.core.listener.JobExecutionListenerSupport;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class JobCompletionNotificationListener extends JobExecutionListenerSupport
        implements StepExecutionListener {

    private final UserRepository userRepository;

    @Autowired
    public JobCompletionNotificationListener(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        if(jobExecution.getStatus() == BatchStatus.COMPLETED) {
            System.out.println("!!! JOB FINISHED! Time to verify the results");

            userRepository.findAll().forEach(user -> System.out.println("Found <" + user + "> in the database."));
        }
    }
}

