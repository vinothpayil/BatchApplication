USE spring_batch_users;

DROP TABLE IF EXISTS BATCH_JOB_EXECUTION_SEQ;
DROP TABLE IF EXISTS BATCH_STEP_EXECUTION_SEQ;
DROP TABLE IF EXISTS BATCH_JOB_EXECUTION_CONTEXT;
DROP TABLE IF EXISTS BATCH_STEP_EXECUTION_CONTEXT;
DROP TABLE IF EXISTS BATCH_STEP_EXECUTION;
DROP TABLE IF EXISTS BATCH_JOB_EXECUTION_PARAMS;
DROP TABLE IF EXISTS BATCH_JOB_EXECUTION;
DROP TABLE IF EXISTS BATCH_JOB_INSTANCE;

CREATE TABLE BATCH_JOB_INSTANCE  (
                                     JOB_INSTANCE_ID BIGINT  PRIMARY KEY,
                                     VERSION BIGINT,
                                     JOB_NAME VARCHAR(100) NOT NULL,
                                     JOB_KEY VARCHAR(32) NOT NULL,
                                     constraint JOB_INST_UN unique (JOB_NAME, JOB_KEY)
) ENGINE=InnoDB;

CREATE TABLE BATCH_JOB_EXECUTION  (
                                      JOB_EXECUTION_ID BIGINT  PRIMARY KEY,
                                      VERSION BIGINT  ,
                                      JOB_INSTANCE_ID BIGINT NOT NULL,
                                      CREATE_TIME DATETIME NOT NULL,
                                      START_TIME DATETIME DEFAULT NULL,
                                      END_TIME DATETIME DEFAULT NULL,
                                      STATUS VARCHAR(10) ,
                                      EXIT_CODE VARCHAR(2500),
                                      EXIT_MESSAGE VARCHAR(2500),
                                      LAST_UPDATED DATETIME,
                                      JOB_CONFIGURATION_LOCATION VARCHAR(2500) NULL,
                                      constraint JOB_INST_EXEC_FK foreign key (JOB_INSTANCE_ID)
                                          references BATCH_JOB_INSTANCE(JOB_INSTANCE_ID)
) ENGINE=InnoDB;

CREATE TABLE BATCH_JOB_EXECUTION_PARAMS  (
                                             JOB_EXECUTION_ID BIGINT NOT NULL,
                                             TYPE_CD VARCHAR(6) NOT NULL,
                                             KEY_NAME VARCHAR(100) NOT NULL,
                                             STRING_VAL VARCHAR(250) ,
                                             DATE_VAL DATETIME DEFAULT NULL ,
                                             LONG_VAL BIGINT ,
                                             DOUBLE_VAL DOUBLE PRECISION ,
                                             IDENTIFYING CHAR(1) NOT NULL ,
                                             constraint JOB_EXEC_PARAMS_FK foreign key (JOB_EXECUTION_ID)
                                                 references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB;

CREATE TABLE BATCH_JOB_SEQ (
                                    ID BIGINT NOT NULL,
                                    UNIQUE_KEY CHAR(1) NOT NULL,
                                    CONSTRAINT UNIQUE_KEY_UN UNIQUE (UNIQUE_KEY)
) ENGINE=InnoDB;


INSERT INTO BATCH_JOB_SEQ (ID, UNIQUE_KEY) select * from (select 0 as ID, '0' as UNIQUE_KEY) as tmp
where not exists(select * from BATCH_JOB_SEQ);

CREATE TABLE BATCH_STEP_EXECUTION  (
                                       STEP_EXECUTION_ID BIGINT  PRIMARY KEY ,
                                       VERSION BIGINT NOT NULL,
                                       STEP_NAME VARCHAR(100) NOT NULL,
                                       JOB_EXECUTION_ID BIGINT NOT NULL,
                                       START_TIME DATETIME NOT NULL ,
                                       END_TIME DATETIME DEFAULT NULL,
                                       STATUS VARCHAR(10) ,
                                       COMMIT_COUNT BIGINT ,
                                       READ_COUNT BIGINT ,
                                       FILTER_COUNT BIGINT ,
                                       WRITE_COUNT BIGINT ,
                                       READ_SKIP_COUNT BIGINT ,
                                       WRITE_SKIP_COUNT BIGINT ,
                                       PROCESS_SKIP_COUNT BIGINT ,
                                       ROLLBACK_COUNT BIGINT ,
                                       EXIT_CODE VARCHAR(2500) ,
                                       EXIT_MESSAGE VARCHAR(2500) ,
                                       LAST_UPDATED DATETIME,
                                       constraint JOB_EXEC_STEP_FK foreign key (JOB_EXECUTION_ID)
                                           references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB;

CREATE TABLE batch_job_execution_seq (
  ID BIGINT(20) NOT NULL,
  UNIQUE KEY UNIQUE_KEY (ID) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO batch_job_execution_seq (ID) VALUES (0);

CREATE TABLE batch_job_execution_context  (
    JOB_EXECUTION_ID BIGINT NOT NULL PRIMARY KEY,
    SHORT_CONTEXT VARCHAR(2500) NOT NULL,
    SERIALIZED_CONTEXT TEXT ,
    constraint JOB_EXEC_CTX_FK foreign key (JOB_EXECUTION_ID)
    references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB;

ALTER TABLE BATCH_STEP_EXECUTION
ADD COLUMN CREATE_TIME TIMESTAMP;

ALTER TABLE BATCH_STEP_EXECUTION
MODIFY COLUMN CREATE_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE BATCH_STEP_EXECUTION
MODIFY COLUMN START_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE BATCH_JOB_EXECUTION_PARAMS 
ADD PARAMETER_NAME VARCHAR(255), 
ADD PARAMETER_TYPE VARCHAR(255), 
ADD PARAMETER_VALUE VARCHAR(255);


CREATE TABLE batch_step_execution_seq (
    ID BIGINT NOT NULL,
    UNIQUE_KEY VARCHAR(255) NOT NULL,
    NEXT_VAL BIGINT NOT NULL,

    PRIMARY KEY (ID)
);

CREATE TABLE batch_step_execution_context (
  step_execution_id BIGINT NOT NULL PRIMARY KEY,
  short_context     VARCHAR(2500) NOT NULL,
  serialized_context    TEXT,
  CONSTRAINT step_execution_context_id_fk FOREIGN KEY (step_execution_id)
  REFERENCES batch_step_execution (step_execution_id)
);