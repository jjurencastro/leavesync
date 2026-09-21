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
) ENGINE=InnoDB AUTO_INCREMENT=205 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
(92,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 01:02:28'),
(94,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:13:44'),
(95,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:13:47'),
(97,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:14:29'),
(99,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:21:37'),
(100,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:23:00'),
(106,1,'login_success','user',1,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 01:30:45'),
(126,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:06:17'),
(127,1,'device_request_approved','device_change_request',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:07:34'),
(128,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:07:46'),
(132,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:08:32'),
(141,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 02:14:31'),
(149,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 03:31:52'),
(150,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:02:50'),
(151,1,'create_user','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:03:48'),
(152,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:05:16'),
(153,2,'password_set','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:05:29'),
(154,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:05:52'),
(155,1,'bulk_create_user','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:07:45'),
(156,3,'login_success_google','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:08:12'),
(157,3,'password_set','user',3,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:08:22'),
(158,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:08:36'),
(159,1,'bulk_create_user','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:11:49'),
(160,1,'bulk_create_user','user',5,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:11:49'),
(161,4,'login_success_google','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:12:24'),
(162,4,'password_set','user',4,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:12:35'),
(163,4,'create_leave_request','leave_request',6,NULL,'{\"bypass_reason\": null, \"assigned_supervisor_id\": 3, \"original_supervisor_id\": 3, \"bypassed_supervisor_ids\": []}','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:13:01'),
(164,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:13:23'),
(165,3,'login_success','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:13:38'),
(166,3,'webauthn_credential_registered','user',3,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:14:10'),
(167,3,'approve_leave_request_supervisor','leave_request',6,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:14:24'),
(168,2,'login_success','user',2,NULL,'[]','180.193.218.250','a69d8edbafee3fcbeb68a1f17ea10e89feead9bc1a53bda184702c4b772ffbdc','2026-09-16 05:14:43'),
(169,2,'device_change_requested','user',2,NULL,'[]','216.247.82.60','93aec685b9ba7b3a68cc537d4a5e991f316446b8acf0cdc6780ef5449692081c','2026-09-16 05:18:40'),
(170,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:18:45'),
(171,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:19:05'),
(172,1,'device_request_approved','device_change_request',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:19:27'),
(173,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:19:33'),
(174,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:19:43'),
(175,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:39:46'),
(176,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:40:40'),
(177,2,'device_change_requested','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:42:12'),
(178,2,'login_failed_untrusted_device','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:42:12'),
(179,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:42:17'),
(180,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:42:32'),
(181,1,'device_request_approved','device_change_request',5,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:43:01'),
(182,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:43:20'),
(183,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:43:21'),
(184,2,'device_change_requested','user',2,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:46:45'),
(185,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:47:01'),
(186,1,'device_request_approved','device_change_request',6,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:47:18'),
(187,2,'login_success_google','user',2,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:47:36'),
(188,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:47:38'),
(189,2,'webauthn_credential_registered','user',2,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:47:59'),
(190,2,'webauthn_approval_device_mismatch','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:48:25'),
(191,2,'approve_leave_request','leave_request',6,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:48:46'),
(192,3,'login_failed','user',3,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:49:15'),
(193,3,'device_change_requested','user',3,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:49:26'),
(194,3,'login_failed_untrusted_device','user',3,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:49:26'),
(195,2,'webauthn_approval_device_mismatch','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:49:40'),
(196,2,'login_success','user',2,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:49:59'),
(197,2,'device_request_approved','device_change_request',7,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:50:15'),
(198,3,'login_success','user',3,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:50:30'),
(199,3,'webauthn_credential_removed','user',3,NULL,'[]','216.247.84.170','edb092655eb00da680f8888e0abdf3cf5a25c72fb346284408f5834f8b6f29ef','2026-09-16 05:50:41'),
(200,4,'login_success','user',4,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:52:17'),
(201,4,'create_leave_request','leave_request',7,NULL,'{\"bypass_reason\": null, \"assigned_supervisor_id\": 3, \"original_supervisor_id\": 3, \"bypassed_supervisor_ids\": []}','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:52:41'),
(202,1,'login_success','user',1,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:59:06'),
(203,NULL,'delete_user','user',5,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 05:59:47'),
(204,2,'login_success','user',2,NULL,'[]','203.177.49.42','2ab34c54e3c1227c7332d41276d84613bb719392148c1f8f76b7047ab3f7e0eb','2026-09-16 06:00:43');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_change_requests`
--

LOCK TABLES `device_change_requests` WRITE;
/*!40000 ALTER TABLE `device_change_requests` DISABLE KEYS */;
INSERT INTO `device_change_requests` VALUES
(4,2,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.82.60\",\"browser\":\"Chrome 152\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"unknown\",\"timezone\":\"UTC\",\"language\":\"\",\"platform\":\"\",\"hardware_concurrency\":\"unknown\",\"device_memory\":\"unknown\"}','216.247.82.60','Chrome 152','approved','2026-09-16 05:18:40','2026-09-16 05:19:27',1),
(5,2,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/153.0.0.0 Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Chrome 153\",\"os\":\"Windows 10\",\"device\":\"Windows PC\",\"screen_resolution\":\"1536x730\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Win32\",\"hardware_concurrency\":12,\"device_memory\":16}','203.177.49.42','Chrome 153','approved','2026-09-16 05:42:12','2026-09-16 05:43:01',1),
(6,2,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.84.170\",\"browser\":\"Chrome 152\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"unknown\",\"timezone\":\"UTC\",\"language\":\"\",\"platform\":\"\",\"hardware_concurrency\":\"unknown\",\"device_memory\":\"unknown\"}','216.247.84.170','Chrome 152','approved','2026-09-16 05:46:45','2026-09-16 05:47:18',1),
(7,3,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.84.170\",\"browser\":\"Chrome 152\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','216.247.84.170','Chrome 152','approved','2026-09-16 05:49:26','2026-09-16 05:50:15',2);
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_fingerprints`
--

LOCK TABLES `device_fingerprints` WRITE;
/*!40000 ALTER TABLE `device_fingerprints` DISABLE KEYS */;
INSERT INTO `device_fingerprints` VALUES
(1,1,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 05:59:06','2026-09-11 03:06:32','2026-09-16 05:59:06'),
(5,1,'c430cbd64980373a8a3183c8953c11de250fe5176919a928ccda32964a69b926','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"138.84.134.51\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x400\", \"hardware_concurrency\": 4}','138.84.134.51','Safari 604',1,'2026-09-13 12:57:10','2026-09-13 12:57:10','2026-09-13 12:57:10'),
(15,2,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 06:00:43','2026-09-16 05:05:29','2026-09-16 06:00:43'),
(16,3,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"180.193.218.250\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','180.193.218.250','Chrome 153',1,'2026-09-16 05:13:38','2026-09-16 05:08:22','2026-09-16 05:13:38'),
(17,4,'18b2276f55c68967cf94b7ff96da1a5893215dd7b49ae176d6298d04f84122d4','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 153\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 153',1,'2026-09-16 05:52:17','2026-09-16 05:12:35','2026-09-16 05:52:17'),
(18,2,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.84.170\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','216.247.84.170','Chrome 152',1,'2026-09-16 05:49:59','2026-09-16 05:19:27','2026-09-16 05:49:59'),
(19,3,'af6db15b99d3949bf44bbd60009fbfc9fef0154c5771ea3b7b356e2f3864c113','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.84.170\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','216.247.84.170','Chrome 152',1,'2026-09-16 05:50:30','2026-09-16 05:50:15','2026-09-16 05:50:30');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_signatures`
--

LOCK TABLES `digital_signatures` WRITE;
/*!40000 ALTER TABLE `digital_signatures` DISABLE KEYS */;
INSERT INTO `digital_signatures` VALUES
(4,6,'leave_request',3,'MEYCIQD5ZMdNuDjKxden-2A8l9b5506KwYOJDuY-3TM7mBdLOgIhAOJ2kNxBvym1k0PJfzf1MXjAxMdA9JPPiQHUVy_KE7f9','{\"type\":\"webauthn\",\"signature\":\"MEYCIQD5ZMdNuDjKxden-2A8l9b5506KwYOJDuY-3TM7mBdLOgIhAOJ2kNxBvym1k0PJfzf1MXjAxMdA9JPPiQHUVy_KE7f9\",\"credential_id\":\"symCX5ogd9sDoM7yks9DJg\",\"assertion\":{\"id\":\"symCX5ogd9sDoM7yks9DJg\",\"rawId\":\"symCX5ogd9sDoM7yks9DJg\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiT1V6cTIyWlJPWEhSbk9wa1ZXX1d2U25BUGxnWERyNkU3UlhoN1V4ZEVrdkZLODRvVHpJa195MTZ6QkozWTh3dHVnOUpsTFN4T1ZBV2t3SEVfQTQyeUEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZSwib3RoZXJfa2V5c19jYW5fYmVfYWRkZWRfaGVyZSI6ImRvIG5vdCBjb21wYXJlIGNsaWVudERhdGFKU09OIGFnYWluc3QgYSB0ZW1wbGF0ZS4gU2VlIGh0dHBzOi8vZ29vLmdsL3lhYlBleCJ9\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEYCIQD5ZMdNuDjKxden-2A8l9b5506KwYOJDuY-3TM7mBdLOgIhAOJ2kNxBvym1k0PJfzf1MXjAxMdA9JPPiQHUVy_KE7f9\",\"userHandle\":\"Mw\"}},\"challenge\":\"OUzq22ZROXHRnOpkVW_WvSnAPlgXDr6E7RXh7UxdEkvFK84oTzIk_y16zBJ3Y8wtug9JlLSxOVAWkwHE_A42yA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":3,\"credential\":{\"public_key\":\"pQECAyYgASFYIOhTWLfNXi3Qxe9j7Gd54nlCXrT5eMg8FfIjvNH6Yw+cIlgg5B1vxO3IkaQS7VUD+Z39ixgXbEPpG8TLWpcrQx68mlg=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"c52bce284f3224ff2d7acc127763cc2dba0f4994b4b13950169301c4fc0e36c8\"}','2026-09-16 05:14:24',1,'2026-09-16 05:14:24'),
(5,6,'leave_request',2,'MEQCIAm5eiiI5wZJPhUQmB1C7d0bi_tHSvDbhmJ4-7f0CN1XAiBdXeoCh3PwmmWNWo7htcdEZ50Essu6OQQXtLtH3R3nXw','{\"type\":\"webauthn\",\"signature\":\"MEQCIAm5eiiI5wZJPhUQmB1C7d0bi_tHSvDbhmJ4-7f0CN1XAiBdXeoCh3PwmmWNWo7htcdEZ50Essu6OQQXtLtH3R3nXw\",\"credential_id\":\"HuI0gG0GZ5cBMJUHaoX13g\",\"assertion\":{\"id\":\"HuI0gG0GZ5cBMJUHaoX13g\",\"rawId\":\"HuI0gG0GZ5cBMJUHaoX13g\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoicGNHWFdTZEs2QjIyT0ZuZWdiQjNBMEg4ZjBHUENCOWcyZUloYmZsZVZwN0ZLODRvVHpJa195MTZ6QkozWTh3dHVnOUpsTFN4T1ZBV2t3SEVfQTQyeUEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEQCIAm5eiiI5wZJPhUQmB1C7d0bi_tHSvDbhmJ4-7f0CN1XAiBdXeoCh3PwmmWNWo7htcdEZ50Essu6OQQXtLtH3R3nXw\",\"userHandle\":\"Mg\"}},\"challenge\":\"pcGXWSdK6B22OFnegbB3A0H8f0GPCB9g2eIhbfleVp7FK84oTzIk_y16zBJ3Y8wtug9JlLSxOVAWkwHE_A42yA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIHRbA0Zsv0jUKnkEHXBqpHitp4lSKo9U9uz4zIbZeWGVIlggbwytF5lORESyc2hL+k6kfbF1NFhtFxhARFRMJL5EHuQ=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"c52bce284f3224ff2d7acc127763cc2dba0f4994b4b13950169301c4fc0e36c8\"}','2026-09-16 05:48:46',1,'2026-09-16 05:48:46');
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
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES
(79,2,1,7.00,0.00,0.00,7.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(80,2,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(81,2,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(82,2,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(83,2,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(84,2,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 05:03:48','2026-09-16 05:03:48'),
(85,3,1,7.00,0.00,0.00,7.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(86,3,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(87,3,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(88,3,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(89,3,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(90,3,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 05:07:45','2026-09-16 05:07:45'),
(91,4,1,7.00,1.00,1.00,5.00,2026,'2026-09-16 05:11:49','2026-09-16 05:52:41'),
(92,4,2,5.00,0.00,0.00,5.00,2026,'2026-09-16 05:11:49','2026-09-16 05:11:49'),
(93,4,3,999.00,0.00,0.00,999.00,2026,'2026-09-16 05:11:49','2026-09-16 05:11:49'),
(94,4,4,105.00,0.00,0.00,105.00,2026,'2026-09-16 05:11:49','2026-09-16 05:11:49'),
(95,4,5,7.00,0.00,0.00,7.00,2026,'2026-09-16 05:11:49','2026-09-16 05:11:49'),
(96,4,6,3.00,0.00,0.00,3.00,2026,'2026-09-16 05:11:49','2026-09-16 05:11:49');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES
(6,4,1,'2026-09-21','2026-09-21',1.00,'test','approved','approved','approved',3,3,'test',2,'test','MEQCIAm5eiiI5wZJPhUQmB1C7d0bi_tHSvDbhmJ4-7f0CN1XAiBdXeoCh3PwmmWNWo7htcdEZ50Essu6OQQXtLtH3R3nXw','2026-09-16 05:48:46','2026-09-16 05:13:01','2026-09-16 05:48:46'),
(7,4,1,'2026-09-25','2026-09-25',1.00,'test','pending','pending','pending',3,3,NULL,NULL,NULL,NULL,NULL,'2026-09-16 05:52:41','2026-09-16 05:52:41');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES
(18,2,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',2,0,'2026-09-16 05:05:29',NULL),
(19,3,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',3,0,'2026-09-16 05:08:22',NULL),
(20,4,'Account activated','Your password was set and this device was registered as a trusted device.','success','user',4,0,'2026-09-16 05:12:35',NULL),
(21,3,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',6,0,'2026-09-16 05:13:01',NULL),
(22,2,'New Leave Request','New leave request awaiting HR approval','info','leave_request',6,0,'2026-09-16 05:14:24',NULL),
(23,4,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-21 to 2026-09-21. It now awaits HR approval.','info','leave_request',6,0,'2026-09-16 05:14:24',NULL),
(24,4,'Leave Request Approved','Your leave request from 2026-09-21 to 2026-09-21 has been approved.','info','leave_request',6,0,'2026-09-16 05:48:46',NULL),
(25,3,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',7,0,'2026-09-16 05:52:41',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES
(17,1,'c263feee66cbacff7eac5293e3c5fbfa9b434a295864217e0270709321f87cfe',1,'203.177.49.42','2026-10-11 04:46:22','2026-09-11 04:38:09'),
(57,1,'6ddf993493b466e472ce953a860d02cb086e92122d26fc4db77afb25cd8a0f07',1,'180.193.218.250','2026-10-16 01:13:44','2026-09-16 01:13:44'),
(92,1,'7e885b195647964f46e4203ca2ac0c15d7b84e4a060facba63b051b178a3f3dc',1,'203.177.49.42','2026-10-16 03:31:59','2026-09-16 03:31:52'),
(113,3,'8566edaadfe8d73b3b1a5c31f89f89f5bec28ea582aa0c16c16bbc00399a27ef',19,'216.247.84.170','2026-10-16 05:58:07','2026-09-16 05:50:30'),
(116,2,'64b6c27f188e99b7f6fb9f9f3bf25f87bfe5938bd59e53477adf8855fe38e681',15,'203.177.49.42','2026-10-16 06:07:12','2026-09-16 06:00:43');
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
(1,6);
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'admin','admin@thelewiscollege.edu.ph','$2y$10$VYHGcBlY1AY9YAnbwcxG9uj5fjLUT9WwOks2TuBj/hxOtS/APudJy','System Administrator','ADMIN',NULL,'male',NULL,'admin',1,NULL,NULL,1,'2026-08-26 03:32:46','2026-08-27 00:45:08'),
(2,'josefjurendelcastro','josefjurendelcastro@thelewiscollege.edu.ph','$2y$10$/flP3rCj3fzosFM80v3bwO1GS25QCPwvXDyfe8u.aw66Nd1m48NlO','Josef Jurendel Castro','ADMIN','HR Officer','male',1,'hr',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAt4q3835Cwibfe0Zr41rS\noNDTNPEbQG0jzueyIHm1yhGNHXkq+59BYW4JyfttuYIhwZaVXEonQiN8mgq4y5Zd\nc42fW9TzkY/BYS9DStIvqLK4zkxKpHnKD909f2xxiuYvn+zUdhTb5XyiJElGTBNR\ncS+yIQLwZDMks42wY5xg42FTEroi0/RpKeBOyaKEVIJt4wCcJqzucC1EuJUVsp0W\nNRChshdskSorO5ItxHcCURbhZpgkbFt1zDt15abRK+ytQGl6D+NX/0bTrge0DQa+\n3BYfn+Mdzhat+y+GI71Nve0Nudxxc2qpv9f2y1r6ybsjPLTCpf0wHU3GExU/l1je\nFGyGmqAupNC8Zwnmk8KOfPquSld0zYgyWdE1P1NGqeMXyIWCr9HXN/bjyPX4WJjY\nVn6k/JNlZhXG1CQ26X9AK2vlLm1nXzt5dvwMpxkok2rR6ndQRJkhx4XeKz0GWGju\nni7M+zX1v2yS9qAvkE6Lm9AIFzOy0uRjSH5u2i+ipGS1ssvQSvPw5lfNI3ey2IEc\n/aSg2oUGtcvpsiSEvLDb7bPWnol0rfh5Xh+JPa0p4PeYQ99quB5W752fwCKCSxQh\nIIpRi6FKvMYWt2VCkDTWP3O7gwc1jL1v9P2vZtyvv8qbAr5mKf2N4UZAsLya30Ky\nyf/9gw097hp7uKnvEMOU1TUCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-16 05:03:48','2026-09-16 05:05:29'),
(3,'cyrilchristiangardon','cyrilchristiangardon@thelewiscollege.edu.ph','$2y$10$ImjbtOiuQSucLsKEJuDXsOYeg/i6fe3xLREPxb1pZHDgc7.Q81O4C','Cyril Christian Gardon','CCS','Dean','female',2,'manager',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAp2FrzLRLlPWTK9d88BQA\nejxdf3bWnQ7AXaTcHDdGqRTsW0iNbaDM+LTkC7+qmTYnQY4EisSmn57K141PWCIf\nzwBIwwfSIoU4Akakp7+CbTa2bI9aK5iXkg0xyW/ox+6/EUum3yXbAjAtI9UXX5GL\nBKuj5aLdyIso6KxGeqR6BAP4xjasyAYzjMj3yBOPYcdyqBQG5VfUcQ/FWoByVIyL\np96tIsp6XDTFyJTad67Ne3Gfseg6GJX7AMRHOF8waajkwoeY2K819u5I6Ld1ts78\nWcGL9ajki7CW7IVroXu3HXus2gwSu7D8u+NCiGOBaRiEcm3a454cXLmQo1msp7s4\nAGuZ/wlXCtakwuLXpqYhHRA4pIoev48UdEMLE/b2Vjqw36wHrAwfRu/8RlzwmLAE\nz/I6o4SODeWDFiah4zYNH0jVbgEVOZ3y4lMzlWSJPIutAGMIJ8BxgyGo7yi/e7aX\nYICpQ8CcFo687VbPnh/TczzK4IFvNvV0Jd6J2tb+jlVe6DV/HhVSXupoqjcL+GeU\nbn2dBtpwV3AoWh/qrlssH/Q8BLVKayJ+gRUUqnqtzkA9j8s1lNnODAURr5fU8boc\nDBKnbEwoD8N6mVk1lcf4Dl0PJZ/wjiO42OzBIBXfk7H34Vn+EGScex5EyfCfveXG\nMi7WqYAtLGmZV3ppCMus5oECAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-16 05:07:45','2026-09-16 05:08:22'),
(4,'ronnieformento','ronnieformento@thelewiscollege.edu.ph','$2y$10$MaOb0VlfgOwu.yuqA9QjceFd/bC/IftlbR2UScOo8ekveJYYjGK4K','Ronnie Formento','CCS','Instructor','male',3,'employee',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlf/QtW3esZGqWLtjZvDM\n8bPYxG6HMcjcMc7uPehjoMtgoaRzVHzxH3Evei4I3yvB09/lVqS1A80p3NKaXbZR\nqit1OOXs188TL1T6XkvPnPNhjmnrI41/wfh+o+M0j5Pmr3XT+vsNYUn5AXPUoC/X\nhA6G+lsUdqwe20TUwY98I2XScFVwB4bSA5f1qsx57FsoyjEnzEuwPrj6LFYhPSS0\nICyLQLTMirHtrbXmT6Vg7qkn3e0IKJj8R9q9MdcOABieH+CYvEOhvZ94HLFruGUc\nkW1TpxokDDAhPwOzBU706U9kwM9GIW340kvhzSv/TfLvo+AP31NRrRr88AtzI2G+\n5iDJJtddpJEOt0tlkcVHwQIdKMcoekVY48PNpO5gweHH/Obkzsjld/4Uhj9txR3l\nvwMwDN+jvyfZLH7YGamdKvvKrjdpTmkDjdKBLN49LRf1pIMS0XP6CEm9L4fAZa89\nuXNkv51U2sB8EhcQeGNNK/dXb+U2RENMPGpcT0duGz7qF+ITq2Jo6/ghzJgGK+KE\n18GVNEL8yjrQjXe5NfeJ++o4dLaXVnBjD5iwGrtZeAG2eJcc57ZXsaXHdBrj03W4\n7bQzoz0bP3dNiYRtdI/LNSFnrmCewy/m+kXrJgwiSY+joz2wMZsN4jZCHw5ojOTn\npmt9YoKXZpg4gzT4P5N8cEUCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-16 05:11:49','2026-09-16 05:12:35');
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_challenges`
--

LOCK TABLES `webauthn_challenges` WRITE;
/*!40000 ALTER TABLE `webauthn_challenges` DISABLE KEYS */;
INSERT INTO `webauthn_challenges` VALUES
(1,1,'paDFDkzsu6Fwc0WaKKqBmqoB8ihAZpebFh229NAfPFI','registration',NULL,NULL,'2026-09-11 03:12:37','2026-09-11 03:07:37'),
(14,1,'fWeOqP2jlJ4XzGBp84YL3ZNwu2c-k-EsRMWCfANEQsU','registration',NULL,NULL,'2026-09-16 05:21:54','2026-09-16 05:18:54');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_credentials`
--

LOCK TABLES `webauthn_credentials` WRITE;
/*!40000 ALTER TABLE `webauthn_credentials` DISABLE KEYS */;
INSERT INTO `webauthn_credentials` VALUES
(7,1,'ybDTsGUum1uqcN7Zn9RDuw','pQECAyYgASFYILnHPUR+qcqrAAuSTq+zDzpSNmIXBhMDPvididMYPVFbIlgghHLJkcFGHfSfRjpSL9sw+jXlzZO8xibignSFj7E8uB8=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','ae0b268077de8046ff0c36bc810656983c652257c17979a8f903b722d0aae064','Chrome • Windows PC','2026-09-16 05:42:32','2026-09-16 05:47:18'),
(8,2,'HuI0gG0GZ5cBMJUHaoX13g','pQECAyYgASFYIHRbA0Zsv0jUKnkEHXBqpHitp4lSKo9U9uz4zIbZeWGVIlggbwytF5lORESyc2hL+k6kfbF1NFhtFxhARFRMJL5EHuQ=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','6220888a45abdcda8d583a34fc97d2faa3aff57df20af69a955ed4600576df02','Chrome • Android Device','2026-09-16 05:47:59','2026-09-16 05:50:15');
/*!40000 ALTER TABLE `webauthn_credentials` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-16  6:07:46
