-- ========================================================
-- STUFAC: Student & Faculty Talent Alignment Platform
-- Complete MySQL Database Export & Setup Script
-- ========================================================

CREATE DATABASE IF NOT EXISTS `stufac_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `stufac_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Table structure for `applications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `applications`;
CREATE TABLE `applications` (
  `application_id` varchar(50) NOT NULL,
  `student_id` varchar(50) DEFAULT NULL,
  `student_name` varchar(150) DEFAULT NULL,
  `student_email` varchar(150) DEFAULT NULL,
  `opportunity_id` varchar(50) DEFAULT NULL,
  `opportunity_title` varchar(255) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `applied_date` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'Applied',
  `last_updated` varchar(100) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `applications` (5 records)
INSERT INTO `applications` (`application_id`, `student_id`, `student_name`, `student_email`, `opportunity_id`, `opportunity_title`, `organization`, `applied_date`, `status`, `last_updated`, `notes`) VALUES ('APP-1018055', '2', 'Raju', 'raju@raisoni.net', '002858fb-98de-4963-be17-0bc561e0f887', 'Frontend Engineering Intern', 'Acme Corporation', '2026-09-20', 'Shortlisted', '2026-09-20T17:37:34Z', 'Status updated to Shortlisted by Faculty.');
INSERT INTO `applications` (`application_id`, `student_id`, `student_name`, `student_email`, `opportunity_id`, `opportunity_title`, `organization`, `applied_date`, `status`, `last_updated`, `notes`) VALUES ('APP-64033', '1', 'Ayudh', 'ayudh@raisoni.net', 'faf1081d-e292-4d90-ae68-7f1e2fe38399', 'AI Research Assistant', 'Stark Industries', '2026-09-21', 'Applied', '2026-09-20T18:47:44Z', 'Applied via Student Portal');
INSERT INTO `applications` (`application_id`, `student_id`, `student_name`, `student_email`, `opportunity_id`, `opportunity_title`, `organization`, `applied_date`, `status`, `last_updated`, `notes`) VALUES ('APP-950382', '2', 'Raju', 'raju@raisoni.net', 'faf1081d-e292-4d90-ae68-7f1e2fe38399', 'AI Research Assistant', 'Stark Industries', '2026-09-20', 'Applied', '2026-09-20T16:15:50Z', 'Applied via Student Portal');
INSERT INTO `applications` (`application_id`, `student_id`, `student_name`, `student_email`, `opportunity_id`, `opportunity_title`, `organization`, `applied_date`, `status`, `last_updated`, `notes`) VALUES ('APP-9582780', '1', 'Ayudh', 'ayudh@raisoni.net', '002858fb-98de-4963-be17-0bc561e0f887', 'Frontend Engineering Intern', 'Acme Corporation', '2026-09-21', 'Applied', '2026-09-20T18:39:42Z', 'Applied via Student Portal');
INSERT INTO `applications` (`application_id`, `student_id`, `student_name`, `student_email`, `opportunity_id`, `opportunity_title`, `organization`, `applied_date`, `status`, `last_updated`, `notes`) VALUES ('APP-9969169', '1', 'Ayudh', 'ayudh@raisoni.net', '28a7a484-01fe-4e9b-856f-8600d29e56cb', 'Rural Development Volunteer', 'Global Hope Foundation', '2026-09-21', 'Applied', '2026-09-20T18:46:09Z', 'Applied via Student Portal');

-- --------------------------------------------------------
-- Table structure for `audit_log_entries`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `audit_log_entries`;
CREATE TABLE `audit_log_entries` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `metadata` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `actor_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `audit_log_entries_chk_1` CHECK ((json_valid(`metadata`) or (`metadata` is null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `auth_group`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `auth_group_permissions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `auth_permission`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `auth_permission` (52 records)
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (1, 1, 'add_logentry', 'Can add log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (2, 1, 'change_logentry', 'Can change log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (3, 1, 'delete_logentry', 'Can delete log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (4, 1, 'view_logentry', 'Can view log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (5, 2, 'add_permission', 'Can add permission');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (6, 2, 'change_permission', 'Can change permission');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (7, 2, 'delete_permission', 'Can delete permission');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (8, 2, 'view_permission', 'Can view permission');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (9, 3, 'add_group', 'Can add group');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (10, 3, 'change_group', 'Can change group');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (11, 3, 'delete_group', 'Can delete group');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (12, 3, 'view_group', 'Can view group');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (13, 4, 'add_user', 'Can add user');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (14, 4, 'change_user', 'Can change user');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (15, 4, 'delete_user', 'Can delete user');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (16, 4, 'view_user', 'Can view user');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (17, 5, 'add_contenttype', 'Can add content type');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (18, 5, 'change_contenttype', 'Can change content type');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (19, 5, 'delete_contenttype', 'Can delete content type');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (20, 5, 'view_contenttype', 'Can view content type');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (21, 6, 'add_session', 'Can add session');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (22, 6, 'change_session', 'Can change session');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (23, 6, 'delete_session', 'Can delete session');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (24, 6, 'view_session', 'Can view session');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (25, 7, 'add_totpdevice', 'Can add TOTP device');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (26, 7, 'change_totpdevice', 'Can change TOTP device');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (27, 7, 'delete_totpdevice', 'Can delete TOTP device');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (28, 7, 'view_totpdevice', 'Can view TOTP device');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (29, 8, 'add_faculty', 'Can add faculty');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (30, 8, 'change_faculty', 'Can change faculty');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (31, 8, 'delete_faculty', 'Can delete faculty');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (32, 8, 'view_faculty', 'Can view faculty');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (33, 9, 'add_auditlogentry', 'Can add audit log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (34, 9, 'change_auditlogentry', 'Can change audit log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (35, 9, 'delete_auditlogentry', 'Can delete audit log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (36, 9, 'view_auditlogentry', 'Can view audit log entry');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (37, 10, 'add_organization', 'Can add organization');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (38, 10, 'change_organization', 'Can change organization');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (39, 10, 'delete_organization', 'Can delete organization');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (40, 10, 'view_organization', 'Can view organization');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (41, 11, 'add_opportunity', 'Can add opportunity');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (42, 11, 'change_opportunity', 'Can change opportunity');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (43, 11, 'delete_opportunity', 'Can delete opportunity');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (44, 11, 'view_opportunity', 'Can view opportunity');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (45, 12, 'add_certificate', 'Can add certificate');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (46, 12, 'change_certificate', 'Can change certificate');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (47, 12, 'delete_certificate', 'Can delete certificate');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (48, 12, 'view_certificate', 'Can view certificate');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (49, 13, 'add_studentverificationrequest', 'Can add student verification request');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (50, 13, 'change_studentverificationrequest', 'Can change student verification request');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (51, 13, 'delete_studentverificationrequest', 'Can delete student verification request');
INSERT INTO `auth_permission` (`id`, `content_type_id`, `codename`, `name`) VALUES (52, 13, 'view_studentverificationrequest', 'Can view student verification request');

-- --------------------------------------------------------
-- Table structure for `auth_user`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `auth_user` (7 records)
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (18, 'pbkdf2_sha256$1000000$mkAK7Y9qzaUAvaaqU2xydN$DDA9tK34mXDjjwL89fgvfbuzx0+/Pm2P+4NNX8wqxpg=', NULL, 0, 'fac_mod', 'Connor', 'mod@saiotaf.edu', 0, 1, '2026-08-26 11:48:54', 'Sarah');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (19, 'pbkdf2_sha256$1000000$fvy9lxPgqrRRBSVhOGub8H$xzjqrPmjrlnZJezRi1Ir61TlgHivXCU/cc8yVwZgm0g=', NULL, 0, 'fac_mfa', 'Doe', 'admin@saiotaf.edu', 0, 1, '2026-08-26 11:48:55', 'John');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (20, 'pbkdf2_sha256$1000000$CaE1uwUu9giZZRsimKJGs1$MIScdfukoH1VjgTjHOvA/3pDFpbzCvtOwt9UgjmSf38=', NULL, 0, 'fac_po', 'Miller', 'po@saiotaf.edu', 0, 1, '2026-08-26 11:48:59', 'Robert');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (21, 'pbkdf2_sha256$1000000$tAVIYYuTpNwSzYi85rkl3t$to0vEmysp5+JXC7D2v89IbKB4n64rIYSWPlvS0nB5tE=', NULL, 0, 'fac_ece', 'Rostova', 'ece_head@saiotaf.edu', 0, 1, '2026-08-26 11:49:02', 'Elena');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (22, 'pbkdf2_sha256$1000000$BZ97H7Qtuiu5W7H8CDKP3X$eoBFYH5fgvzmCIj5bi172AleNrk3Rdofcadqy1ohqow=', NULL, 0, 'sumit', 'fokmare', 'sumit@gmail.com', 0, 1, '2026-08-26 15:52:26', 'sumit');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (23, 'pbkdf2_sha256$1200000$yMPJxVpETGYp5XejaL4Vyj$xmvwR9vZgyCf011nz4Xue6RBbqyLTG/mOIARv8snS6s=', NULL, 0, 'ashish123', 'kakne', 'ashishkakne@raisoni.net', 0, 1, '2026-09-20 15:10:39', 'ashish');
INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `first_name`) VALUES (24, 'pbkdf2_sha256$1200000$5OXawxV3okSo04HxB4U9rp$1s0KviniSQR1Mz6cKABoh+N9turqbSVFYbgLhbP1a9w=', NULL, 0, 'shivam12', 'patil', 'shivam@raisoni.net', 0, 1, '2026-09-20 18:33:13', 'shivam');

-- --------------------------------------------------------
-- Table structure for `auth_user_groups`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE `auth_user_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `auth_user_user_permissions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE `auth_user_user_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `certificates`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `certificates`;
CREATE TABLE `certificates` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issue_date` date DEFAULT NULL,
  `verification_status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verified_at` datetime DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `verified_by_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opportunity_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `organization_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `django_admin_log`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `object_id` text COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `action_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `django_content_type`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `django_content_type` (13 records)
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (4, 'auth', 'user');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (5, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (6, 'sessions', 'session');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (7, 'otp_totp', 'totpdevice');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (8, 'faculty_app', 'faculty');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (9, 'faculty_app', 'auditlogentry');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (10, 'faculty_app', 'organization');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (11, 'faculty_app', 'opportunity');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (12, 'faculty_app', 'certificate');
INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES (13, 'faculty_app', 'studentverificationrequest');

-- --------------------------------------------------------
-- Table structure for `django_migrations`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `django_migrations` (22 records)
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (1, 'contenttypes', '0001_initial', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (2, 'auth', '0001_initial', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (3, 'admin', '0001_initial', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (4, 'admin', '0002_logentry_remove_auto_add', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (5, 'admin', '0003_logentry_add_action_flag_choices', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (6, 'contenttypes', '0002_remove_content_type_name', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (7, 'auth', '0002_alter_permission_name_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (8, 'auth', '0003_alter_user_email_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (9, 'auth', '0004_alter_user_username_opts', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (10, 'auth', '0005_alter_user_last_login_null', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (11, 'auth', '0006_require_contenttypes_0002', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (12, 'auth', '0007_alter_validators_add_error_messages', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (13, 'auth', '0008_alter_user_username_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (14, 'auth', '0009_alter_user_last_name_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (15, 'auth', '0010_alter_group_name_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (16, 'auth', '0011_update_proxy_permissions', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (17, 'auth', '0012_alter_user_first_name_max_length', '2026-08-10 13:04:13');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (18, 'faculty_app', '0001_initial', '2026-08-10 13:04:14');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (19, 'otp_totp', '0001_initial', '2026-08-10 13:04:14');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (20, 'otp_totp', '0002_auto_20190420_0723', '2026-08-10 13:04:14');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (21, 'otp_totp', '0003_add_timestamps', '2026-08-10 13:04:15');
INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES (22, 'sessions', '0001_initial', '2026-08-10 13:04:15');

-- --------------------------------------------------------
-- Table structure for `django_session`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `faculty`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `faculty`;
CREATE TABLE `faculty` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mfa_enabled` tinyint(1) NOT NULL,
  `mfa_secret` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `faculty` (7 records)
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-08-26 11:48:59', '2026-08-26 11:48:59', '30ffa24c452b4ae49a8e2066e0a71d04', 'FAC102', 'Information Technology', 'DEPARTMENT_ADMIN', 1, 'JBSWY3DPEHPK3PXP', 1, 19);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-08-26 15:52:27', '2026-08-26 15:52:27', '67e7e907ce56401c940a7e680e8c4637', '12', 'cs', 'MODERATOR', 0, NULL, 1, 22);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-09-20 15:10:40', '2026-09-20 15:10:40', '729d873d050649d9978e41358386e97a', '012345', 'it', 'TPO_INCHARGE', 0, NULL, 1, 23);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-09-20 18:33:13', '2026-09-20 18:33:13', 'b1f8d6943de44ffc8625025640504506', '1280', 'It', 'TPO_INCHARGE', 0, NULL, 1, 24);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', 'c9b1009b0f4c41e69cc732611eb5ad73', 'FAC104', 'Electronics & Communication', 'DEPARTMENT_ADMIN', 0, NULL, 1, 21);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-08-26 11:48:55', '2026-08-26 11:48:55', 'cf3c28ae089a4a4fa7d8dbb9ec63a706', 'FAC101', 'Computer Science', 'MODERATOR', 0, NULL, 1, 18);
INSERT INTO `faculty` (`created_at`, `updated_at`, `id`, `employee_id`, `department`, `role`, `mfa_enabled`, `mfa_secret`, `is_active`, `user_id`) VALUES ('2026-08-26 11:49:02', '2026-08-26 11:49:02', 'e9751eb458f641f886eb433bb0ca38f0', 'FAC103', 'Training & Placement', 'PLACEMENT_OFFICER', 0, NULL, 1, 20);

-- --------------------------------------------------------
-- Table structure for `notifications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` varchar(50) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text,
  `timestamp` varchar(100) DEFAULT NULL,
  `read` int DEFAULT '0',
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Table structure for `opportunities`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `opportunities`;
CREATE TABLE `opportunities` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `opportunity_type` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `required_skills` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `compensation_amount` decimal(10,0) DEFAULT NULL,
  `compensation_currency` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_unpaid` tinyint(1) NOT NULL,
  `work_mode` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_weeks` smallint unsigned DEFAULT NULL,
  `application_deadline` datetime NOT NULL,
  `positions_available` smallint unsigned NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `approved_by_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `posted_by_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `organization_id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `opportunities_chk_1` CHECK ((json_valid(`required_skills`) or (`required_skills` is null))),
  CONSTRAINT `opportunities_chk_2` CHECK ((`duration_weeks` >= 0)),
  CONSTRAINT `opportunities_chk_3` CHECK ((`positions_available` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `opportunities` (3 records)
INSERT INTO `opportunities` (`created_at`, `updated_at`, `id`, `title`, `opportunity_type`, `description`, `required_skills`, `compensation_amount`, `compensation_currency`, `is_unpaid`, `work_mode`, `location`, `duration_weeks`, `application_deadline`, `positions_available`, `status`, `approved_at`, `rejection_reason`, `approved_by_id`, `posted_by_id`, `organization_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', '002858fb98de4963be170bc561e0f887', 'Frontend Engineering Intern', 'INTERNSHIP', 'Join our frontend UI/UX team. You will build highly responsive web pages using React and Bootstrap.', '["React", "JavaScript", "HTML/CSS", "Bootstrap"]', '25000', 'INR', 0, 'HYBRID', 'Bangalore, KA', 12, '2026-09-25 11:49:04', 3, 'APPROVED', '2026-08-17 11:49:04', NULL, 'cf3c28ae089a4a4fa7d8dbb9ec63a706', 'cf3c28ae089a4a4fa7d8dbb9ec63a706', '09eaa925be944e2ca2444c09648bfc88');
INSERT INTO `opportunities` (`created_at`, `updated_at`, `id`, `title`, `opportunity_type`, `description`, `required_skills`, `compensation_amount`, `compensation_currency`, `is_unpaid`, `work_mode`, `location`, `duration_weeks`, `application_deadline`, `positions_available`, `status`, `approved_at`, `rejection_reason`, `approved_by_id`, `posted_by_id`, `organization_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', '28a7a48401fe4e9b856f8600d29e56cb', 'Rural Development Volunteer', 'NGO', 'Help coordinate literacy campaigns and community outreach in rural learning hubs.', '["Public Speaking", "Social Work", "Local Language"]', NULL, 'INR', 1, 'ONSITE', 'Wayanad, KL', 8, '2026-09-10 11:49:04', 5, 'APPROVED', NULL, NULL, NULL, '30ffa24c452b4ae49a8e2066e0a71d04', '6c7de2e5b9ec4c93b2ae856296fbc4a2');
INSERT INTO `opportunities` (`created_at`, `updated_at`, `id`, `title`, `opportunity_type`, `description`, `required_skills`, `compensation_amount`, `compensation_currency`, `is_unpaid`, `work_mode`, `location`, `duration_weeks`, `application_deadline`, `positions_available`, `status`, `approved_at`, `rejection_reason`, `approved_by_id`, `posted_by_id`, `organization_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', 'faf1081de2924d90ae687f1e2fe38399', 'AI Research Assistant', 'INTERNSHIP', 'Assist in training machine learning models for computer vision and autonomous robotics.', '["Python", "PyTorch", "Linear Algebra", "Machine Learning"]', '50000', 'INR', 0, 'REMOTE', NULL, 24, '2026-10-10 11:49:04', 2, 'APPROVED', '2026-08-22 11:49:04', NULL, '30ffa24c452b4ae49a8e2066e0a71d04', '30ffa24c452b4ae49a8e2066e0a71d04', '659cab0e06904773844e6e01685fd5be');

-- --------------------------------------------------------
-- Table structure for `organizations`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `organizations`;
CREATE TABLE `organizations` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `org_type` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `website` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verification_status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verified_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `verified_by_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `organizations` (3 records)
INSERT INTO `organizations` (`created_at`, `updated_at`, `id`, `name`, `org_type`, `website`, `contact_name`, `contact_email`, `contact_phone`, `verification_status`, `verified_at`, `notes`, `verified_by_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', '09eaa925be944e2ca2444c09648bfc88', 'Acme Corporation', 'COMPANY', 'https://acme.example.com', 'Wiley Coyote', 'wiley@acme.example.com', '+15550199', 'VERIFIED', '2026-08-16 11:49:04', 'High-tech engineering partner.', 'cf3c28ae089a4a4fa7d8dbb9ec63a706');
INSERT INTO `organizations` (`created_at`, `updated_at`, `id`, `name`, `org_type`, `website`, `contact_name`, `contact_email`, `contact_phone`, `verification_status`, `verified_at`, `notes`, `verified_by_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', '659cab0e06904773844e6e01685fd5be', 'Stark Industries', 'COMPANY', 'https://stark.example.com', 'Pepper Potts', 'pepper@stark.example.com', NULL, 'VERIFIED', '2026-08-21 11:49:04', 'Defense and clean energy titan.', '30ffa24c452b4ae49a8e2066e0a71d04');
INSERT INTO `organizations` (`created_at`, `updated_at`, `id`, `name`, `org_type`, `website`, `contact_name`, `contact_email`, `contact_phone`, `verification_status`, `verified_at`, `notes`, `verified_by_id`) VALUES ('2026-08-26 11:49:04', '2026-08-26 11:49:04', '6c7de2e5b9ec4c93b2ae856296fbc4a2', 'Global Hope Foundation', 'NGO', 'https://globalhope.example.org', 'Jane Goodall', 'jane@globalhope.example.org', NULL, 'PENDING', NULL, 'Non-profit focused on ecology.', NULL);

-- --------------------------------------------------------
-- Table structure for `otp_totp_totpdevice`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `otp_totp_totpdevice`;
CREATE TABLE `otp_totp_totpdevice` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `confirmed` tinyint(1) NOT NULL,
  `key` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `step` smallint unsigned NOT NULL,
  `t0` bigint NOT NULL,
  `digits` smallint unsigned NOT NULL,
  `tolerance` smallint unsigned NOT NULL,
  `drift` smallint NOT NULL,
  `last_t` bigint NOT NULL,
  `user_id` int NOT NULL,
  `throttling_failure_count` int unsigned NOT NULL,
  `throttling_failure_timestamp` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `otp_totp_totpdevice_chk_1` CHECK ((`step` >= 0)),
  CONSTRAINT `otp_totp_totpdevice_chk_2` CHECK ((`digits` >= 0)),
  CONSTRAINT `otp_totp_totpdevice_chk_3` CHECK ((`tolerance` >= 0)),
  CONSTRAINT `otp_totp_totpdevice_chk_4` CHECK ((`throttling_failure_count` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `profile`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `profile`;
CREATE TABLE `profile` (
  `student_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `roll_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dept` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cgpa` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linkedin` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `github` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `profile_completion_pct` int DEFAULT NULL,
  `verified_by_faculty` int DEFAULT NULL,
  `consent_resume_sharing` int DEFAULT NULL,
  `admission_year` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passout_year` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `program` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `resume`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume` (
  `resume_id` varchar(50) NOT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `file_size` varchar(50) DEFAULT NULL,
  `upload_date` varchar(100) DEFAULT NULL,
  `version` int DEFAULT '1',
  `status` varchar(50) DEFAULT 'Parsed',
  `parsed_data` longtext,
  `file_url` varchar(500) DEFAULT NULL,
  `student_id` varchar(50) DEFAULT NULL,
  `student_email` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`resume_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `resume` (4 records)
INSERT INTO `resume` (`resume_id`, `filename`, `file_size`, `upload_date`, `version`, `status`, `parsed_data`, `file_url`, `student_id`, `student_email`) VALUES ('RES_1902', 'Ayudh_Pogulwar_AI_Intern.pdf', '0.2 MB', '2026-09-20T16:18:28Z', 1, 'Parsed', '{"skills": [{"skill_id": "SK-2188", "skill_name": "Python", "category": "Programming"}, {"skill_id": "SK-6370", "skill_name": "JavaScript", "category": "Programming"}, {"skill_id": "SK-5643", "skill_name": "TypeScript", "category": "Programming"}, {"skill_id": "SK-2723", "skill_name": "Java", "category": "Programming"}, {"skill_id": "SK-3165", "skill_name": "C++", "category": "Programming"}, {"skill_id": "SK-4632", "skill_name": "C", "category": "Programming"}, {"skill_id": "SK-2599", "skill_name": "HTML", "category": "Web Dev"}, {"skill_id": "SK-5543", "skill_name": "HTML5", "category": "Web Dev"}, {"skill_id": "SK-8328", "skill_name": "CSS", "category": "Web Dev"}, {"skill_id": "SK-3638", "skill_name": "CSS3", "category": "Web Dev"}, {"skill_id": "SK-5624", "skill_name": "React", "category": "Web Dev"}, {"skill_id": "SK-4270", "skill_name": "React.js", "category": "Web Dev"}, {"skill_id": "SK-9543", "skill_name": "Spring Boot", "category": "Web Dev"}, {"skill_id": "SK-3472", "skill_name": "SQL", "category": "Database"}, {"skill_id": "SK-3883", "skill_name": "MySQL", "category": "Database"}, {"skill_id": "SK-1137", "skill_name": "Git", "category": "DevOps"}, {"skill_id": "SK-4840", "skill_name": "GitHub", "category": "DevOps"}, {"skill_id": "SK-7210", "skill_name": "Problem Solving", "category": "Core"}, {"skill_id": "SK-4620", "skill_name": "Data Structures", "category": "Core"}, {"skill_id": "SK-2148", "skill_name": "Algorithms", "category": "Core"}], "skill_names": ["Python", "JavaScript", "TypeScript", "Java", "C++", "C", "HTML", "HTML5", "CSS", "CSS3", "React", "React.js", "Spring Boot", "SQL", "MySQL", "Git", "GitHub", "Problem Solving", "Data Structures", "Algorithms"], "experience": ["Extracted Experience Highlight: Software Engineering & Project Architecture"], "education": "B.Tech Computer Science & Engineering"}', 'http://localhost:8000/media/resumes/RES_1902_Ayudh_Pogulwar_AI_Intern.pdf', '2', 'raju@raisoni.net');
INSERT INTO `resume` (`resume_id`, `filename`, `file_size`, `upload_date`, `version`, `status`, `parsed_data`, `file_url`, `student_id`, `student_email`) VALUES ('RES_3298', 'Ayudh_Pogulwar_AI_Intern.pdf', '0.2 MB', '2026-09-20T15:51:47Z', 1, 'Parsed', '{"skills": [{"skill_id": "SK-8137", "skill_name": "Python", "category": "Programming"}, {"skill_id": "SK-2442", "skill_name": "JavaScript", "category": "Programming"}, {"skill_id": "SK-5992", "skill_name": "TypeScript", "category": "Programming"}, {"skill_id": "SK-1717", "skill_name": "Java", "category": "Programming"}, {"skill_id": "SK-6554", "skill_name": "C++", "category": "Programming"}, {"skill_id": "SK-1437", "skill_name": "C", "category": "Programming"}, {"skill_id": "SK-7831", "skill_name": "HTML", "category": "Web Dev"}, {"skill_id": "SK-4981", "skill_name": "HTML5", "category": "Web Dev"}, {"skill_id": "SK-7100", "skill_name": "CSS", "category": "Web Dev"}, {"skill_id": "SK-8950", "skill_name": "CSS3", "category": "Web Dev"}, {"skill_id": "SK-3011", "skill_name": "React", "category": "Web Dev"}, {"skill_id": "SK-6594", "skill_name": "React.js", "category": "Web Dev"}, {"skill_id": "SK-3626", "skill_name": "Spring Boot", "category": "Web Dev"}, {"skill_id": "SK-6418", "skill_name": "SQL", "category": "Database"}, {"skill_id": "SK-8242", "skill_name": "MySQL", "category": "Database"}, {"skill_id": "SK-3122", "skill_name": "Git", "category": "DevOps"}, {"skill_id": "SK-8405", "skill_name": "GitHub", "category": "DevOps"}, {"skill_id": "SK-6392", "skill_name": "Problem Solving", "category": "Core"}, {"skill_id": "SK-6343", "skill_name": "Data Structures", "category": "Core"}, {"skill_id": "SK-3426", "skill_name": "Algorithms", "category": "Core"}], "skill_names": ["Python", "JavaScript", "TypeScript", "Java", "C++", "C", "HTML", "HTML5", "CSS", "CSS3", "React", "React.js", "Spring Boot", "SQL", "MySQL", "Git", "GitHub", "Problem Solving", "Data Structures", "Algorithms"], "experience": ["Extracted Experience Highlight: Software Engineering & Project Architecture"], "education": "B.Tech Computer Science & Engineering"}', 'http://localhost:8000/media/resumes/RES_3298_Ayudh_Pogulwar_AI_Intern.pdf', NULL, NULL);
INSERT INTO `resume` (`resume_id`, `filename`, `file_size`, `upload_date`, `version`, `status`, `parsed_data`, `file_url`, `student_id`, `student_email`) VALUES ('RES_4886', 'my_resume.pdf', '0.0 MB', '2026-09-20T15:46:12Z', 1, 'Parsed', '{"skills": [{"skill_id": "SK-6678", "skill_name": "Python", "category": "Programming"}, {"skill_id": "SK-5724", "skill_name": "React", "category": "Web Dev"}, {"skill_id": "SK-8016", "skill_name": "Django", "category": "Web Dev"}, {"skill_id": "SK-8278", "skill_name": "SQL", "category": "Database"}], "skill_names": ["Python", "React", "Django", "SQL"], "experience": ["Extracted Experience Highlight: Software Engineering & Project Architecture"], "education": "B.Tech Computer Science & Engineering"}', 'http://127.0.0.1:8000/media/resumes/RES_4886_my_resume.pdf', NULL, NULL);
INSERT INTO `resume` (`resume_id`, `filename`, `file_size`, `upload_date`, `version`, `status`, `parsed_data`, `file_url`, `student_id`, `student_email`) VALUES ('RES_9714', 'Data_Scientist_Resume.pdf', '0.0 MB', '2026-09-20T16:14:06Z', 1, 'Parsed', '{"skills": [{"skill_id": "SK-3473", "skill_name": "Python", "category": "Programming"}, {"skill_id": "SK-2010", "skill_name": "SQL", "category": "Database"}, {"skill_id": "SK-8410", "skill_name": "Machine Learning", "category": "AI/ML"}, {"skill_id": "SK-6696", "skill_name": "Data Science", "category": "AI/ML"}, {"skill_id": "SK-6037", "skill_name": "PyTorch", "category": "AI/ML"}, {"skill_id": "SK-3284", "skill_name": "Pandas", "category": "AI/ML"}, {"skill_id": "SK-5006", "skill_name": "AWS", "category": "DevOps"}, {"skill_id": "SK-1238", "skill_name": "Docker", "category": "DevOps"}, {"skill_id": "SK-6767", "skill_name": "Linux", "category": "DevOps"}], "skill_names": ["Python", "SQL", "Machine Learning", "Data Science", "PyTorch", "Pandas", "AWS", "Docker", "Linux"], "experience": ["Extracted Experience Highlight: Software Engineering & Project Architecture"], "education": "B.Tech Computer Science & Engineering"}', 'http://127.0.0.1:8000/media/resumes/RES_9714_Data_Scientist_Resume.pdf', '1', 'ayudh@raisoni.net');

-- --------------------------------------------------------
-- Table structure for `skills`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `skills`;
CREATE TABLE `skills` (
  `skill_id` varchar(50) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `source` varchar(50) DEFAULT 'manual',
  `student_id` varchar(50) DEFAULT NULL,
  `student_email` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `skills` (29 records)
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-1137', 'Git', 'DevOps', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-1238', 'Docker', 'DevOps', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-2010', 'SQL', 'Database', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-2148', 'Algorithms', 'Core', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-2188', 'Python', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-2599', 'HTML', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-2723', 'Java', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3165', 'C++', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3284', 'Pandas', 'AI/ML', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3472', 'SQL', 'Database', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3473', 'Python', 'Programming', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3638', 'CSS3', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-3883', 'MySQL', 'Database', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-4270', 'React.js', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-4620', 'Data Structures', 'Core', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-4632', 'C', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-4840', 'GitHub', 'DevOps', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-5006', 'AWS', 'DevOps', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-5543', 'HTML5', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-5624', 'React', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-5643', 'TypeScript', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-6037', 'PyTorch', 'AI/ML', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-6370', 'JavaScript', 'Programming', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-6696', 'Data Science', 'AI/ML', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-6767', 'Linux', 'DevOps', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-7210', 'Problem Solving', 'Core', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-8328', 'CSS', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-8410', 'Machine Learning', 'AI/ML', 'parsed', '1', 'ayudh@raisoni.net');
INSERT INTO `skills` (`skill_id`, `skill_name`, `category`, `source`, `student_id`, `student_email`) VALUES ('SK-9543', 'Spring Boot', 'Web Dev', 'parsed', '2', 'raju@raisoni.net');

-- --------------------------------------------------------
-- Table structure for `student_profiles`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `student_profiles`;
CREATE TABLE `student_profiles` (
  `student_id` int NOT NULL,
  `roll_number` varchar(50) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `department` varchar(150) DEFAULT NULL,
  `graduation_year` int DEFAULT '2027',
  `cgpa` decimal(4,2) DEFAULT '0.00',
  `preferred_opportunity_type` varchar(50) DEFAULT 'Both',
  `verification_status` varchar(50) DEFAULT 'Pending',
  `placement_readiness_score` decimal(5,2) DEFAULT '0.00',
  `phone_number` varchar(50) DEFAULT NULL,
  `linkedin` varchar(255) DEFAULT NULL,
  `github` varchar(255) DEFAULT NULL,
  `bio` text,
  `active_resume_id` varchar(50) DEFAULT NULL,
  `passout_year` int DEFAULT NULL,
  `admission_year` int DEFAULT NULL,
  `program` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `student_profiles` (2 records)
INSERT INTO `student_profiles` (`student_id`, `roll_number`, `first_name`, `last_name`, `department`, `graduation_year`, `cgpa`, `preferred_opportunity_type`, `verification_status`, `placement_readiness_score`, `phone_number`, `linkedin`, `github`, `bio`, `active_resume_id`, `passout_year`, `admission_year`, `program`) VALUES (1, '2023CS8796', 'Ayudh', '', 'Civil', 2027, '9.00', 'Both', 'Approved', '0.00', '789456', NULL, NULL, NULL, 'RES_1902', 2027, 2022, 'B.Tech');
INSERT INTO `student_profiles` (`student_id`, `roll_number`, `first_name`, `last_name`, `department`, `graduation_year`, `cgpa`, `preferred_opportunity_type`, `verification_status`, `placement_readiness_score`, `phone_number`, `linkedin`, `github`, `bio`, `active_resume_id`, `passout_year`, `admission_year`, `program`) VALUES (2, '2023CS5937', 'Raju', '', 'Computer Science & Engineering', 2027, '0.00', 'Both', 'Approved', '0.00', NULL, NULL, NULL, NULL, 'RES_1902', NULL, NULL, NULL);

-- --------------------------------------------------------
-- Table structure for `student_verification_requests`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `student_verification_requests`;
CREATE TABLE `student_verification_requests` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roll_number` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `year_of_study` smallint unsigned NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `flag_reason` text COLLATE utf8mb4_unicode_ci,
  `reviewed_by_id` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_id` (`student_id`),
  CONSTRAINT `student_verification_requests_chk_1` CHECK ((`year_of_study` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `student_verification_requests` (3 records)
INSERT INTO `student_verification_requests` (`created_at`, `updated_at`, `id`, `student_id`, `full_name`, `roll_number`, `department`, `year_of_study`, `email`, `status`, `reviewed_at`, `flag_reason`, `reviewed_by_id`) VALUES ('2026-08-26 12:19:47', '2026-08-26 17:06:20', '030018c78e90458398d0de8371793463', '109bde8edd4f47acb0a95a05a5a3ac25', 'Ayudh', '2023CS8697', 'Computer Science & Engineering', 3, 'ayudh@ghrietn.raisoni.net', 'APPROVED', '2026-08-26 17:06:20', NULL, NULL);
INSERT INTO `student_verification_requests` (`created_at`, `updated_at`, `id`, `student_id`, `full_name`, `roll_number`, `department`, `year_of_study`, `email`, `status`, `reviewed_at`, `flag_reason`, `reviewed_by_id`) VALUES ('2026-09-20 16:20:05', '2026-09-20 17:32:28', 'a6bd3eca0d21406bb45354a0d2c9546d', 'e9affff227124503bf448570e41ce711', 'Ayudh', '2023CS8796', 'Civil', 3, 'ayudh@raisoni.net', 'APPROVED', '2026-09-20 17:32:28', NULL, NULL);
INSERT INTO `student_verification_requests` (`created_at`, `updated_at`, `id`, `student_id`, `full_name`, `roll_number`, `department`, `year_of_study`, `email`, `status`, `reviewed_at`, `flag_reason`, `reviewed_by_id`) VALUES ('2026-09-20 16:20:05', '2026-09-20 18:38:54', 'c721ad76bd85431f850a190694057fdc', 'd8b2a34b61dc40b49a1537c9c4ed2ba3', 'Raju', '2023CS5937', 'Computer Science & Engineering', 3, 'raju@raisoni.net', 'APPROVED', '2026-09-20 18:38:54', NULL, NULL);

-- --------------------------------------------------------
-- Table structure for `users`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT 'Student',
  `is_active` int DEFAULT '1',
  `is_verified` int DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `users` (2 records)
INSERT INTO `users` (`user_id`, `email`, `password_hash`, `role`, `is_active`, `is_verified`) VALUES (1, 'ayudh@raisoni.net', '$2b$12$eImiTXuWVxfM37uY4JANjO2ZfW9X2m2kF8a2A2h1W5eG5f5S5S5S5', 'Student', 1, 1);
INSERT INTO `users` (`user_id`, `email`, `password_hash`, `role`, `is_active`, `is_verified`) VALUES (2, 'raju@raisoni.net', '$2b$12$eImiTXuWVxfM37uY4JANjO2ZfW9X2m2kF8a2A2h1W5eG5f5S5S5S5', 'Student', 1, 1);

SET FOREIGN_KEY_CHECKS = 1;
-- Complete database dump finished successfully.