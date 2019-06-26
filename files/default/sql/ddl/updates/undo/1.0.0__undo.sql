DROP TABLE IF EXISTS `secrets`;

ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_updated`;
ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_type`;
ALTER TABLE `hopsworks`.`users` CHANGE `activated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

CREATE TABLE IF NOT EXISTS `featurestore_dependency` (
  `id`               INT(11) NOT NULL AUTO_INCREMENT,
  `feature_group_id` INT(11) DEFAULT NULL,
  `training_dataset_id` INT(11) DEFAULT NULL,
  `inode_pid` BIGINT(20) NOT NULL,
  `inode_name`              VARCHAR(255) NOT NULL,
  `partition_id`            BIGINT(20)      NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  FOREIGN KEY (`inode_pid`, `inode_name`, `partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`, `name`, `partition_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
)
  ENGINE = ndbcluster
  DEFAULT CHARSET = latin1
  COLLATE = latin1_general_cs;

DROP TABLE IF EXISTS `hopsworks`.`feature_store_jdbc_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_s3_connector`;
DROP TABLE IF EXISTS `hopsworks`.`feature_store_hopsfs_connector`;
DROP TABLE IF EXISTS `hopsworks`.`on_demand_feature_group`;
DROP TABLE IF EXISTS `hopsworks`.`cached_feature_group`;

ALTER TABLE `hopsworks`.`feature_group` MODIFY COLUMN `hive_tbl_id` BIGINT(20) NOT NULL;
ALTER TABLE `hopsworks`.`feature_store_feature` RENAME TO `training_dataset_feature`;
ALTER TABLE `hopsworks`.`feature_store_feature` MODIFY COLUMN `training_dataset_id` INT(11) NOT NULL;
ALTER TABLE `hopsworks`.`feature_store_feature` DROP FOREIGN KEY `on_demand_feature_group_fk`;
ALTER TABLE `hopsworks`.`feature_store_feature` DROP COLUMN `on_demand_feature_group_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `feature_group_type`;
ALTER TABLE `hopsworks`.`feature_group` DROP FOREIGN KEY `external_fg_fk`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `on_demand_feature_group_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `cached_feature_group_id`;
ALTER TABLE `hopsworks`.`feature_group` DROP INDEX `project_idx`;
ALTER TABLE `hopsworks`.`feature_group` DROP INDEX `feature_store_idx`;
ALTER TABLE `hopsworks`.`training_dataset` DROP INDEX `feature_store_idx`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `training_dataset_type`;
ALTER TABLE `hopsworks`.`training_dataset` DROP CONSTRAINT `external_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP CONSTRAINT `hopsfs_training_dataset_fk`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `hopsfs_training_dataset_id`;
ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `external_training_dataset_id`;

