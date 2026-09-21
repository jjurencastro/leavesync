/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: railway
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_fingerprint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_action` (`action`),
  CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES
(7,1,'login_success','user',1,NULL,'[]','216.247.84.154','c48d9944bc9cac726bb01e4c7116ada183b221f56d4bc143de0420a460562b81','2026-09-11 03:06:32'),
(9,1,'login_success','user',1,NULL,'[]','216.247.84.154','c48d9944bc9cac726bb01e4c7116ada183b221f56d4bc143de0420a460562b81','2026-09-11 03:07:22'),
(10,1,'webauthn_credential_registered','user',1,NULL,'[]','216.247.84.154','c48d9944bc9cac726bb01e4c7116ada183b221f56d4bc143de0420a460562b81','2026-09-11 03:07:50'),
(11,1,'webauthn_credential_removed','user',1,NULL,'[]','216.247.84.154','c48d9944bc9cac726bb01e4c7116ada183b221f56d4bc143de0420a460562b81','2026-09-11 03:07:55'),
(12,1,'login_failed','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:28:14'),
(13,1,'login_failed','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:28:15'),
(14,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:28:21'),
(15,1,'create_user','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:29:09'),
(18,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:29:46'),
(22,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:32:50'),
(26,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-11 04:35:16'),
(27,1,'create_user','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-11 04:35:58'),
(29,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-11 04:36:31'),
(31,1,'create_user','user',5,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-11 04:37:38'),
(32,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-11 04:38:09'),
(33,1,'login_success','user',1,NULL,'[]','138.84.134.51','e6e47f9e639167af5b2ee58d8cd6d961572ac0400411bd78bf24cd10d6ada5f3','2026-09-13 12:57:10'),
(34,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:18:58'),
(35,1,'create_user','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:19:37'),
(36,1,'create_user','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:20:20'),
(37,1,'create_user','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:21:08'),
(38,1,'update_user','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-14 00:21:42'),
(39,1,'update_user','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-14 00:21:45'),
(44,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:51:50'),
(52,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 00:59:22'),
(57,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:06:04'),
(63,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:26:55'),
(64,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:27:16'),
(65,1,'device_request_approved','device_change_request',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:27:27'),
(73,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:33:51'),
(78,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 01:55:46'),
(86,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 02:47:58'),
(87,1,'bulk_create_user','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 03:39:09'),
(88,1,'bulk_create_user','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 03:42:16'),
(89,1,'bulk_create_user','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-14 03:42:58'),
(90,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:00:18'),
(91,2,'password_set','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:00:33'),
(92,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:02:28'),
(93,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:05:26'),
(94,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:13:44'),
(95,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:13:47'),
(96,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:14:03'),
(97,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:14:29'),
(98,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:21:11'),
(99,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:21:37'),
(100,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:23:00'),
(101,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:24:11'),
(102,3,'login_success_google','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:24:24'),
(103,3,'password_set','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:24:34'),
(104,4,'login_success_google','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:25:26'),
(105,4,'password_set','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:25:37'),
(106,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:30:45'),
(107,4,'login_success','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:31:41'),
(108,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:32:10'),
(109,3,'create_leave_request','leave_request',4,NULL,'{\"bypass_reason\": null, \"assigned_supervisor_id\": null, \"original_supervisor_id\": 2, \"bypassed_supervisor_ids\": []}','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:32:33'),
(110,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:32:49'),
(111,2,'webauthn_credential_registered','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:33:24'),
(112,2,'approve_leave_request','leave_request',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:33:37'),
(113,4,'login_success','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:33:48'),
(114,4,'create_leave_request','leave_request',5,NULL,'{\"bypass_reason\": \"supervisor_on_approved_leave_or_inactive\", \"assigned_supervisor_id\": 2, \"original_supervisor_id\": 3, \"bypassed_supervisor_ids\": [3]}','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:34:09'),
(115,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:34:30'),
(116,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:34:58'),
(117,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:41:07'),
(118,4,'login_success','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:41:48'),
(119,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:42:29'),
(120,3,'login_success','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:52:08'),
(121,4,'login_success','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:53:49'),
(122,4,'update_leave_request','leave_request',5,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:54:19'),
(123,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:04:20'),
(124,3,'device_change_requested','user',3,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:06:12'),
(125,3,'login_failed_untrusted_device','user',3,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:06:12'),
(126,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:06:17'),
(127,1,'device_request_approved','device_change_request',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:07:34'),
(128,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:07:46'),
(129,3,'login_success','user',3,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:07:52'),
(130,3,'webauthn_credential_registered','user',3,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:08:10'),
(131,3,'approve_leave_request_supervisor','leave_request',5,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:08:25'),
(132,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:08:32'),
(133,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:08:58'),
(134,4,'device_change_requested','user',4,NULL,'[]','175.158.215.172','113dd0ea633d7f1287c677c0dd23d508bf4d4725fa12155a9dc9be250110aa82','2026-09-16 02:12:38'),
(135,4,'login_failed_untrusted_device','user',4,NULL,'[]','175.158.215.172','113dd0ea633d7f1287c677c0dd23d508bf4d4725fa12155a9dc9be250110aa82','2026-09-16 02:12:38'),
(136,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:13:04'),
(137,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:13:19'),
(138,3,'device_request_approved','device_change_request',3,NULL,'[]','203.177.49.42','a96d296d405dba857ed820c953249a063ef9444c11929b521f90895520d81ff7','2026-09-16 02:13:42'),
(139,4,'login_success','user',4,NULL,'[]','175.158.215.172','113dd0ea633d7f1287c677c0dd23d508bf4d4725fa12155a9dc9be250110aa82','2026-09-16 02:13:44'),
(140,4,'login_success','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:14:05'),
(141,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:14:31'),
(142,NULL,'bulk_create_user','user',5,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:03:22'),
(143,NULL,'bulk_create_user','user',6,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:03:22'),
(144,NULL,'bulk_create_user','user',7,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:03:23'),
(145,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:08:17'),
(146,2,'approve_leave_request','leave_request',5,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:08:36'),
(147,3,'login_success','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:08:52'),
(148,4,'login_success','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:09:12');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_change_requests`
--

