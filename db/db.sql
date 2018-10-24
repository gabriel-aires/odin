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
	`name`	TEXT NOT NULL UNIQUE,
	`pass`	TEXT NOT NULL,
	`active`	INTEGER NOT NULL,
	`type_id`	INTEGER NOT NULL
);
INSERT INTO `user` VALUES ('admin','a4444468b2bef94f51dc31fbcfb46360637542901cb1aae92f8ae7619344a66c',1,1);
CREATE TABLE IF NOT EXISTS `task` (
	`name`	TEXT NOT NULL UNIQUE,
	`description`	TEXT NOT NULL UNIQUE,
	`steps`	TEXT NOT NULL UNIQUE,
	`pipeline`	TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS `step` (
	`name`	TEXT NOT NULL UNIQUE,
	`type`	TEXT NOT NULL,
	`script_id`	INTEGER NOT NULL UNIQUE,
	`requirements`	TEXT,
	`artifacts`	TEXT,
	`arguments`	TEXT,
	`mutexes`	TEXT,
	`reversible`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `script` (
	`name`	TEXT NOT NULL UNIQUE,
	`description`	TEXT NOT NULL,
	`revision`	INTEGER NOT NULL UNIQUE,
	`content`	TEXT NOT NULL UNIQUE,
	`arguments`	TEXT,
	`dependencies`	TEXT
);
CREATE TABLE IF NOT EXISTS `rule` (
	`name`	TEXT NOT NULL UNIQUE,
	`pattern`	TEXT
);
INSERT INTO `rule` VALUES ('required','.');
INSERT INTO `rule` VALUES ('optional','');
INSERT INTO `rule` VALUES ('task_type','^deploy|build$');
INSERT INTO `rule` VALUES ('password_size','........');
CREATE TABLE IF NOT EXISTS `role_type` (
	`name`	TEXT NOT NULL,
	`description`	TEXT NOT NULL
);
INSERT INTO `role_type` VALUES ('app','defines an application access policy');
INSERT INTO `role_type` VALUES ('env','defines an environment access policy');
CREATE TABLE IF NOT EXISTS `role` (
	`name`	TEXT NOT NULL UNIQUE,
	`description`	TEXT,
	`active`	INTEGER NOT NULL,
	`access_id`	INTEGER NOT NULL,
	`type_id`	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS `lib` (
	`name`	TEXT NOT NULL UNIQUE,
	`description`	TEXT NOT NULL,
	`revision`	INTEGER NOT NULL UNIQUE,
	`content`	TEXT NOT NULL UNIQUE,
	`arguments`	TEXT
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
	`name`	TEXT NOT NULL UNIQUE,
	`active`	INTEGER NOT NULL
);
INSERT INTO `group` VALUES ('common',1);
CREATE TABLE IF NOT EXISTS `environment` (
	`name`	TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS `enforce_type` (
	`name`	TEXT NOT NULL,
	`description`	TEXT NOT NULL
);
INSERT INTO `enforce_type` VALUES ('inherit','Effective permission calculated at runtime');
INSERT INTO `enforce_type` VALUES ('grant','Explicitly granted access');
INSERT INTO `enforce_type` VALUES ('deny','Explicitly denied access');
CREATE TABLE IF NOT EXISTS `application` (
	`name`	TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS `access_type` (
	`name`	TEXT,
	`description`	TEXT
);
INSERT INTO `access_type` VALUES ('read','Allows read access');
INSERT INTO `access_type` VALUES ('write','read and write access');
INSERT INTO `access_type` VALUES ('exec','read, write and exec access');
COMMIT;
