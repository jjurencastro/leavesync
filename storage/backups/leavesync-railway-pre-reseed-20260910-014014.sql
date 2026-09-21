-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: railway
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activation_approvals`
--

DROP TABLE IF EXISTS `activation_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activation_approvals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `approver_id` int NOT NULL,
  `approval_level` enum('supervisor','hr') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` text COLLATE utf8mb4_unicode_ci,
  `digital_signature` text COLLATE utf8mb4_unicode_ci,
  `signature_timestamp` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `approver_id` (`approver_id`),
  KEY `idx_activation_user` (`user_id`),
  KEY `idx_activation_level` (`approval_level`),
  KEY `idx_activation_status` (`status`),
  CONSTRAINT `activation_approvals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `activation_approvals_ibfk_2` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activation_approvals`
--

LOCK TABLES `activation_approvals` WRITE;
/*!40000 ALTER TABLE `activation_approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `activation_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=453 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (5,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:02'),(6,1,'update_user','user',2,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:25'),(10,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 06:08:07'),(22,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:28'),(23,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:32'),(24,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:37'),(29,1,'login_failed','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:01'),(30,1,'login_success','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:09'),(31,1,'device_request_approved','device_change_request',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:31'),(37,1,'login_success','user',1,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:39:44'),(39,1,'device_request_approved','device_change_request',2,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:42:09'),(45,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:03:56'),(46,1,'device_request_approved','device_change_request',4,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:06'),(47,1,'device_request_approved','device_change_request',3,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:09'),(48,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:20:15'),(52,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:35:42'),(57,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:44:43'),(58,1,'password_changed','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:08'),(59,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:18'),(63,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 01:56:42'),(70,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:41:18'),(71,1,'webauthn_credential_registered','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:05'),(72,1,'device_request_approved','device_change_request',5,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:22'),(76,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:44:28'),(78,1,'device_request_approved','device_change_request',6,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:47:13'),(88,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:01'),(89,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:03'),(90,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:06'),(91,1,'update_user','user',4,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:16'),(101,1,'login_success','user',1,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:29:10'),(102,1,'device_request_approved','device_change_request',7,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:30:17'),(117,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:40'),(118,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:42'),(119,1,'device_request_approved','device_change_request',8,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:01:03'),(123,1,'device_request_approved','device_change_request',9,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:02:38'),(130,1,'login_failed','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:52'),(131,1,'login_success','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:55'),(137,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-02 01:12:33'),(145,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:05:13'),(147,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:06:56'),(152,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:24:57'),(153,1,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:25:08'),(158,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:30:33'),(165,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:21'),(166,1,'approve_leave_request','leave_request',7,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:49'),(167,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:48:46'),(170,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:29'),(171,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:40'),(172,1,'update_user','user',4,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:52:21'),(175,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:24'),(176,1,'device_request_approved','device_change_request',11,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:49'),(177,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 04:15:57'),(183,1,'device_request_approved','device_change_request',12,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:23:00'),(194,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:21'),(195,1,'device_request_approved','device_change_request',13,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:40'),(197,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:00'),(200,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:31'),(201,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:16'),(202,1,'device_request_approved','device_change_request',14,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:27'),(207,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:12:25'),(208,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:14:20'),(209,1,'device_request_approved','device_change_request',15,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:15:45'),(219,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:37'),(220,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:54'),(221,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:00'),(222,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:03'),(223,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:08'),(224,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:15'),(225,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:17'),(231,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:07'),(232,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:16'),(233,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:20'),(234,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:53'),(235,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:59'),(236,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:01'),(237,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:14'),(238,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:22'),(239,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:26'),(240,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:31'),(241,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:33'),(246,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:55'),(247,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:20'),(248,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:31'),(249,1,'device_request_approved','device_change_request',16,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:41'),(265,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:01'),(266,1,'device_request_approved','device_change_request',17,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:20'),(267,1,'approve_leave_request_supervisor','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:31'),(268,1,'approve_leave_request','leave_request',9,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:42'),(269,1,'reject_leave_request','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:57:00'),(286,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:13:58'),(287,1,'device_request_approved','device_change_request',18,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:14:10'),(300,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:06:20'),(302,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:07:34'),(310,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:34:42'),(311,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:36:04'),(313,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:37:25'),(316,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:39:27'),(317,1,'update_user','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:39:39'),(327,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:49:33'),(335,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:52:50'),(336,1,'device_request_approved','device_change_request',19,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:53:50'),(343,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:56:19'),(344,1,'device_request_approved','device_change_request',20,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:56:31'),(350,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-09 00:19:45'),(356,1,'webauthn_credential_removed','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-09 00:21:53'),(357,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-09 00:22:02'),(360,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-09 00:23:49'),(369,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 00:45:06'),(373,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 00:49:10'),(388,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 00:55:02'),(392,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 00:58:17'),(393,1,'login_success','user',1,NULL,'[]','216.247.84.217','4f6d795abf2b3e060be82ceedc8ec1b2ddc71930ac81d94b2230623d91da76b5','2026-09-09 00:59:03'),(394,1,'webauthn_credential_registered','user',1,NULL,'[]','216.247.84.217','4f6d795abf2b3e060be82ceedc8ec1b2ddc71930ac81d94b2230623d91da76b5','2026-09-09 00:59:30'),(395,1,'device_request_approved','device_change_request',23,NULL,'[]','216.247.84.217','4f6d795abf2b3e060be82ceedc8ec1b2ddc71930ac81d94b2230623d91da76b5','2026-09-09 01:01:12'),(402,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 03:30:56'),(403,1,'login_success','user',1,NULL,'[]','216.247.84.217','9359ef120d3bda076021ceb35b374fbcd0ebccfbf44f5b1f4c7ac7a40acf90b2','2026-09-09 03:31:51'),(404,1,'login_success','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:22:49'),(405,NULL,'login_success_google','user',2,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:23:06'),(406,NULL,'login_failed','user',NULL,NULL,'{\"username\": \"ronnieformento\"}','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:23:48'),(407,3,'login_success_google','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:23:58'),(408,3,'password_set','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:24:20'),(409,1,'update_user','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:24:33'),(410,3,'login_success_google','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:24:43'),(411,1,'update_user','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:26:55'),(412,3,'login_failed','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:27:12'),(413,3,'login_failed','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:27:17'),(414,1,'login_failed','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:27:38'),(415,1,'login_success','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:27:41'),(416,3,'login_success','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:28:00'),(417,4,'login_success_google','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:28:28'),(418,4,'password_set','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:28:50'),(419,1,'login_success','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:29:12'),(420,3,'login_success','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:29:34'),(421,3,'approve_user','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:29:43'),(422,4,'login_success','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:29:59'),(423,4,'login_success','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:30:19'),(424,3,'login_success','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:30:47'),(425,1,'login_success','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:31:08'),(426,4,'login_success','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:31:27'),(427,4,'create_leave_request','leave_request',17,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:32:16'),(428,4,'create_leave_request','leave_request',18,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:32:32'),(429,4,'create_leave_request','leave_request',19,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:32:57'),(430,3,'login_success','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:33:20'),(431,3,'webauthn_credential_registered','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:33:51'),(432,1,'login_success','user',1,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:34:16'),(433,3,'device_change_requested','user',3,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:34:36'),(434,5,'login_success_google','user',5,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:34:49'),(435,1,'login_success','user',1,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:34:54'),(436,5,'password_set','user',5,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:35:16'),(437,1,'device_request_approved','device_change_request',24,NULL,'[]','216.247.83.70','d30f456cdd2c8dc85d7ab97a2d191ecc35cd1578f86dff6b25ff862e6bc3fce9','2026-09-10 00:36:02'),(438,NULL,'login_failed','user',NULL,NULL,'{\"username\": \"josefjurendelcastro@thelewiscollege.edu.ph\"}','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:36:19'),(439,3,'login_success','user',3,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:36:28'),(440,3,'webauthn_approval_device_mismatch','user',3,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:36:39'),(441,4,'device_change_requested','user',4,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:37:03'),(442,4,'login_failed_untrusted_device','user',4,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:37:03'),(443,1,'device_request_approved','device_change_request',25,NULL,'[]','216.247.83.70','d30f456cdd2c8dc85d7ab97a2d191ecc35cd1578f86dff6b25ff862e6bc3fce9','2026-09-10 00:37:28'),(444,4,'login_success','user',4,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:37:32'),(445,4,'webauthn_credential_registered','user',4,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:37:44'),(446,4,'approve_user','user',5,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:37:56'),(447,5,'login_success','user',5,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:38:11'),(448,5,'create_leave_request','leave_request',20,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:38:38'),(449,4,'approve_leave_request_supervisor','leave_request',20,NULL,'[]','216.247.83.70','9e1c39461b7a527b42ac64bd40dd1ea302ad5ef485381e49920eed3d6d20f99e','2026-09-10 00:39:14'),(450,4,'login_success','user',4,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:39:29'),(451,3,'login_success','user',3,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:40:13'),(452,3,'approve_leave_request','leave_request',20,NULL,'[]','216.247.83.70','f98738d123d05b6b244eea7a18d7ecdfdd648bda728b0aae03b93e00c55cf9c3','2026-09-10 00:40:26');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'ADMIN','Administration','Administrative and support offices','2026-08-26 03:30:08','2026-08-26 03:30:08'),(2,'BED','Basic Education','Preschool through senior high school','2026-08-26 03:30:08','2026-08-26 03:30:08'),(3,'HED','Higher Education','Colleges and higher education programs','2026-08-26 03:30:08','2026-08-26 03:30:08');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_change_requests`
--

