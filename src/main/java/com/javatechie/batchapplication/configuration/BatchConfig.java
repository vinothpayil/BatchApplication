package com.javatechie.batchapplication.configuration;


import com.javatechie.batchapplication.entity.User;
import com.javatechie.batchapplication.listener.JobCompletionNotificationListener;
import com.javatechie.batchapplication.processor.UserItemProcessor;
import com.javatechie.batchapplication.repository.UserRepository;
import org.springframework.batch.core.*;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;


import org.springframework.batch.core.job.SimpleJob;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.step.builder.TaskletStepBuilder;
import org.springframework.batch.core.step.item.ChunkOrientedTasklet;
import org.springframework.batch.core.step.item.SimpleChunkProcessor;
import org.springframework.batch.core.step.item.SimpleChunkProvider;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.core.step.tasklet.TaskletStep;
import org.springframework.batch.item.*;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.support.SynchronizedItemStreamReader;
import org.springframework.batch.item.support.builder.SynchronizedItemStreamReaderBuilder;
import org.springframework.batch.repeat.RepeatOperations;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.batch.repeat.policy.SimpleCompletionPolicy;
import org.springframework.batch.repeat.support.TaskExecutorRepeatTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.transaction.PlatformTransactionManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


@Configuration
@EnableBatchProcessing
public class BatchConfig {

    @Autowired
    private JobRepository jobRepository;


    @Autowired
    private PlatformTransactionManager transactionManager;

    @Autowired
    private UserRepository userRepository;



    @Bean
    public FlatFileItemReader<User> reader() {
        FlatFileItemReader<User> reader = new FlatFileItemReader<User>();
        reader.setResource(new ClassPathResource("input/users.txt"));
        reader.setLineMapper(new DefaultLineMapper<User>() {{

        }});
        reader.setStrict(false);
        return reader;
    }

    @Bean
    public UserItemProcessor processor() {
        return new UserItemProcessor();
    }

    @Bean
    public ItemWriter<User> writer() {
        return (items) -> userRepository.saveAll(items);
    }

    @Bean
    public Step step1(ItemReader<User> reader, ItemProcessor<User, User> processor, ItemWriter<User> writer, StepExecutionListener listener) {
        Tasklet tasklet = (contribution, chunkContext) -> {
            List<User> items = new ArrayList<>();
            User item;
            try {
                ((ItemStream)reader).open(new ExecutionContext());  //Opening the reader
                while((item = reader.read()) != null) {
                    User processedItem = processor.process(item);
                    items.add(processedItem);
                }
            } catch (UnexpectedInputException | ParseException | NonTransientResourceException e) {
                e.printStackTrace();
            } finally{
                ((ItemStream)reader).close();  //Closing the reader
            }
            Chunk<User> chunk = new Chunk<>(items);
            writer.write(chunk);
            return RepeatStatus.FINISHED;
        };

        TaskletStep step = new TaskletStep();
        step.setName("step1");
        step.setJobRepository(jobRepository);
        step.setTransactionManager(transactionManager);
        step.setTasklet(tasklet);
        step.setStepExecutionListeners(new StepExecutionListener[]{listener});
        return step;
    }

    @Bean
    public Job importUserJob(JobCompletionNotificationListener listener) {
        SimpleJob job = new SimpleJob("importUserJob");
        job.setJobRepository(jobRepository);
        job.setJobParametersValidator(new JobParametersValidator() {
            @Override
            public void validate(JobParameters parameters) throws JobParametersInvalidException {
                // validation logic here
            }
        });
        job.setJobParametersIncrementer(new RunIdIncrementer());
        job.setJobExecutionListeners(new JobExecutionListener[]{listener});
        job.addStep(step1((ItemReader<User>) reader(),
                (ItemProcessor<User, User>) processor(),
                writer(),
                (StepExecutionListener) listener));
        return job;
    }
}