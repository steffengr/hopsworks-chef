CREATE TABLE IF NOT EXISTS `secrets` (
       `uid` INT NOT NULL,
       `secret_name` VARCHAR(125) NOT NULL,
       `secret` VARBINARY(10000) NOT NULL,
       `added_on` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       `visibility` TINYINT NOT NULL,
       `pid_scope` INT DEFAULT NULL,
       PRIMARY KEY (`uid`, `secret_name`),
       FOREIGN KEY `secret_uid` (`uid`) REFERENCES `users` (`uid`)
          ON DELETE CASCADE
          ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`users` ADD COLUMN `validation_key_updated` timestamp DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` ADD COLUMN `validation_key_type` VARCHAR(20) DEFAULT NULL;
ALTER TABLE `hopsworks`.`users` CHANGE `activated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS `feature_store_jdbc_connector` (
  `id`                      INT(11)          NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)          NOT NULL,
  `connection_string`       VARCHAR(5000)    NOT NULL,
  `arguments`               VARCHAR(2000)    NULL,
  `description`             VARCHAR(1000)    NULL,
  `name`                    VARCHAR(1000)    NOT NULL UNIQUE,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_s3_connector` (
  `id`                      INT(11)         NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)         NOT NULL,
  `access_key`              VARCHAR(1000)   NULL,
  `secret_key`              VARCHAR(1000)   NULL,
  `bucket`                  VARCHAR(5000)   NOT NULL,
  `description`             VARCHAR(1000)   NULL,
  `name`                    VARCHAR(1000)   NOT NULL UNIQUE,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_hopsfs_connector` (
  `id`                      INT(11)         NOT NULL AUTO_INCREMENT,
  `feature_store_id`        INT(11)         NOT NULL,
  `hopsfs_dataset`          INT(11)         NOT NULL,
  `description`             VARCHAR(1000)   NULL,
  `name`                    VARCHAR(1000)   NOT NULL UNIQUE,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_store_id`) REFERENCES `hopsworks`.`feature_store` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hopsfs_dataset`) REFERENCES `hopsworks`.`dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;


CREATE TABLE IF NOT EXISTS `on_demand_feature_group` (
  `id`                      INT(11)         NOT NULL AUTO_INCREMENT,
  `query`                   VARCHAR(11000)  NOT NULL,
  `jdbc_connector_id`       INT(11)         NOT NULL,
  `description`             VARCHAR(1000)   NULL,
  `name`                    VARCHAR(1000)   NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`jdbc_connector_id`) REFERENCES `hopsworks`.`feature_store_jdbc_connector` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `cached_feature_group` (
  `id`                             INT(11)         NOT NULL AUTO_INCREMENT,
  `offline_feature_group`          BIGINT(20)      NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`offline_feature_group`) REFERENCES `metastore`.`TBLS` (`TBL_ID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;


CREATE TABLE IF NOT EXISTS `hopsfs_training_dataset` (
  `id`                                INT(11)         NOT NULL AUTO_INCREMENT,
  `inode_pid`                         BIGINT(20)      NOT NULL,
  `inode_name`                        VARCHAR(255)    NOT NULL,
  `partition_id`                      BIGINT(20)      NOT NULL,
  `hopsfs_connector_id`               INT(11)         NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`hopsfs_connector_id`) REFERENCES `hopsworks`.`feature_store_hopsfs_connector` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `external_training_dataset` (
  `id`                                INT(11)         NOT NULL AUTO_INCREMENT,
  `s3_connector_id`                   INT(11)         NOT NULL,
  `name`                              VARCHAR(256)    NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`s3_connector_id`) REFERENCES `hopsworks`.`feature_store_s3_connector` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

DROP TABLE IF EXISTS `hopsworks`.`featurestore_dependency`;
ALTER TABLE `hopsworks`.`training_dataset_feature` RENAME TO `feature_store_feature`;
ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `training_dataset_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_store_feature` ADD COLUMN `on_demand_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_store_feature` ADD CONSTRAINT `on_demand_feature_group_fk`
                                                FOREIGN KEY (`on_demand_feature_group_id`) REFERENCES
                                               `hopsworks`.`on_demand_feature_group`(`id`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `feature_group_type` INT(11) NOT NULL DEFAULT '0';
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `on_demand_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `on_demand_feature_group_fk`
                                                FOREIGN KEY (`on_demand_feature_group_id`) REFERENCES
                                               `hopsworks`.`on_demand_feature_group`(`id`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `cached_feature_group_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`feature_group` ADD CONSTRAINT `cached_feature_group_fk`
                                                FOREIGN KEY (`cached_feature_group_id`) REFERENCES
                                               `hopsworks`.`cached_feature_group`(`id`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `hopsfs_training_dataset_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `hopsfs_training_dataset_fk`
                                                FOREIGN KEY (`hopsfs_training_dataset_id`) REFERENCES
                                               `hopsworks`.`hopsfs_training_dataset`(`id`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `external_training_dataset_id` INT(11) NULL;
ALTER TABLE `hopsworks`.`training_dataset` ADD CONSTRAINT `external_training_dataset_fk`
                                                FOREIGN KEY (`external_training_dataset_id`) REFERENCES
                                               `hopsworks`.`external_training_dataset`(`id`)
                                               ON DELETE CASCADE
                                               ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD  COLUMN `training_dataset_type`   INT(11) NOT NULL DEFAULT '0';

/*
  Move columns from feature_group to cached_feature_group
*/

-- Move hive_tbl_id
INSERT INTO `hopsworks`.`cached_feature_group`(`offline_feature_group`)
SELECT `hive_tbl_id` FROM `hopsworks`.`feature_group` WHERE feature_group_type=0;

-- Set foreign key on parent table
UPDATE `hopsworks`.`feature_group` INNER JOIN `hopsworks`.`cached_feature_group`
    ON `feature_group`.`hive_tbl_id` = `cached_feature_group`.`offline_feature_group`
SET `feature_group`.`cached_feature_group_id` = `cached_feature_group`.`id`;

/*
  Drop foreign keys and columns from the parent table that was move to the child table
*/

-- drop foreign key to metastore.TBLS
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "feature_group" AND REFERENCED_TABLE_NAME="TBLS");
SET @s := concat('ALTER TABLE hopsworks.feature_group DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- Drop hive_tbl_id column from feature_group
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `hive_tbl_id`;

/*
  Move columns from training_dataset to hopsfs_training_dataset
*/

-- Move Inode
INSERT INTO `hopsworks`.`hopsfs_training_dataset`(`inode_pid`, `inode_name`, `partition_id`)
SELECT `inode_pid`, `inode_name`, `partition_id` FROM `hopsworks`.`training_dataset` WHERE training_dataset_type=0;

-- Set foreign key on parent table
UPDATE `hopsworks`.`training_dataset` INNER JOIN `hopsworks`.`hopsfs_training_dataset`
    ON `training_dataset`.`inode_pid` = `hopsfs_training_dataset`.`inode_pid`
    AND `training_dataset`.`inode_name` = `hopsfs_training_dataset`.`inode_name`
    AND `training_dataset`.`partition_id` = `hopsfs_training_dataset`.`partition_id`
SET `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`;

-- Move dataset to foreign key to connector table
UPDATE `hopsworks`.`hopsfs_training_dataset` INNER JOIN `hopsworks`.`feature_store_hopsfs_connector`
    INNER JOIN `hopsworks`.`training_dataset`
    ON `training_dataset`.`training_dataset_folder` = `feature_store_hopsfs_connector`.`hopsfs_dataset`
    AND `training_dataset`.`hopsfs_training_dataset_id` = `hopsfs_training_dataset`.`id`
SET `hopsfs_training_dataset`.`hopsfs_connector_id` = `feature_store_hopsfs_connector`.`id`;

/*
  Move columns from training_dataset to hopsfs_training_dataset - COMPLETE
*/


/*
  Drop foreign keys and columns from the parent table that was move to the child table
*/
-- drop foreign key to dataset
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "training_dataset" AND REFERENCED_TABLE_NAME="dataset");
SET @s := concat('ALTER TABLE hopsworks.training_dataset DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- drop foreign key to inode
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "training_dataset" AND REFERENCED_TABLE_NAME="hdfs_inodes" LIMIT 1);
SET @s := concat('ALTER TABLE hopsworks.training_dataset DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- drop inode and dataset columns
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `training_dataset_folder`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `inode_pid`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `inode_name`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `partition_id`;

/*
  Drop foreign keys and columns from the parent table that was move to the child table - COMPLETE
*/
