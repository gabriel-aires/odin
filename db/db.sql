BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `user_type` (
	`name`	TEXT NOT NULL,
	`description`	TEXT NOT NULL
);
INSERT INTO `user_type` VALUES ('admin','Unrestricted user');
INSERT INTO `user_type` VALUES ('default','Default user type. Requires group membership or explicit permissions to operate the system');
CREATE TABLE IF NOT EXISTS `user_permissions` (
	`user_id`	INTEGER NOT NULL,
	`app_role_id`	INTEGER NOT NULL,
	`env_role_id`	INTEGER NOT NULL,
	`enforce_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `user_groups` (
	`user_id`	INTEGER NOT NULL,
	`group_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `user` (
	`name`	TEXT NOT NULL,
	`pass`	TEXT NOT NULL,
	`active`	INTEGER NOT NULL,
	`type_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `role_type` (
	`name`	TEXT NOT NULL,
	`description`	TEXT NOT NULL
);
INSERT INTO `role_type` VALUES ('app','defines an application access policy');
INSERT INTO `role_type` VALUES ('env','defines an environment access policy');
CREATE TABLE IF NOT EXISTS `role` (
	`name`	TEXT NOT NULL,
	`description`	TEXT,
	`active`	INTEGER NOT NULL,
	`access_id`	INTEGER NOT NULL,
	`type_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `group_roles` (
	`group_id`	INTEGER NOT NULL,
	`role_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `group_permissions` (
	`group_id`	INTEGER NOT NULL,
	`app_role_id`	INTEGER NOT NULL,
	`env_role_id`	INTEGER NOT NULL,
	`enforce_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `group` (
	`name`	TEXT NOT NULL,
	`active`	INTEGER NOT NULL
);
INSERT INTO `group` VALUES ('common',1);
CREATE TABLE IF NOT EXISTS `enforce_type` (
	`name`	TEXT NOT NULL,
	`description`	TEXT NOT NULL
);
INSERT INTO `enforce_type` VALUES ('inherit','Effective permission calculated at runtime');
INSERT INTO `enforce_type` VALUES ('grant','Explicitly granted access');
INSERT INTO `enforce_type` VALUES ('deny','Explicitly denied access');
CREATE TABLE IF NOT EXISTS `access_type` (
	`name`	TEXT,
	`description`	TEXT
);
INSERT INTO `access_type` VALUES ('read','Allows read access');
INSERT INTO `access_type` VALUES ('write','read and write access');
INSERT INTO `access_type` VALUES ('exec','read, write and exec access');
COMMIT;