DROP TABLE IF EXISTS `device_change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_change_requests`
--

LOCK TABLES `device_change_requests` WRITE;
/*!40000 ALTER TABLE `device_change_requests` DISABLE KEYS */;
INSERT INTO `device_change_requests` VALUES (24,3,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/151.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.83.70\",\"browser\":\"Chrome 151\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"unknown\",\"timezone\":\"UTC\",\"language\":\"\",\"platform\":\"\",\"hardware_concurrency\":\"unknown\",\"device_memory\":\"unknown\"}','216.247.83.70','Chrome 151','approved','2026-09-10 00:34:36','2026-09-10 00:36:02',1),(25,4,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/151.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.83.70\",\"browser\":\"Chrome 151\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','216.247.83.70','Chrome 151','approved','2026-09-10 00:37:03','2026-09-10 00:37:28',1);
/*!40000 ALTER TABLE `device_change_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_fingerprints`
--

DROP TABLE IF EXISTS `device_fingerprints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_fingerprints`
--

LOCK TABLES `device_fingerprints` WRITE;
/*!40000 ALTER TABLE `device_fingerprints` DISABLE KEYS */;
INSERT INTO `device_fingerprints` VALUES (2,1,'0c82c8f821f00d8940a23e7b440b36ea2ae0f9fed0b06894671b3291fb3b78fa','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"110.54.141.165\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','110.54.141.165','Chrome 151',1,'2026-08-27 10:00:42','2026-08-26 05:52:02','2026-08-27 10:00:42'),(5,1,'25befb4fd7a4be2871b71dbdc19479a6559a154a7f7fcd620b393dd464e14999','{\"os\": \"macOS 10.15.7\", \"device\": \"Mac\", \"browser\": \"Chrome 150\", \"language\": \"en-US\", \"platform\": \"MacIntel\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"136.158.103.18\", \"user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36\", \"device_memory\": 8, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1470x835\", \"hardware_concurrency\": 8}','136.158.103.18','Chrome 150',1,'2026-08-26 11:39:44','2026-08-26 11:39:44','2026-08-26 11:39:44'),(9,1,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','216.247.83.70','Chrome 151',1,'2026-09-10 00:34:54','2026-08-27 06:29:10','2026-09-10 00:34:54'),(11,1,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','216.247.83.70','Chrome 152',1,'2026-09-10 00:34:16','2026-09-01 23:58:55','2026-09-10 00:34:16'),(34,1,'e44a38aebe8bea57ff7f26d2a63aec715d43b6e6a4d61828e67cca151f060db4','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.84.217\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/152.0.7977.64 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x532\", \"hardware_concurrency\": 4}','216.247.84.217','Safari 604',1,'2026-09-09 00:59:03','2026-09-09 00:59:03','2026-09-09 00:59:03'),(37,3,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','216.247.83.70','Chrome 152',1,'2026-09-10 00:40:13','2026-09-10 00:23:58','2026-09-10 00:40:13'),(38,4,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','216.247.83.70','Chrome 152',1,'2026-09-10 00:39:29','2026-09-10 00:28:28','2026-09-10 00:39:29'),(39,5,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','216.247.83.70','Chrome 152',1,'2026-09-10 00:38:11','2026-09-10 00:34:49','2026-09-10 00:38:11'),(40,3,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','216.247.83.70','Chrome 151',1,'2026-09-10 00:36:28','2026-09-10 00:36:02','2026-09-10 00:36:28'),(41,4,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"216.247.83.70\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','216.247.83.70','Chrome 151',0,'2026-09-10 00:37:32','2026-09-10 00:37:28','2026-09-10 00:39:46');
/*!40000 ALTER TABLE `device_fingerprints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_signatures`
--

DROP TABLE IF EXISTS `digital_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_signatures`
--

LOCK TABLES `digital_signatures` WRITE;
/*!40000 ALTER TABLE `digital_signatures` DISABLE KEYS */;
INSERT INTO `digital_signatures` VALUES (25,20,'leave_request',4,'MEYCIQDaXQZoZXImir4AGp438Y6FFvUGE0ngW-yW7hmLSr5IzAIhAPIxsVHxuahgsmJub1xW3NNqPPdAPJh4PKAfficuLQxq','{\"type\":\"webauthn\",\"signature\":\"MEYCIQDaXQZoZXImir4AGp438Y6FFvUGE0ngW-yW7hmLSr5IzAIhAPIxsVHxuahgsmJub1xW3NNqPPdAPJh4PKAfficuLQxq\",\"credential_id\":\"CDMsK0qnmLmUJa-0ga46wA\",\"assertion\":{\"id\":\"CDMsK0qnmLmUJa-0ga46wA\",\"rawId\":\"CDMsK0qnmLmUJa-0ga46wA\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoidzRjRDJBMFR6c19iM1RaNGpBUlRXZ3JXZ2trWG1Hank3Ni1RNEtydnhaMUhralhjaDhDYzYxbmxha2hIMFkwQVpINVMwWk1JQXc4clNYSFNmWlhZeWciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEYCIQDaXQZoZXImir4AGp438Y6FFvUGE0ngW-yW7hmLSr5IzAIhAPIxsVHxuahgsmJub1xW3NNqPPdAPJh4PKAfficuLQxq\",\"userHandle\":\"NA\"}},\"challenge\":\"w4cD2A0Tzs_b3TZ4jARTWgrWgkkXmGjy76-Q4KrvxZ1HkjXch8Cc61nlakhH0Y0AZH5S0ZMIAw8rSXHSfZXYyg\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIJrR9uBXyegXsgdb5zpcDpljgya1wcbxtaIp8JUE488FIlgg9K+CrR\\/wbyL6esmxKQHguZtIVkb6mndRUecEE+b3t1E=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"479235dc87c09ceb59e56a4847d18d00647e52d19308030f2b4971d27d95d8ca\"}','2026-09-10 00:39:14',1,'2026-09-10 00:39:14'),(26,20,'leave_request',3,'MEUCIDDwGdz1qlV40xILgklpC0-rzDmp08bJwQlk8rFPqXUzAiEAsJru7bVzsija_hw0sriEdzT86F5aGgKtmrJ0K4ohUSU','{\"type\":\"webauthn\",\"signature\":\"MEUCIDDwGdz1qlV40xILgklpC0-rzDmp08bJwQlk8rFPqXUzAiEAsJru7bVzsija_hw0sriEdzT86F5aGgKtmrJ0K4ohUSU\",\"credential_id\":\"IzrRDRtlTS51EQFWQfV35Q\",\"assertion\":{\"id\":\"IzrRDRtlTS51EQFWQfV35Q\",\"rawId\":\"IzrRDRtlTS51EQFWQfV35Q\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoieGV3MHJKSlZuMEt4Yk5lVmFXekk4dDR5QUI2dXBSN0k3U1FIWU85d204OUhralhjaDhDYzYxbmxha2hIMFkwQVpINVMwWk1JQXc4clNYSFNmWlhZeWciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZSwib3RoZXJfa2V5c19jYW5fYmVfYWRkZWRfaGVyZSI6ImRvIG5vdCBjb21wYXJlIGNsaWVudERhdGFKU09OIGFnYWluc3QgYSB0ZW1wbGF0ZS4gU2VlIGh0dHBzOi8vZ29vLmdsL3lhYlBleCJ9\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIDDwGdz1qlV40xILgklpC0-rzDmp08bJwQlk8rFPqXUzAiEAsJru7bVzsija_hw0sriEdzT86F5aGgKtmrJ0K4ohUSU\",\"userHandle\":\"Mw\"}},\"challenge\":\"xew0rJJVn0KxbNeVaWzI8t4yAB6upR7I7SQHYO9wm89HkjXch8Cc61nlakhH0Y0AZH5S0ZMIAw8rSXHSfZXYyg\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":3,\"credential\":{\"public_key\":\"pQECAyYgASFYIMVrzX7GjtM2teZbFYGs2jyBkQZKQgxzNlGmOyFjTAiWIlggFqIPcM+7AfV5i79sn1WSC1qDc4SMBZ4HUbmMy+gpVkg=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"479235dc87c09ceb59e56a4847d18d00647e52d19308030f2b4971d27d95d8ca\"}','2026-09-10 00:40:26',1,'2026-09-10 00:40:26');
/*!40000 ALTER TABLE `digital_signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_approvals`
--

DROP TABLE IF EXISTS `leave_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_approvals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `leave_request_id` int NOT NULL,
  `approver_id` int NOT NULL,
  `approval_level` enum('supervisor','hr') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` text COLLATE utf8mb4_unicode_ci,
  `digital_signature` text COLLATE utf8mb4_unicode_ci,
  `signature_timestamp` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `approver_id` (`approver_id`),
  KEY `idx_leave_approval_request` (`leave_request_id`),
  KEY `idx_leave_approval_level` (`approval_level`),
  CONSTRAINT `leave_approvals_ibfk_1` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_approvals_ibfk_2` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_approvals`
--

LOCK TABLES `leave_approvals` WRITE;
/*!40000 ALTER TABLE `leave_approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_balances`
--

DROP TABLE IF EXISTS `leave_balances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
  UNIQUE KEY `uq_user_leave_type` (`user_id`,`leave_type_id`),
  UNIQUE KEY `unique_user_leave_type` (`user_id`,`leave_type_id`),
  KEY `leave_type_id` (`leave_type_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_fiscal_year` (`fiscal_year`),
  CONSTRAINT `leave_balances_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_balances_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES (1,1,1,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(2,1,2,5.00,0.00,0.00,5.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(15,1,3,99.00,0.00,0.00,99.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(16,1,4,105.00,0.00,0.00,105.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(17,1,5,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(18,1,6,3.00,0.00,0.00,3.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(115,3,1,7.00,0.00,0.00,7.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(116,3,2,5.00,0.00,0.00,5.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(117,3,3,999.00,0.00,0.00,999.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(118,3,4,105.00,0.00,0.00,105.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(119,3,5,7.00,0.00,0.00,7.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(120,3,6,3.00,0.00,0.00,3.00,2026,'2026-09-10 00:23:58','2026-09-10 00:23:58'),(121,4,1,7.00,0.00,7.00,0.00,2026,'2026-09-10 00:28:28','2026-09-10 00:32:16'),(122,4,2,5.00,0.00,5.00,0.00,2026,'2026-09-10 00:28:28','2026-09-10 00:32:32'),(123,4,3,999.00,0.00,7.00,992.00,2026,'2026-09-10 00:28:28','2026-09-10 00:32:57'),(124,4,4,105.00,0.00,0.00,105.00,2026,'2026-09-10 00:28:28','2026-09-10 00:28:28'),(125,4,5,7.00,0.00,0.00,7.00,2026,'2026-09-10 00:28:28','2026-09-10 00:28:28'),(126,4,6,3.00,0.00,0.00,3.00,2026,'2026-09-10 00:28:28','2026-09-10 00:28:28'),(127,5,1,7.00,0.00,0.00,7.00,2026,'2026-09-10 00:34:49','2026-09-10 00:34:49'),(128,5,2,5.00,0.00,0.00,5.00,2026,'2026-09-10 00:34:49','2026-09-10 00:34:49'),(129,5,3,999.00,0.00,0.00,999.00,2026,'2026-09-10 00:34:49','2026-09-10 00:34:49'),(130,5,4,105.00,0.00,0.00,105.00,2026,'2026-09-10 00:34:49','2026-09-10 00:34:49'),(131,5,5,7.00,1.00,0.00,6.00,2026,'2026-09-10 00:34:49','2026-09-10 00:40:26'),(132,5,6,3.00,0.00,0.00,3.00,2026,'2026-09-10 00:34:49','2026-09-10 00:34:49');
/*!40000 ALTER TABLE `leave_balances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
  `approval_stage` enum('pending_supervisor','pending_hr','approved','rejected','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending_supervisor',
  `manager_id` int DEFAULT NULL,
  `manager_comments` text COLLATE utf8mb4_unicode_ci,
  `hr_id` int DEFAULT NULL,
  `hr_comments` text COLLATE utf8mb4_unicode_ci,
  `digital_signature` text COLLATE utf8mb4_unicode_ci,
  `signature_timestamp` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `leave_type_id` (`leave_type_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_manager_id` (`manager_id`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `hr_id` (`hr_id`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`),
  CONSTRAINT `leave_requests_ibfk_3` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `leave_requests_ibfk_4` FOREIGN KEY (`hr_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (17,4,1,'2026-09-21','2026-09-29',7.00,'test\n','pending','not_required','pending','pending_supervisor',3,NULL,NULL,NULL,NULL,NULL,'2026-09-10 00:32:16','2026-09-10 00:32:16'),(18,4,2,'2026-09-01','2026-09-07',5.00,'sick\n','pending','not_required','pending','pending_supervisor',3,NULL,NULL,NULL,NULL,NULL,'2026-09-10 00:32:32','2026-09-10 00:32:32'),(19,4,3,'2026-10-01','2026-10-09',7.00,'testing','pending','not_required','pending','pending_supervisor',3,NULL,NULL,NULL,NULL,NULL,'2026-09-10 00:32:57','2026-09-10 00:32:57'),(20,5,5,'2026-09-10','2026-09-10',1.00,'test\n','approved','approved','approved','pending_supervisor',4,'',3,'test','MEUCIDDwGdz1qlV40xILgklpC0-rzDmp08bJwQlk8rFPqXUzAiEAsJru7bVzsija_hw0sriEdzT86F5aGgKtmrJ0K4ohUSU','2026-09-10 00:40:26','2026-09-10 00:38:38','2026-09-10 00:40:26');
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
INSERT INTO `leave_types` VALUES (1,'Vacation Leave','Paid vacation leave; must be filed at least 3 days before the requested start date',7,1,0,'2026-09-09 03:27:32','2026-09-09 03:27:32'),(2,'Sick Leave','Leave for medical reasons',5,1,0,'2026-09-09 03:27:32','2026-09-09 03:27:32'),(3,'Leave Without Pay','Unpaid leave, only usable once Vacation and Sick leave balances are exhausted',999,0,1,'2026-09-09 03:27:32','2026-09-09 03:27:32'),(4,'Maternity Leave','Leave for maternity (RA 11210); female employees only',105,1,1,'2026-09-09 03:27:32','2026-09-09 03:27:32'),(5,'Paternity Leave','Leave for paternity (RA 8187); male employees only',7,1,1,'2026-09-09 03:27:32','2026-09-09 03:27:32'),(6,'Bereavement Leave','Leave for the death of an immediate family member',3,1,1,'2026-09-09 03:27:32','2026-09-09 03:27:32');
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mfa_secrets`
--

DROP TABLE IF EXISTS `mfa_secrets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (10,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-08-27 06:25:48',NULL),(21,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',2,0,'2026-09-02 01:12:20',NULL),(22,1,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',7,0,'2026-09-03 03:29:25',NULL),(25,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-09-03 03:50:56',NULL),(45,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',2,0,'2026-09-08 06:32:31',NULL),(46,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',2,0,'2026-09-08 06:32:31',NULL),(47,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',4,0,'2026-09-08 06:39:12',NULL),(48,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',4,0,'2026-09-08 06:39:14',NULL),(58,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-09-09 00:21:30',NULL),(64,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',3,0,'2026-09-10 00:24:20',NULL),(65,3,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-09-10 00:28:50',NULL),(66,3,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',17,0,'2026-09-10 00:32:16',NULL),(67,3,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',18,0,'2026-09-10 00:32:32',NULL),(68,3,'New Leave Request','New leave request from Ronnie Formento','info','leave_request',19,0,'2026-09-10 00:32:57',NULL),(69,4,'New Account Pending Approval','Cyril Christian Gardon has requested account activation.','info','user',5,0,'2026-09-10 00:35:16',NULL),(70,4,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',20,0,'2026-09-10 00:38:38',NULL),(71,3,'New Leave Request','New leave request awaiting HR approval','info','leave_request',20,0,'2026-09-10 00:39:14',NULL),(72,5,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-10 to 2026-09-10. It now awaits HR approval.','info','leave_request',20,0,'2026-09-10 00:39:14',NULL),(73,5,'Leave Request Approved','Your leave request from 2026-09-10 to 2026-09-10 has been approved.','info','leave_request',20,0,'2026-09-10 00:40:26',NULL);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `can_approve` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'employee','Employee / Staff',0,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(2,'faculty','Faculty / Instructor',0,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(3,'department_head','Department Head',1,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(4,'coordinator','Coordinator / Program Chair',1,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(5,'dean_principal','Dean / Principal',1,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(6,'hr_admin','HR Administrator',1,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(7,'system_admin','System Administrator',1,1,'2026-08-26 03:30:08','2026-08-26 03:30:08');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (4,1,'9d644fe40a7335ef22ca54b89e3209a9a15b885070c74e303c1ae4460318816e',2,'203.177.49.42','2026-08-26 07:00:05','2026-08-26 05:52:02'),(26,1,'849b6098df773bd47471547225ab32abc42251b970bcdc7d98b33dff7957dbf4',5,'136.158.103.18','2026-08-26 12:59:36','2026-08-26 11:39:44'),(29,1,'9057d05753845ea9ba4ff8b49e5a729f16cb963f95f6c89b9945d7b7fce5d1ee',2,'209.35.170.100','2026-08-27 01:18:19','2026-08-27 00:03:56'),(91,1,'61c4e4bde3ff5cb3277cb52b75ed524626180c886c8b68df3bfbb57072ecd917',11,'216.247.85.11','2026-10-03 03:51:47','2026-09-03 03:48:46'),(94,1,'e49e33319cee79c94601494bbbe14c41844cc4610cd52e904a800673e50c96f1',9,'216.247.85.11','2026-10-03 03:51:40','2026-09-03 03:51:40'),(174,1,'d32c90baebe0e815bf59038ec44032191144ee0bc1462a890c63164a030abd5e',11,'216.247.84.217','2026-10-09 01:36:11','2026-09-09 00:49:10'),(182,1,'d951d3b9cd334431a50bdc37b857994bd004e2add025cefb732ff10eb465adc6',34,'216.247.84.217','2026-10-10 00:37:28','2026-09-09 00:59:03'),(187,1,'cd3bb9080b647246f08927ea4e681ba05841ca3e72bfbb40a5bd22a70f0e6389',11,'216.247.84.217','2026-10-09 03:31:51','2026-09-09 03:30:56'),(204,1,'88456bef799ba49f34aecb54a589313e232718668843d828d92968e60691cf4c',11,'216.247.83.70','2026-10-10 01:39:36','2026-09-10 00:34:16'),(211,3,'690efcc5c5abddb75adb9d2890919e391b4c4da99b589ebafc8940a89cea6426',37,'216.247.83.70','2026-10-10 01:39:36','2026-09-10 00:40:13');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sub_departments`
--

DROP TABLE IF EXISTS `sub_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sub_departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `department_id` int NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_sub_department_parent` (`department_id`),
  KEY `idx_sub_department_active` (`is_active`),
  CONSTRAINT `sub_departments_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sub_departments`
--

LOCK TABLES `sub_departments` WRITE;
/*!40000 ALTER TABLE `sub_departments` DISABLE KEYS */;
INSERT INTO `sub_departments` VALUES (1,1,'ADMIN_HR','Human Resources',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(2,1,'ADMIN_REGISTRAR','Registrar',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(3,1,'ADMIN_CASHIER','Cashier / Bursar',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(4,1,'ADMIN_SASO','SASO',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(5,1,'ADMIN_IT','IT Support',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(6,2,'BED_PRESCHOOL','Preschool',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(7,2,'BED_ELEMENTARY','Elementary',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(8,2,'BED_JUNIOR_HIGH','Junior High School',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(9,2,'BED_SENIOR_HIGH','Senior High School',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(10,3,'HED_CCS','College of Computer Studies (CCS)',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(11,3,'HED_CBE','College of Business Education (CBE)',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08'),(12,3,'HED_CTE','College of Teacher Education (CTE)',NULL,1,'2026-08-26 03:30:08','2026-08-26 03:30:08');
/*!40000 ALTER TABLE `sub_departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_id_sequence`
--

DROP TABLE IF EXISTS `user_id_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
INSERT INTO `user_id_sequence` VALUES (1,6);
/*!40000 ALTER TABLE `user_id_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
  `sub_department_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `activation_status` enum('pending_supervisor','pending_hr','active','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
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
  KEY `idx_sub_department_id` (`sub_department_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_supervisor_id` (`supervisor_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`sub_department_id`) REFERENCES `sub_departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_ibfk_3` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@thelewiscollege.edu.ph','$2y$10$VYHGcBlY1AY9YAnbwcxG9uj5fjLUT9WwOks2TuBj/hxOtS/APudJy','System Administrator','ADMIN',NULL,'male',NULL,'admin',NULL,7,'active',1,NULL,NULL,1,'2026-08-26 03:32:46','2026-08-27 00:45:08'),(3,'josefjurendelcastro','josefjurendelcastro@thelewiscollege.edu.ph','$2y$10$zi.z9kN3g4EerlRB9sIeAe0q/paZ5ZaKUnL6w/UU3x4j.T7nFEP72','Josef Jurendel Castro','ADMIN','HR Officer','male',1,'hr',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA8NoIjL8Gz7+XMfVDrJIE\nThXGHvBmyG3OkkZRxYYWnnS8tdBXHln2razdplF+ejWmOn26RieTAX+r4+Mn8UII\n+WsJpIU40xhJWyueWFQOdIzTpiHjIru0pV5WvWnAHq/lEbSnnfYJNbwBlmAvf4Mc\nkWm9WDPEuCmVP6KbjR7KYe17K88dPhA0MH3C5SqHunxgIfXBay43MIPjsW+dam1i\ndwp4oQVs88zoPpn+i17NhshnEXgrcM6rs29eIuBCgfCc0hwwb6YZ5Qb62cCeIEtq\nGuzQOW6YpSd7mrsVlHmHYUVom/aCT9rsxl63s4BKm9edqruFKD4BCQedi+h4Ywag\niC4oihMVBeyNSsu+9Znz4SGg30Uc8klpWLMO0+HWi1KK+PR9776/iXWWfocxOER9\nOrmYzdjySfIQXpbLXYdXzGbPtObom+P7ONKdqWT9ZZZuNmPhklkXFvVZhesjPdaX\np4Z/i/gQH3cdcEAvf0EgOLJjaLrnUO4Fv1iJv64ltp94q8VdUosd51fbQW5uo3Us\n5liLCEPyLhrJOoZYayK8YkL94JDmJn8tlsc0qOioKZ9JTPUeSENNeCoxWHs8AfSp\ntWbHGUxH6JIodcuv0Ch60scER9MWhe8ltjHCuwz64ur1WSG44QdlbfaAqBWpUv0d\n4DEdLokpG9Ej1emDhZ+zcD0CAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-10 00:23:58','2026-09-10 00:26:55'),(4,'ronnieformento','ronnieformento@thelewiscollege.edu.ph','$2y$10$djVQxIHDGj2H8LGGJTAlLejcIZKhtLmPBEqVD43n79F2/0UQiQi7y','Ronnie Formento','CCS','Dean','female',3,'manager',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsKNI+9moMfXUjJMHgRZc\nJmyi+cS/XJ2jPDqBExms8OqjmN7oOFNTXfk/ch7dKICVfL2Apj+Exid1KXgMBAYU\nEIo303LcA8h5lMoaCRS06ZlqNGpKYNKgrbCpxDKspDJBTLlgIhAUvxEMaZ5N7VWt\nZGxUKWwb/Ix3ETUXe7k4zo0NKINQoPjbdQCojNRr0wfq8tOLES0wwv6xG8uRC6M5\nrdKb1Fd5mXc6mej26wisGl1ge5T9iOG4dvF3WhSKZNy6P1TqQj2FFDInK0pBcj3A\ngm/kcKxeGrAOC6BpMXRnaQkNcb3N+44lYPL6k8MyAv4pNlpngJIDGLkU30ypu1kB\n20zocQPPBcBEBQ66VvjZs+x45oPMC4n+uTfGsGGlHur2F/9BWOOb93BUkz8s1KNo\nAJOFRvjcOp4HVBq6fJgBFQi0fIb5VrkE4AToAXKS3VzD/LpN3fJ+tnFTjzgJ8hIa\nL0cQ6RXBGg/4TX/EBuRDrYZmaR5JSdUulqsB1gX1lM1OWDB+kgv9drAMMiZ+519f\ngsmubHyO/Ba0u2/J4oihuPvyCS5XaEXUutCH4eXLwkDKpFwXxwryAnVp/Gkz6qjw\nQ3CKxZMUuCQzkqqvrNW3FB7js99LFeVwq2cokwgxV1KNecpqLf7eQ9aJcTmBlBhj\niFMtwIaOwVQeudbuEtsQtAUCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-10 00:28:28','2026-09-10 00:29:43'),(5,'cyrilchristiangardon','cyrilchristiangardon@thelewiscollege.edu.ph','$2y$10$QRuRgUjcOvn2U9KwFgKz5OXH.Mlk.BBL4WeCMBZyGsVcEeZs1vWgK','Cyril Christian Gardon','CCS','Instructor','male',4,'employee',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtkMyypbvpGUR6J/4kVUX\n1iFdC3iTnhqDRJE7coAtfPKFw6gTv2i0GF6peEZz12EGSveaSZjPGCwJwG8N0+ru\nDpHyLdIeE4ujn+oGfj6cZtDgYi3FEqwTFyqwDdS2IB5447a66HVMqetLj2A7xak+\nPOXZ5YbZEye5ceu3+qWCKLEr9xwM9ebhgdGJT2e1beePczx4Htv7cMgJX0CNLqmh\ntYZwojnjGVN5fSNOmufrsdCbcJ0XIg1ntzHJUjoWEjTdonXnK0ekxs7AyE/6JGSa\naF0LKIF0G8k2/mruEzx/D7sIUF3HAcSzA+hB1f3CPfrYDiN4c8WjeEEYDRRlBgk0\nZ4BSdszSwfnpkL5C9+X3mG/lYHQu3QoO2FZ4RjaxXlngWijQ/38DPPrQ3OUdlQzC\njAsKKol6kOsQcpwkBNueppxSEwy5Xqb3qzsFIymzRLAPNYE5AJQ8rMR/2Q6zYEPc\n9ctWWTNCnKL8JtSOHqB780YwyPMJPsLAQvV1r0IKe0s/TkwtWlwud5sZ/2CnkCNq\nX3o26ezbCFzpuLww86YLD3PtRUxLVQ84ajqsWR5gKsJoBlwRwChcuLbZdU1j04jP\n9QRTXTObw54RH+iimQY4gTqqqGigXrv3Cp3LprzzRWxLZrPSmkVFqcYuLoY6Rg0k\naw5NeBMA7WM74PhghjkIcgkCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-10 00:34:49','2026-09-10 00:37:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webauthn_challenges`
--

DROP TABLE IF EXISTS `webauthn_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_challenges`
--

LOCK TABLES `webauthn_challenges` WRITE;
/*!40000 ALTER TABLE `webauthn_challenges` DISABLE KEYS */;
INSERT INTO `webauthn_challenges` VALUES (24,1,'nOaG8AxHqTmPl5JQ6vsq6Fnbl8HmbAAv5PXRGsRoxKU','approval','device_change',7,'2026-08-27 06:34:27','2026-08-27 06:29:27'),(30,1,'Wt_XMjjKEHtAbwUgwi71oHMLGmVrf_yizu5JGB2u4xI','approval','device_change',9,'2026-08-27 10:07:17','2026-08-27 10:02:17'),(56,1,'bz1aPmo4Qs2MCBX1nZ9jBmiqN7mFnmOwfhE94u3R-BY','approval','device_change',15,'2026-09-03 05:17:35','2026-09-03 05:12:35'),(84,1,'gRDqvlswaewclA50ETWEkTDz1bW3VE9otA2YR0m1IpQ','approval','device_change',19,'2026-09-08 06:58:12','2026-09-08 06:53:12'),(102,1,'kyNAFzfZO-qssR2ytEDaGvE-goPXgq8ahU7GKsJE2SY','approval','device_change',23,'2026-09-09 01:04:46','2026-09-09 00:59:46'),(103,1,'G-1mLQNgTFpxN-9Y60zLTJWF1o47ri9i-dFS0ETJ-9g','approval','device_change',23,'2026-09-09 01:04:52','2026-09-09 00:59:52'),(104,1,'_sc0kqOSQ_rlWfSoPb4CzBNJADpQbcBaCzgpD29B1No','approval','device_change',23,'2026-09-09 01:05:03','2026-09-09 01:00:03'),(105,1,'dGlHTPH8LMTZGrXEE1SZftKk5weA8zHKmxvOa1m-Zi4','approval','device_change',23,'2026-09-09 01:05:04','2026-09-09 01:00:04'),(106,1,'4GKefWfLEbhj7Zmvp-aEjIBWV3hQ0BnuritZe9MBoX8','approval','device_change',23,'2026-09-09 01:05:04','2026-09-09 01:00:04'),(107,1,'tIyKeUTkLtHZmh9aTAd8aER_55Ef33c8EqIfjWXjhQI','approval','device_change',23,'2026-09-09 01:05:04','2026-09-09 01:00:04'),(108,1,'biRb0PiCGpK2b8RafCSU0BM5cXGzgnVX_xBCF6-a6Wg','approval','device_change',23,'2026-09-09 01:05:09','2026-09-09 01:00:09'),(114,1,'q-5bhfAaBle8Yf-XecHVOzkGT_170XIYG6CLSCz3sxA','approval','device_change',24,'2026-09-10 00:39:42','2026-09-10 00:34:42'),(115,1,'8lOUHM9qqoByoWSvnlOx-TTLXIl--tuqB6OqbHRcXiA','registration',NULL,NULL,'2026-09-10 00:40:26','2026-09-10 00:35:26');
/*!40000 ALTER TABLE `webauthn_challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webauthn_credentials`
--

DROP TABLE IF EXISTS `webauthn_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_credentials`
--

LOCK TABLES `webauthn_credentials` WRITE;
/*!40000 ALTER TABLE `webauthn_credentials` DISABLE KEYS */;
INSERT INTO `webauthn_credentials` VALUES (18,1,'kk4zhIXMi5s_VRJLXKf6A9TJBPg','pQECAyYgASFYIF/LVxgAZTXyojajZUkny6WpRAH0RiVnYXhICauzauqbIlggpNTxf9BIExon1zt0v+5csSK/ippPL7trgZc+mS++yJQ=','none',NULL,'fbfc3007-154e-4ecc-8c0b-6e020557d7bd','[]',0,'Passkey','30c190c18197ac61c2be6da06dfec5df73f010d40c364d4a6f28b519372f4e3f','Safari • iPhone','2026-09-09 00:59:30','2026-09-10 00:37:28'),(19,3,'IzrRDRtlTS51EQFWQfV35Q','pQECAyYgASFYIMVrzX7GjtM2teZbFYGs2jyBkQZKQgxzNlGmOyFjTAiWIlggFqIPcM+7AfV5i79sn1WSC1qDc4SMBZ4HUbmMy+gpVkg=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','ae0b268077de8046ff0c36bc810656983c652257c17979a8f903b722d0aae064','Chrome • Windows PC','2026-09-10 00:33:51','2026-09-10 00:40:26'),(20,4,'CDMsK0qnmLmUJa-0ga46wA','pQECAyYgASFYIJrR9uBXyegXsgdb5zpcDpljgya1wcbxtaIp8JUE488FIlgg9K+CrR/wbyL6esmxKQHguZtIVkb6mndRUecEE+b3t1E=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','6220888a45abdcda8d583a34fc97d2faa3aff57df20af69a955ed4600576df02','Chrome • Android Device','2026-09-10 00:37:44','2026-09-10 00:39:14');
/*!40000 ALTER TABLE `webauthn_credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'railway'
--

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

-- Dump completed on 2026-09-10  1:41:20