DROP TABLE IF EXISTS `device_change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_change_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `fingerprint_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_info` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resolved_by` (`resolved_by`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `device_change_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `device_change_requests_ibfk_2` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_change_requests`
--

LOCK TABLES `device_change_requests` WRITE;
/*!40000 ALTER TABLE `device_change_requests` DISABLE KEYS */;
INSERT INTO `device_change_requests` VALUES
(2,3,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Chrome 152\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','203.177.49.42','Chrome 152','approved','2026-09-16 02:06:12','2026-09-16 02:07:34',1),
(3,4,'c430cbd64980373a8a3183c8953c11de250fe5176919a928ccda32964a69b926','{\"user_agent\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) CriOS\\/153.0.8010.24 Mobile\\/15E148 Safari\\/604.1\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"175.158.215.172\",\"browser\":\"Safari 604\",\"os\":\"iOS 26.5.0\",\"device\":\"iPhone\",\"screen_resolution\":\"414x717\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"iPhone\",\"hardware_concurrency\":4,\"device_memory\":\"unknown\"}','175.158.215.172','Safari 604','approved','2026-09-16 02:12:38','2026-09-16 02:13:42',3);
/*!40000 ALTER TABLE `device_change_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_fingerprints`
--

DROP TABLE IF EXISTS `device_fingerprints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_fingerprints` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `fingerprint_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_info` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_trusted` tinyint(1) DEFAULT '0',
  `last_used` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_fingerprint` (`fingerprint_hash`),
  CONSTRAINT `device_fingerprints_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_fingerprints`
--

LOCK TABLES `device_fingerprints` WRITE;
/*!40000 ALTER TABLE `device_fingerprints` DISABLE KEYS */;
INSERT INTO `device_fingerprints` VALUES
(1,1,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 02:14:31','2026-09-11 03:06:32','2026-09-16 02:14:31'),
(5,1,'c430cbd64980373a8a3183c8953c11de250fe5176919a928ccda32964a69b926','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"138.84.134.51\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x400\", \"hardware_concurrency\": 4}','138.84.134.51','Safari 604',1,'2026-09-13 12:57:10','2026-09-13 12:57:10','2026-09-13 12:57:10'),
(10,2,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 03:08:17','2026-09-16 01:00:33','2026-09-16 03:08:17'),
(11,3,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 03:08:52','2026-09-16 01:24:34','2026-09-16 03:08:52'),
(12,4,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 03:09:12','2026-09-16 01:25:37','2026-09-16 03:09:12'),
(13,3,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','203.177.49.42','Chrome 152',1,'2026-09-16 02:07:52','2026-09-16 02:07:34','2026-09-16 02:07:52'),
(14,4,'c430cbd64980373a8a3183c8953c11de250fe5176919a928ccda32964a69b926','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"175.158.215.172\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x717\", \"hardware_concurrency\": 4}','175.158.215.172','Safari 604',1,'2026-09-16 02:13:44','2026-09-16 02:13:42','2026-09-16 02:13:44');
/*!40000 ALTER TABLE `device_fingerprints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_signatures`
--

DROP TABLE IF EXISTS `digital_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `digital_signatures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_id` int NOT NULL,
  `document_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `signer_id` int NOT NULL,
  `signature_hash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `certificate_data` longtext COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NOT NULL,
  `is_valid` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_document_id` (`document_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_signer_id` (`signer_id`),
  CONSTRAINT `digital_signatures_ibfk_1` FOREIGN KEY (`signer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_signatures`
--

LOCK TABLES `digital_signatures` WRITE;
/*!40000 ALTER TABLE `digital_signatures` DISABLE KEYS */;
INSERT INTO `digital_signatures` VALUES
(1,4,'leave_request',2,'MEYCIQDUbIZl3TyFO0zI-V050jpy6wZYbRXT4fodKrAR3EGpHgIhAMMfOyecTe63P451fbMez1AzyD88sO-7SFw4-cr-F9Hb','{\"type\":\"webauthn\",\"signature\":\"MEYCIQDUbIZl3TyFO0zI-V050jpy6wZYbRXT4fodKrAR3EGpHgIhAMMfOyecTe63P451fbMez1AzyD88sO-7SFw4-cr-F9Hb\",\"credential_id\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"assertion\":{\"id\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"rawId\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiVEtlY1pNVVJqZ2Z2OE5YZGwxVUtWQnVXbHhJbDd5VXpmemczQzBNX3dmM0xycjNlazFCeTRzeFBFSEJBLXpISUotZ29TZWp2UUJhRHlManlISDVFdFEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEYCIQDUbIZl3TyFO0zI-V050jpy6wZYbRXT4fodKrAR3EGpHgIhAMMfOyecTe63P451fbMez1AzyD88sO-7SFw4-cr-F9Hb\",\"userHandle\":\"Mg\"}},\"challenge\":\"TKecZMURjgfv8NXdl1UKVBuWlxIl7yUzfzg3C0M_wf3Lrr3ek1By4sxPEHBA-zHIJ-goSejvQBaDyLjyHH5EtQ\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIJnMPXProk3ddOquEk+16Qk+C1F4GV4Ejh8Z3r5CTRoEIlggBilnAW5jCmSimgwvC9JszcnQsBIveElOugUI0vqUus4=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"cbaebdde935072e2cc4f107040fb31c827e82849e8ef401683c8b8f21c7e44b5\"}','2026-09-16 01:33:37',1,'2026-09-16 01:33:37'),
(2,5,'leave_request',3,'MEUCIGMbTidzezLeZjlTl3SdgNngehEkahRGpSmCiaF_wY2yAiEAyvxQkliSnhnKxTwBt5pdnsPQkivmZnvziiqTp-4wh1o','{\"type\":\"webauthn\",\"signature\":\"MEUCIGMbTidzezLeZjlTl3SdgNngehEkahRGpSmCiaF_wY2yAiEAyvxQkliSnhnKxTwBt5pdnsPQkivmZnvziiqTp-4wh1o\",\"credential_id\":\"598qWm9XTbiPWtG0n7XGuA\",\"assertion\":{\"id\":\"598qWm9XTbiPWtG0n7XGuA\",\"rawId\":\"598qWm9XTbiPWtG0n7XGuA\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoicFJFWDRjNnA0NEN6cDdCczNrOUlGUVFHQm54alhZUmVTWl96YW9Kd3hnX1kyMXhxdWJrVHlrb01pTy1GQnZFWjJmdDJnRG9Ld3Zqdm8zaU9FVGlVekEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIGMbTidzezLeZjlTl3SdgNngehEkahRGpSmCiaF_wY2yAiEAyvxQkliSnhnKxTwBt5pdnsPQkivmZnvziiqTp-4wh1o\",\"userHandle\":\"Mw\"}},\"challenge\":\"pREX4c6p44Czp7Bs3k9IFQQGBnxjXYReSZ_zaoJwxg_Y21xqubkTykoMiO-FBvEZ2ft2gDoKwvjvo3iOETiUzA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":3,\"credential\":{\"public_key\":\"pQECAyYgASFYIDyUFAh2OfPqOIV47tIWeV1Z5uFrHCpwdOPctrixLqUkIlggUQQeP22XiA+EEqC6GCaDZGeFh+8PUYC1Tfeap+ZHnMo=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"d8db5c6ab9b913ca4a0c88ef8506f119d9fb76803a0ac2f8efa3788e113894cc\"}','2026-09-16 02:08:25',1,'2026-09-16 02:08:25'),
(3,5,'leave_request',2,'MEUCIB1JEzCtlQ6wV-8WHVzs8dn5Jw3tCu5CcskytSI5Za_fAiEAgeP-2Nmj4co-LLY1dXc_90jg29WuXOEkAK74Mg-eOU4','{\"type\":\"webauthn\",\"signature\":\"MEUCIB1JEzCtlQ6wV-8WHVzs8dn5Jw3tCu5CcskytSI5Za_fAiEAgeP-2Nmj4co-LLY1dXc_90jg29WuXOEkAK74Mg-eOU4\",\"credential_id\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"assertion\":{\"id\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"rawId\":\"CW-8VR4Z_Ix9dUq6XOPqEg\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiOUpEeFJhcHhxQW1pZ055cEpkU2FVWmstZlFJcXM4OVdIUWZEMnRZMlVOWFkyMXhxdWJrVHlrb01pTy1GQnZFWjJmdDJnRG9Ld3Zqdm8zaU9FVGlVekEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIB1JEzCtlQ6wV-8WHVzs8dn5Jw3tCu5CcskytSI5Za_fAiEAgeP-2Nmj4co-LLY1dXc_90jg29WuXOEkAK74Mg-eOU4\",\"userHandle\":\"Mg\"}},\"challenge\":\"9JDxRapxqAmigNypJdSaUZk-fQIqs89WHQfD2tY2UNXY21xqubkTykoMiO-FBvEZ2ft2gDoKwvjvo3iOETiUzA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIJnMPXProk3ddOquEk+16Qk+C1F4GV4Ejh8Z3r5CTRoEIlggBilnAW5jCmSimgwvC9JszcnQsBIveElOugUI0vqUus4=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"d8db5c6ab9b913ca4a0c88ef8506f119d9fb76803a0ac2f8efa3788e113894cc\"}','2026-09-16 03:08:36',1,'2026-09-16 03:08:36');
/*!40000 ALTER TABLE `digital_signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_balances`
--

DROP TABLE IF EXISTS `leave_balances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_balances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `total_days` decimal(6,2) DEFAULT NULL,
  `used_days` decimal(6,2) DEFAULT '0.00',
  `pending_days` decimal(6,2) DEFAULT '0.00',
  `balance` decimal(6,2) DEFAULT NULL,
  `fiscal_year` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_leave_type` (`user_id`,`leave_type_id`),
  KEY `leave_type_id` (`leave_type_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_fiscal_year` (`fiscal_year`),
  CONSTRAINT `leave_balances_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_balances_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES
(43,2,1,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(44,2,2,5.00,0.00,0.00,5.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(45,2,3,999.00,0.00,0.00,999.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(46,2,4,105.00,0.00,0.00,105.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(47,2,5,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(48,2,6,3.00,0.00,0.00,3.00,2026,'2026-09-14 03:39:09','2026-09-14 03:39:09'),
(49,3,1,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:42:16','2026-09-14 03:42:16'),
(50,3,2,5.00,1.00,0.00,4.00,2026,'2026-09-14 03:42:16','2026-09-16 01:33:37'),
(51,3,3,999.00,0.00,0.00,999.00,2026,'2026-09-14 03:42:16','2026-09-14 03:42:16'),
(52,3,4,105.00,0.00,0.00,105.00,2026,'2026-09-14 03:42:16','2026-09-14 03:42:16'),
(53,3,5,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:42:16','2026-09-14 03:42:16'),
(54,3,6,3.00,0.00,0.00,3.00,2026,'2026-09-14 03:42:16','2026-09-14 03:42:16'),
(55,4,1,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:42:58','2026-09-14 03:42:58'),
(56,4,2,5.00,1.00,0.00,4.00,2026,'2026-09-14 03:42:58','2026-09-16 03:08:36'),
(57,4,3,999.00,0.00,0.00,999.00,2026,'2026-09-14 03:42:58','2026-09-14 03:42:58'),
(58,4,4,105.00,0.00,0.00,105.00,2026,'2026-09-14 03:42:58','2026-09-14 03:42:58'),
(59,4,5,7.00,0.00,0.00,7.00,2026,'2026-09-14 03:42:58','2026-09-14 03:42:58'),
(60,4,6,3.00,0.00,0.00,3.00,2026,'2026-09-14 03:42:58','2026-09-14 03:42:58'),
(61,5,1,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(62,5,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(63,5,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(64,5,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(65,5,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(66,5,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(67,6,1,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(68,6,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(69,6,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(70,6,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(71,6,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(72,6,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(73,7,1,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23'),
(74,7,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23'),
(75,7,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23'),
(76,7,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23'),
(77,7,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23'),
(78,7,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 03:03:23','2026-09-16 03:03:23');
/*!40000 ALTER TABLE `leave_balances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `number_of_days` decimal(6,2) DEFAULT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','approved','rejected','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `supervisor_status` enum('pending','approved','rejected','not_required') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `hr_status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `manager_id` int DEFAULT NULL,
  `assigned_supervisor_id` int DEFAULT NULL,
  `manager_comments` text COLLATE utf8mb4_unicode_ci,
  `hr_id` int DEFAULT NULL,
  `hr_comments` text COLLATE utf8mb4_unicode_ci,
  `digital_signature` text COLLATE utf8mb4_unicode_ci,
  `signature_timestamp` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `leave_type_id` (`leave_type_id`),
  KEY `hr_id` (`hr_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_manager_id` (`manager_id`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_assigned_supervisor_id` (`assigned_supervisor_id`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`),
  CONSTRAINT `leave_requests_ibfk_3` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `leave_requests_ibfk_4` FOREIGN KEY (`hr_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `leave_requests_ibfk_5` FOREIGN KEY (`assigned_supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES
(4,3,2,'2026-09-16','2026-09-16',1.00,'testing','approved','not_required','approved',2,NULL,NULL,2,'test','MEYCIQDUbIZl3TyFO0zI-V050jpy6wZYbRXT4fodKrAR3EGpHgIhAMMfOyecTe63P451fbMez1AzyD88sO-7SFw4-cr-F9Hb','2026-09-16 01:33:37','2026-09-16 01:32:33','2026-09-16 01:33:37'),
(5,4,2,'2026-09-16','2026-09-16',1.00,'testting','approved','approved','approved',3,2,'t',2,'tes','MEUCIB1JEzCtlQ6wV-8WHVzs8dn5Jw3tCu5CcskytSI5Za_fAiEAgeP-2Nmj4co-LLY1dXc_90jg29WuXOEkAK74Mg-eOU4','2026-09-16 03:08:36','2026-09-16 01:34:09','2026-09-16 03:08:36');
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `days_per_year` int NOT NULL,
  `is_paid` tinyint(1) DEFAULT '1',
  `requires_documentation` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_types`
--

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
INSERT INTO `leave_types` VALUES
(1,'Vacation Leave','Paid vacation leave; must be filed at least 3 days before the requested start date',7,1,0,'2026-09-11 02:57:21','2026-09-11 02:57:21'),
(2,'Sick Leave','Leave for medical reasons',5,1,0,'2026-09-11 02:57:21','2026-09-11 02:57:21'),
(3,'Leave Without Pay','Unpaid leave, only usable once Vacation and Sick leave balances are exhausted',999,0,1,'2026-09-11 02:57:21','2026-09-11 02:57:21'),
(4,'Maternity Leave','Leave for maternity (RA 11210); female employees only',105,1,1,'2026-09-11 02:57:21','2026-09-11 02:57:21'),
(5,'Paternity Leave','Leave for paternity (RA 8187); male employees only',7,1,1,'2026-09-11 02:57:21','2026-09-11 02:57:21'),
(6,'Bereavement Leave','Leave for the death of an immediate family member',3,1,1,'2026-09-11 02:57:21','2026-09-11 02:57:21');
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfa_secrets`
--

DROP TABLE IF EXISTS `mfa_secrets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mfa_secrets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `secret` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `backup_codes` json DEFAULT NULL,
  `is_enabled` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `mfa_secrets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mfa_secrets`
--

LOCK TABLES `mfa_secrets` WRITE;
/*!40000 ALTER TABLE `mfa_secrets` DISABLE KEYS */;
/*!40000 ALTER TABLE `mfa_secrets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `notification_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_id` int DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES
(9,2,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',2,0,'2026-09-16 01:00:33',NULL),
(10,3,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',3,0,'2026-09-16 01:24:34',NULL),
(11,4,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',4,0,'2026-09-16 01:25:37',NULL),
(12,2,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',4,0,'2026-09-16 01:32:33',NULL),
(13,3,'Leave Request Approved','Your leave request from 2026-09-16 to 2026-09-16 has been approved.','info','leave_request',4,0,'2026-09-16 01:33:37',NULL),
(14,2,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',5,0,'2026-09-16 01:34:09',NULL),
(15,2,'New Leave Request','New leave request awaiting HR approval','info','leave_request',5,0,'2026-09-16 02:08:25',NULL),
(16,4,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-16 to 2026-09-16. It now awaits HR approval.','info','leave_request',5,0,'2026-09-16 02:08:25',NULL),
(17,4,'Leave Request Approved','Your leave request from 2026-09-16 to 2026-09-16 has been approved.','info','leave_request',5,0,'2026-09-16 03:08:36',NULL);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_id` int DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `device_id` (`device_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_token_hash` (`token_hash`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sessions_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `device_fingerprints` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES
(17,1,'c263feee66cbacff7eac5293e3c5fbfa9b434a295864217e0270709321f87cfe',1,'203.177.49.42','2026-10-11 04:46:22','2026-09-11 04:38:09'),
(57,1,'6ddf993493b466e472ce953a860d02cb086e92122d26fc4db77afb25cd8a0f07',1,'180.193.218.250','2026-10-16 01:13:44','2026-09-16 01:13:44'),
(81,3,'b0a28f7886e7f02e94366bce6dd70379805747915768e0aed37ea9d8bdf9eb91',13,'203.177.49.42','2026-10-16 02:13:42','2026-09-16 02:07:52'),
(86,4,'a76c3bbc644ba18257c98a8f728abd5f0024ec84909af0175a858a01fb13661d',14,'175.158.215.172','2026-10-16 02:13:48','2026-09-16 02:13:44');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_id_sequence`
--

DROP TABLE IF EXISTS `user_id_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_id_sequence` (
  `id` tinyint NOT NULL,
  `next_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_id_sequence`
--

LOCK TABLES `user_id_sequence` WRITE;
/*!40000 ALTER TABLE `user_id_sequence` DISABLE KEYS */;
INSERT INTO `user_id_sequence` VALUES
(1,8);
/*!40000 ALTER TABLE `user_id_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `supervisor_id` int DEFAULT NULL,
  `role` enum('employee','manager','hr','admin') COLLATE utf8mb4_unicode_ci DEFAULT 'employee',
  `is_active` tinyint(1) DEFAULT '1',
  `device_fingerprint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `public_key` longtext COLLATE utf8mb4_unicode_ci,
  `password_set` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_supervisor_id` (`supervisor_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'admin','admin@thelewiscollege.edu.ph','$2y$10$VYHGcBlY1AY9YAnbwcxG9uj5fjLUT9WwOks2TuBj/hxOtS/APudJy','System Administrator','ADMIN',NULL,'male',NULL,'admin',1,NULL,NULL,1,'2026-08-26 03:32:46','2026-08-27 00:45:08'),
(2,'josefjurendelcastro','josefjurendelcastro@thelewiscollege.edu.ph','$2y$10$CToKRtTtwI0BMmaD1E1ZCOwaySottIYceU9bkjUwbtnHspSoeYyFi','Josef Jurendel Castro','ADMIN','HR Officer','male',1,'hr',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAudsgdOT2dK5h49FnpjPA\nxt9Sqj6LvF4pQe2TlLJQMIjjqu7wOfupdjLJ6+w0Xt1Pj1anSKHxczFOc7A+fhCJ\no4fcMU90ZM+9FmO+KYdA2dj6pKH6GOyHXYHTom+MS5FLTmtB9hQ3ORFiFG5tWgSD\n8mEahj70BV2Osj83VBuu3KrnYz4CWJ0YPfgsPXW7yzL66ux9K3OROBxUCaruBY9F\nj9kfWPZcYOii4SlmLrFoS6B8yimvlxbav/RCMM1771nk8T4tdFKdcVCQB7WGsmE5\nAdKrdY9SwB+1hoDUacXz0YEBwQUY2HRJOCXfwbO5SRnkEwUG6QRfTllOgv1uKvQP\n3BiP581UQWnRyL0NULs40frV/+Bntm98STtHkkjxutV5Uuf+8AJNFxc08ZFk1leg\netZtJEuqedUqggRBBK6vjMH54ichjggH7cHmDBomkgbXRzQlluhJjjKUM8xKAZ8C\nhwP1ch8v+iuRrfBfyYaA+4XtRaqHVhOrfxdjXg4FttCZ+E6kAhsJDGuYSoHjkzHx\nX0tg1s2AAk/ynd/WjDCKEKWJcv3Owlw6PLz8sIK2lMZ5GlxkIkoDD2y8MjcxeZwm\nl9esH1iGUludIYZMjMUIzQE2j2czJceaNyZzebCB9xc2+gsf9cr4AzbkXRwSH9n+\nV/mvh1mlbNxrWrZaZvf61p0CAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-14 03:39:09','2026-09-16 01:00:33'),
(3,'cyrilchristiangardon','cyrilchristiangardon@thelewiscollege.edu.ph','$2y$10$xEw2DsRbZV3/6S4lZcXAc.CEcyayrCV7CQ8rhydfQWwTzYzdPLSE2','Cyril Christian Gardon','CCS','Dean','male',2,'manager',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApIfp8wUwezv5rWXydcm0\n3lwUNq34MEvmrhGeKOpM3/mLaiZV1UHjE3nNmZKOAFAU9xsVWbJbBL1HQJ4DFzZ3\n9/KWbCy/6u8H7WiwbbVqIBoH+cvHbe5xWZ5F5j6C/JGB+ZOE137OOJ+a+lc7cnhE\nYDlWmzY+gKMKhVHnAsXYs5AXS3tQwyNdcVwaAbn/8N0tsvw9qMT6JOoemyd373W/\nZLLh3wD34bmS+8MdXPbW0SIvKT7RiXtFCTfpS4nVuxQ8P0llYCTpsz6btc7XKMZf\nMp3DeOdQdbiRf0O+JJKWvng3cYn0dQjaPU5sVgFBGw7wHx0aZF//95EGPQ3tw9kk\nZ93azjQ4bQsPQSkYY2HEs5OE69f8E4b3Vy73b1q3dd7IAu+RYP2TsBCSSXY/ilqt\nfEbotw1UFqlYXOmT88bOmuqTzopFcJChrheEBQHAYsUJGc7mZp3q6NDoiUVYogmz\nN2rTXgMAKisH24QRZ2/EsAg53cRRi9VkQt7HH8Z9ZSJ8o5wFysVKeBszBC0Gie9+\n/2YhCqkCCoS+CxhmR7Hk8CbJIPa4zyzGw4NHskgMazMRgd2GwSP5BcZD/CdvQ408\nDyeBdCINsOhsm/7r9s3e1hoLNYyHXfoYzhX3M3i2cMzMITJ1LqZd98ciHg0BM2R5\n01OGIY93g1qoNAop1X0sIzsCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-14 03:42:16','2026-09-16 01:24:34'),
(4,'ronnieformento','ronnieformento@thelewiscollege.edu.ph','$2y$10$7CXhRxsJVOg99XcNDSgD2.bMDD1YhlQHF34LaS2oqGHCAm4f5Cgqq','Ronnie Formento','CCS','Instructor','female',3,'employee',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtdRHR7t57052F+U4Gohl\n9KBAl5YY2voamc/yOGckWn1abrNxOg91HgF13XBPdpwsjjzbyL0ACWs94WbQ0QXt\nEcLaknAtxsmgjuJlSnqc9xoj2Tg87h+9qqKuGgxgUHmwsDUDnglVPxsT2GlRq8f3\nkH57XyfNwNDSLk2Q0KeUm0bSALL7Nx2+uBZv+lMxffSIj1Nsa68SZpXrmb8jJ7h3\ni0M0C+b4ZRCxT3u1bxCVxc/btNBYVK8T9rUxhrTsVT/aLMM1/FAzMBkHVv15qqza\nMGZbJgqxprMrIGpgZ4kdZ1Ee1bzT10jvI8S8cV2W1wxIJTzoJT5nMoUBvDejf5IW\nubHw99X2/M8KQOyEza9GjP+Hn8D6/FZXoqDKsJBfeCT3GDRfsolN9XVCjyWYPi8t\n34MLdJCyPRXivfX2wXSx89JQ0vmQwdbXlCkrXPYlCUcpZZEOTc8PVvSmRJ/MO8/+\nFft6fkMyAvDC+vAN278yNKSeerTm68S6DuoabXzhUBaXGzIGXBCNCEtinNNM2NDZ\nXMsTU3ZuIryzsIIiq57LSNc0ZeMWGMJVbYhWYUOCk4DqZ5lH1wySzgyKONsiaCOO\n9xfIWZHJP6erBtYo2rO3/1yPtlwPh6MkvPI+kp3RTN4SmrmDhfJQ5IKQA302NPX0\n4voxWWfYos8PB0kfe41SW9kCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-14 03:42:58','2026-09-16 01:25:37'),
(5,'arleeblairebongao','arleeblairebongao@thelewiscollege.edu.ph','$2y$10$cXSyW0NXbKINS9AsGc7Qf.hwMeUzDexaLo/7eZewHrGRArS.t4Tvu','Arlee Blaire Bongao','CTE','Dean','male',2,'manager',0,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA08u2wxo5E581GBO2qdkb\n1ioC+vbDUY3P9i0Oq2FJQGBcPSr3VMa/hhNPMj2JbkbQWh2uSLBEtmi/NLDDa2yE\n7p0MG9fo2XV9RZ6Dh2umjmTHSnLtKBF61PYRxKniaLt4FJEKTgqaYX4ZzxYwvaJv\nj1FiYupZnQsFOwC2Aey3m3eYV9dmBo33Xz6mdkFOJE0kfYA7mEkIaDFkx5bNmV7b\ndVkLnxFcjM3N50kXnyLb4I8gn6eRDT53fl5vJtCpbMohcyddq0VfGDZrEfhCXlkL\nBHCQwDJ8kkfUoTwyajwaolYJ39TPb2+PcNzTRBZoOfTaOY0TBr5DMs/8XQS9PtS9\ndIB1ZnMl5QXo0b0XjsVyMXh0LeMolH2P6VgzuupH80RBQRlMSoMGfIFzu8nAdfZP\n4TgVlLucCe9QnZR2xyxM143Y2lKM8k4arYJBQIvRy5uIfi07lckvMV7jC2tU8Kab\nESrEwv36GWUK8PvumkzKWSQt3B5OTGMiDbn2B7iEVNzbhkl3syQzxTIUKtysrSv6\nMCV9o4+4AG+9O0nRVLX8FYkPczlLpIvgKWNOFNc0Jb+nIxVFxfBbOqbtsCDok6sh\n/9ON4VZEv+jFyOe4/bgdpFOe57pS52zPDJs7dDHSvPYCRpSEUIUuJLDB7Yblpi2A\nGTWvRScWkQMFO3iKDFa5UpMCAwEAAQ==\n-----END PUBLIC KEY-----\n',0,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(6,'gefrendayao','gefrendayao@thelewiscollege.edu.ph','$2y$10$y1IyO4K7h87OFZHlPHiUe.qPYj0JkfqV9lkZH.tVw2Mump.XKEC7G','Gefren Dayao','CCS','Instructor','female',3,'employee',0,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoY/kiuH7p037X8qOTVar\nAz0IlIBZti+aaYbGiIjI25+atsIn+QTnJX+fbb3bRddHd+o7ro6UlOtjAs1pUwzy\nsJvZJwrslRU8FIXkf38NPCuEfNsxTtsDhUpbF7fe/HAK9nKPXbx7cN9hoUTWSoL1\nLqs6CZsX8zcSNFG2P3Vc7w07Ymp86kMS4Y8fORiOEgJswK9fQTvhn6u8ygK476jc\nLahhg55I7UyOZN2HRO+Ir9ea2B0j8zSiwq7WCRurwk6TIJvsBoAXnMSs2zOUS6K6\n0GtCno9XdFfzyyZSl2/DBo1Ced5PVbdzxct2Qxj63HsJ/je6ez8N6NlN6qOL8eQJ\nDz46fEuP0oaPTKYuNTSOP3g2lsY9i+r/PYFMmYU3YFkX4QSa51oWp0XCLShe18Hr\n44tMmE8V4MP35PPIQMqKpZ+cHwlZTD16mj+X6z4w93hWD7EBgZ+C/JC0BuxPSHK2\nsoCnwU80ltJXaUB9EbOUnPfvpK7k2Rjjxd9mqEyDj8cWJn3N8vxJO0pu7H9Zwo8C\nulSSxgUjx51sbM6fVSUriJvTwCVBAMtvSa2x5liCCOxw9vSwBDudv0ZQJIYIKFQi\nF5+Je3jrRxxTDls40G5zhq/CNstPGGFjwrXPq5ssr/CEInwY8C75RY1iYJhfj8rg\nIvkJY+kybsp1I9LifWjcc2ECAwEAAQ==\n-----END PUBLIC KEY-----\n',0,'2026-09-16 03:03:22','2026-09-16 03:03:22'),
(7,'brianianlasala','brianianlasala@thelewiscollege.edu.ph','$2y$10$9lqek/LXNn/ueB30JkVWt.WV60lmT9lchQR1jprjWbofnvyfUydga','Brian Lasala','ADMIN','Guidance Counselor','male',1,'employee',0,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0gl2z7DqTvd2CG0Azw+q\nmMTRMOdolmyYvObaAFA/dWzUywCDFpOZ+gBtBg3+KMh2u6+ZVCa5PEzcjWRMbecb\nhN0YeaNYAUe0Wn/vc6fgYuDqHehIcNGKFvUXB2WQVmrnFQCJwYAmVkNf0jbadQMW\nzosx80ckklwE7x5kPfGoTng7YLKbsIdxtrzbrPuTfbl1WjlQZd9UkCF4ayZO6kjp\nVnmMGFFX1eihqdshjJkhSgi+iPzzkWBhK/HuxF0fdy8A28/Mv9d/4dy3HO6XoZsu\n+3q+i5wa2hJ7uwBwLb8N+GULJ1DJ025zXHzc66hh7F6eh8w82t7SFQ3BHaGwWF/2\nDBtttehA59YYUK3N2OC8NIHe/6TnZZRzMY3LZxgo+JrLqcqvl4ncH4jmHuFqrSqL\nbBX7JeQHZU8zLoLjwPZRegkbaH3+kHzdBlq3KxVUHDTI436HH8oJbLtVxteivk1U\n/gkHusWPHDFdaw7FGnLEanXFNEIak7MLZExJQ95JGgSQ1nrdEYxIM8SeVRpqQzae\nLeYY/twvr+R2wV2/1tls5any10WaC3oLP7Lr74MyVR/LEMIs2RljdeUdci1fBMhl\nTiR8T2Ic63wT5kEKV6bGn8vKfbm4FpkZ6FmQjDt3pkQS3e4d/yaa9AivHM5C878V\n3JO/hkxy3bRN+tDOjlAfBgkCAwEAAQ==\n-----END PUBLIC KEY-----\n',0,'2026-09-16 03:03:23','2026-09-16 03:03:23');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webauthn_challenges`
--

DROP TABLE IF EXISTS `webauthn_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `webauthn_challenges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `challenge` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` enum('registration','approval') COLLATE utf8mb4_unicode_ci NOT NULL,
  `context_type` enum('leave_request','device_change') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `context_id` int DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `webauthn_challenges_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_challenges`
--

LOCK TABLES `webauthn_challenges` WRITE;
/*!40000 ALTER TABLE `webauthn_challenges` DISABLE KEYS */;
INSERT INTO `webauthn_challenges` VALUES
(1,1,'paDFDkzsu6Fwc0WaKKqBmqoB8ihAZpebFh229NAfPFI','registration',NULL,NULL,'2026-09-11 03:12:37','2026-09-11 03:07:37');
/*!40000 ALTER TABLE `webauthn_challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webauthn_credentials`
--

DROP TABLE IF EXISTS `webauthn_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `webauthn_credentials` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `credential_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `public_key` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `attestation_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `trust_path` text COLLATE utf8mb4_unicode_ci,
  `aaguid` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transports` json DEFAULT NULL,
  `sign_count` bigint unsigned NOT NULL DEFAULT '0',
  `label` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_fingerprint_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_label` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credential_id` (`credential_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `webauthn_credentials_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_credentials`
--

LOCK TABLES `webauthn_credentials` WRITE;
/*!40000 ALTER TABLE `webauthn_credentials` DISABLE KEYS */;
INSERT INTO `webauthn_credentials` VALUES
(3,2,'CW-8VR4Z_Ix9dUq6XOPqEg','pQECAyYgASFYIJnMPXProk3ddOquEk+16Qk+C1F4GV4Ejh8Z3r5CTRoEIlggBilnAW5jCmSimgwvC9JszcnQsBIveElOugUI0vqUus4=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','ae0b268077de8046ff0c36bc810656983c652257c17979a8f903b722d0aae064','Chrome • Windows PC','2026-09-16 01:33:24','2026-09-16 03:08:36'),
(4,3,'598qWm9XTbiPWtG0n7XGuA','pQECAyYgASFYIDyUFAh2OfPqOIV47tIWeV1Z5uFrHCpwdOPctrixLqUkIlggUQQeP22XiA+EEqC6GCaDZGeFh+8PUYC1Tfeap+ZHnMo=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','6220888a45abdcda8d583a34fc97d2faa3aff57df20af69a955ed4600576df02','Chrome • Android Device','2026-09-16 02:08:10','2026-09-16 02:13:42');
/*!40000 ALTER TABLE `webauthn_credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'railway'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-16  3:27:42
