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
) ENGINE=InnoDB AUTO_INCREMENT=350 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (5,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:02'),(6,1,'update_user','user',2,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:25'),(10,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 06:08:07'),(22,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:28'),(23,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:32'),(24,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:37'),(29,1,'login_failed','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:01'),(30,1,'login_success','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:09'),(31,1,'device_request_approved','device_change_request',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:31'),(37,1,'login_success','user',1,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:39:44'),(39,1,'device_request_approved','device_change_request',2,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:42:09'),(45,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:03:56'),(46,1,'device_request_approved','device_change_request',4,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:06'),(47,1,'device_request_approved','device_change_request',3,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:09'),(48,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:20:15'),(52,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:35:42'),(57,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:44:43'),(58,1,'password_changed','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:08'),(59,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:18'),(63,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 01:56:42'),(70,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:41:18'),(71,1,'webauthn_credential_registered','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:05'),(72,1,'device_request_approved','device_change_request',5,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:22'),(76,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:44:28'),(78,1,'device_request_approved','device_change_request',6,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:47:13'),(88,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:01'),(89,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:03'),(90,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:06'),(91,1,'update_user','user',4,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:16'),(101,1,'login_success','user',1,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:29:10'),(102,1,'device_request_approved','device_change_request',7,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:30:17'),(117,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:40'),(118,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:42'),(119,1,'device_request_approved','device_change_request',8,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:01:03'),(123,1,'device_request_approved','device_change_request',9,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:02:38'),(130,1,'login_failed','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:52'),(131,1,'login_success','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:55'),(137,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-02 01:12:33'),(145,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:05:13'),(147,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:06:56'),(152,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:24:57'),(153,1,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:25:08'),(158,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:30:33'),(165,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:21'),(166,1,'approve_leave_request','leave_request',7,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:49'),(167,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:48:46'),(170,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:29'),(171,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:40'),(172,1,'update_user','user',4,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:52:21'),(175,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:24'),(176,1,'device_request_approved','device_change_request',11,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:49'),(177,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 04:15:57'),(183,1,'device_request_approved','device_change_request',12,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:23:00'),(194,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:21'),(195,1,'device_request_approved','device_change_request',13,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:40'),(197,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:00'),(200,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:31'),(201,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:16'),(202,1,'device_request_approved','device_change_request',14,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:27'),(207,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:12:25'),(208,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:14:20'),(209,1,'device_request_approved','device_change_request',15,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:15:45'),(219,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:37'),(220,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:54'),(221,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:00'),(222,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:03'),(223,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:08'),(224,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:15'),(225,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:17'),(231,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:07'),(232,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:16'),(233,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:20'),(234,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:53'),(235,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:59'),(236,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:01'),(237,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:14'),(238,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:22'),(239,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:26'),(240,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:31'),(241,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:33'),(246,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:55'),(247,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:20'),(248,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:31'),(249,1,'device_request_approved','device_change_request',16,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:41'),(265,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:01'),(266,1,'device_request_approved','device_change_request',17,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:20'),(267,1,'approve_leave_request_supervisor','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:31'),(268,1,'approve_leave_request','leave_request',9,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:42'),(269,1,'reject_leave_request','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:57:00'),(286,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:13:58'),(287,1,'device_request_approved','device_change_request',18,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:14:10'),(299,NULL,'login_failed','user',NULL,NULL,'{\"username\": \"josefjurendelcastro\"}','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:06:16'),(300,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:06:20'),(301,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:07:08'),(302,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:07:34'),(303,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:08:10'),(304,NULL,'login_success_google','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:23:40'),(305,NULL,'login_failed','user',NULL,NULL,'{\"username\": \"cyrilchristiangardon\"}','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:23:50'),(306,4,'login_success_google','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:30:40'),(307,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:31:07'),(308,2,'password_set','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:32:31'),(309,2,'password_set','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:32:31'),(310,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:34:42'),(311,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:36:04'),(312,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:36:23'),(313,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:37:25'),(314,4,'password_set','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:39:12'),(315,4,'password_set','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:39:14'),(316,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:39:27'),(317,1,'update_user','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:39:39'),(318,NULL,'login_success_google','user',5,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:40:10'),(319,NULL,'login_failed','user',NULL,NULL,'{\"username\": \"cyrilchristiangardon\"}','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:40:23'),(320,6,'login_success_google','user',6,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:40:29'),(321,6,'password_set','user',6,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:45:57'),(322,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:46:36'),(323,4,'login_success_google','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:47:57'),(324,4,'approve_user','user',6,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:48:20'),(325,6,'login_success','user',6,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:48:33'),(326,6,'create_leave_request','leave_request',14,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:48:54'),(327,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:49:33'),(328,4,'webauthn_credential_registered','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:49:44'),(329,4,'approve_leave_request_supervisor','leave_request',14,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:50:33'),(330,6,'login_success','user',6,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:51:42'),(331,6,'create_leave_request','leave_request',15,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:52:07'),(332,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:52:33'),(333,4,'device_change_requested','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:52:43'),(334,4,'login_failed_untrusted_device','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:52:43'),(335,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:52:50'),(336,1,'device_request_approved','device_change_request',19,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:53:50'),(337,4,'login_success','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:54:33'),(338,4,'login_success_google','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:54:51'),(339,4,'webauthn_approval_device_mismatch','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:54:56'),(340,4,'approve_leave_request_supervisor','leave_request',15,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-08 06:55:12'),(341,2,'device_change_requested','user',2,NULL,'[]','175.158.217.57','474d46af7a99e57234f673a9d7a1197a29979f76a6515bf196d0e7a41333d938','2026-09-08 06:56:03'),(342,2,'login_failed_untrusted_device','user',2,NULL,'[]','175.158.217.57','474d46af7a99e57234f673a9d7a1197a29979f76a6515bf196d0e7a41333d938','2026-09-08 06:56:03'),(343,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:56:19'),(344,1,'device_request_approved','device_change_request',20,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-08 06:56:31'),(345,2,'login_success','user',2,NULL,'[]','175.158.217.57','474d46af7a99e57234f673a9d7a1197a29979f76a6515bf196d0e7a41333d938','2026-09-08 06:56:35'),(346,2,'webauthn_credential_registered','user',2,NULL,'[]','175.158.217.57','474d46af7a99e57234f673a9d7a1197a29979f76a6515bf196d0e7a41333d938','2026-09-08 06:56:46'),(347,2,'approve_leave_request','leave_request',15,NULL,'[]','175.158.217.57','474d46af7a99e57234f673a9d7a1197a29979f76a6515bf196d0e7a41333d938','2026-09-08 06:57:01'),(348,2,'login_success','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:57:26'),(349,2,'reject_leave_request','leave_request',14,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-08 06:57:48');
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_change_requests`
--

LOCK TABLES `device_change_requests` WRITE;
/*!40000 ALTER TABLE `device_change_requests` DISABLE KEYS */;
INSERT INTO `device_change_requests` VALUES (19,4,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"180.193.218.250\",\"browser\":\"Chrome 152\",\"os\":\"Windows 10\",\"device\":\"Windows PC\",\"screen_resolution\":\"1536x730\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Win32\",\"hardware_concurrency\":12,\"device_memory\":16}','180.193.218.250','Chrome 152','approved','2026-09-08 06:52:43','2026-09-08 06:53:50',1),(20,2,'e44a38aebe8bea57ff7f26d2a63aec715d43b6e6a4d61828e67cca151f060db4','{\"user_agent\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) CriOS\\/152.0.7977.64 Mobile\\/15E148 Safari\\/604.1\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"175.158.217.57\",\"browser\":\"Safari 604\",\"os\":\"iOS 26.5.0\",\"device\":\"iPhone\",\"screen_resolution\":\"414x720\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"iPhone\",\"hardware_concurrency\":4,\"device_memory\":\"unknown\"}','175.158.217.57','Safari 604','approved','2026-09-08 06:56:03','2026-09-08 06:56:31',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_fingerprints`
--

LOCK TABLES `device_fingerprints` WRITE;
/*!40000 ALTER TABLE `device_fingerprints` DISABLE KEYS */;
INSERT INTO `device_fingerprints` VALUES (2,1,'0c82c8f821f00d8940a23e7b440b36ea2ae0f9fed0b06894671b3291fb3b78fa','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"110.54.141.165\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','110.54.141.165','Chrome 151',1,'2026-08-27 10:00:42','2026-08-26 05:52:02','2026-08-27 10:00:42'),(5,1,'25befb4fd7a4be2871b71dbdc19479a6559a154a7f7fcd620b393dd464e14999','{\"os\": \"macOS 10.15.7\", \"device\": \"Mac\", \"browser\": \"Chrome 150\", \"language\": \"en-US\", \"platform\": \"MacIntel\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"136.158.103.18\", \"user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36\", \"device_memory\": 8, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1470x835\", \"hardware_concurrency\": 8}','136.158.103.18','Chrome 150',1,'2026-08-26 11:39:44','2026-08-26 11:39:44','2026-08-26 11:39:44'),(9,1,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','203.177.49.42','Chrome 151',1,'2026-09-03 05:12:25','2026-08-27 06:29:10','2026-09-03 05:12:25'),(11,1,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 152',1,'2026-09-08 06:56:19','2026-09-01 23:58:55','2026-09-08 06:56:19'),(19,2,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"180.193.218.250\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','180.193.218.250','Chrome 152',1,'2026-09-08 06:57:26','2026-09-08 06:07:08','2026-09-08 06:57:26'),(21,4,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"\", \"platform\": \"\", \"timezone\": \"UTC\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"unknown\", \"hardware_concurrency\": \"unknown\"}','203.177.49.42','Chrome 151',1,'2026-09-08 06:54:51','2026-09-08 06:30:40','2026-09-08 06:54:51'),(23,6,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 152',1,'2026-09-08 06:51:42','2026-09-08 06:40:29','2026-09-08 06:51:42'),(24,4,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"180.193.218.250\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','180.193.218.250','Chrome 152',1,'2026-09-08 06:54:33','2026-09-08 06:53:50','2026-09-08 06:54:33'),(25,2,'e44a38aebe8bea57ff7f26d2a63aec715d43b6e6a4d61828e67cca151f060db4','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"175.158.217.57\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/152.0.7977.64 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x720\", \"hardware_concurrency\": 4}','175.158.217.57','Safari 604',1,'2026-09-08 06:56:35','2026-09-08 06:56:31','2026-09-08 06:56:35');
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_signatures`
--

LOCK TABLES `digital_signatures` WRITE;
/*!40000 ALTER TABLE `digital_signatures` DISABLE KEYS */;
INSERT INTO `digital_signatures` VALUES (20,14,'leave_request',4,'MEUCIQDP-rjnn8GvD_izW-fwhwHgVWDAyZT8D2jzGJ4XeXhoQQIgdQmfTdtwKHrXrbeMeLwPaKsEqPuf64pmXBler6ZBgpg','{\"type\":\"webauthn\",\"signature\":\"MEUCIQDP-rjnn8GvD_izW-fwhwHgVWDAyZT8D2jzGJ4XeXhoQQIgdQmfTdtwKHrXrbeMeLwPaKsEqPuf64pmXBler6ZBgpg\",\"credential_id\":\"QUaj0NkA8e36VBF7Wceq5w\",\"assertion\":{\"id\":\"QUaj0NkA8e36VBF7Wceq5w\",\"rawId\":\"QUaj0NkA8e36VBF7Wceq5w\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiUzR6NGF6akE1clhZVE9ENE9sdVFOUVN2OFhkeVNUTmJSdG0xTlhhV29mWU5yTEtYZnFUZS1uX1JsLWdxNzF6T3N1S2xSUDExQnM0Q01oUzJLOEpjNVEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIQDP-rjnn8GvD_izW-fwhwHgVWDAyZT8D2jzGJ4XeXhoQQIgdQmfTdtwKHrXrbeMeLwPaKsEqPuf64pmXBler6ZBgpg\",\"userHandle\":\"NA\"}},\"challenge\":\"S4z4azjA5rXYTOD4OluQNQSv8XdySTNbRtm1NXaWofYNrLKXfqTe-n_Rl-gq71zOsuKlRP11Bs4CMhS2K8Jc5Q\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIOu8ngztWuHIOj6+Xh+yyQE+LzMDvxgX5EXL6t+fQVrIIlgg8G8AghoSzRAjJHQlCvCjX4DljycPU\\/q7kZlLuQVvG+U=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"0dacb2977ea4defa7fd197e82aef5cceb2e2a544fd7506ce023214b62bc25ce5\"}','2026-09-08 06:50:33',1,'2026-09-08 06:50:33'),(21,15,'leave_request',4,'MEUCIB67sFRwcxEGkd5tvgKsfz9LOyyXHIZrm31m4oEJ0JNuAiEAlk6ERv6S56UBYNzKUmyXJTI4sfZMk0CDp7T7NWVEIyY','{\"type\":\"webauthn\",\"signature\":\"MEUCIB67sFRwcxEGkd5tvgKsfz9LOyyXHIZrm31m4oEJ0JNuAiEAlk6ERv6S56UBYNzKUmyXJTI4sfZMk0CDp7T7NWVEIyY\",\"credential_id\":\"QUaj0NkA8e36VBF7Wceq5w\",\"assertion\":{\"id\":\"QUaj0NkA8e36VBF7Wceq5w\",\"rawId\":\"QUaj0NkA8e36VBF7Wceq5w\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiMUVRRzd2eTA5YlhvT2xqSEhMOVdLOVFBdmlTUTBqZUJwWXczX1JKRHpEWkhSNWc4NVZBdy05NDdlcXp4cURWVUQ2eDdiNkFXYlFLS3ZlQkRtSU1zdXciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIB67sFRwcxEGkd5tvgKsfz9LOyyXHIZrm31m4oEJ0JNuAiEAlk6ERv6S56UBYNzKUmyXJTI4sfZMk0CDp7T7NWVEIyY\",\"userHandle\":\"NA\"}},\"challenge\":\"1EQG7vy09bXoOljHHL9WK9QAviSQ0jeBpYw3_RJDzDZHR5g85VAw-947eqzxqDVUD6x7b6AWbQKKveBDmIMsuw\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIOu8ngztWuHIOj6+Xh+yyQE+LzMDvxgX5EXL6t+fQVrIIlgg8G8AghoSzRAjJHQlCvCjX4DljycPU\\/q7kZlLuQVvG+U=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"4747983ce55030fbde3b7aacf1a835540fac7b6fa0166d028abde04398832cbb\"}','2026-09-08 06:55:12',1,'2026-09-08 06:55:12'),(22,15,'leave_request',2,'MEUCIF9-V2OLuaVb2ZoQZTOcuVM15SfGSDVh-I9RjrlMcBgPAiEA-jBxyDjP9tCyaSZmKv-ZhDnBfqAhIYxiMVzcfyASGTo','{\"type\":\"webauthn\",\"signature\":\"MEUCIF9-V2OLuaVb2ZoQZTOcuVM15SfGSDVh-I9RjrlMcBgPAiEA-jBxyDjP9tCyaSZmKv-ZhDnBfqAhIYxiMVzcfyASGTo\",\"credential_id\":\"z3A7Rii0Y71unspAo885iO7hLnE\",\"assertion\":{\"id\":\"z3A7Rii0Y71unspAo885iO7hLnE\",\"rawId\":\"z3A7Rii0Y71unspAo885iO7hLnE\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiaUNjVVNKYklvY1lzLTYwUnZqVEJodEJMZUYzMVdxQmJ6Z1N4Umh6SEJLSkhSNWc4NVZBdy05NDdlcXp4cURWVUQ2eDdiNkFXYlFLS3ZlQkRtSU1zdXciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIF9-V2OLuaVb2ZoQZTOcuVM15SfGSDVh-I9RjrlMcBgPAiEA-jBxyDjP9tCyaSZmKv-ZhDnBfqAhIYxiMVzcfyASGTo\",\"userHandle\":\"Mg\"}},\"challenge\":\"iCcUSJbIocYs-60RvjTBhtBLeF31WqBbzgSxRhzHBKJHR5g85VAw-947eqzxqDVUD6x7b6AWbQKKveBDmIMsuw\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIKos\\/fksgTSI9lp4bnjcQAiycGkP5\\/SGtXxmA7LE\\/U99IlggwEOW\\/0\\/0ZzszGsKwsyV5+KBBkaTeS7a9tIy46oRQo3U=\",\"attestation_type\":\"none\",\"aaguid\":\"fbfc3007-154e-4ecc-8c0b-6e020557d7bd\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"4747983ce55030fbde3b7aacf1a835540fac7b6fa0166d028abde04398832cbb\"}','2026-09-08 06:57:01',1,'2026-09-08 06:57:01');
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
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES (1,1,1,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(2,1,2,5.00,0.00,0.00,5.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(15,1,3,99.00,0.00,0.00,99.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(16,1,4,105.00,0.00,0.00,105.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(17,1,5,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(18,1,6,3.00,0.00,0.00,3.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(43,2,1,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(44,2,2,5.00,0.00,0.00,5.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(45,2,3,99.00,0.00,0.00,99.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(46,2,4,105.00,0.00,0.00,105.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(47,2,5,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(48,2,6,3.00,0.00,0.00,3.00,2026,'2026-09-08 06:07:08','2026-09-08 06:07:08'),(55,4,1,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(56,4,2,5.00,0.00,0.00,5.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(57,4,3,99.00,0.00,0.00,99.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(58,4,4,105.00,0.00,0.00,105.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(59,4,5,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(60,4,6,3.00,0.00,0.00,3.00,2026,'2026-09-08 06:30:40','2026-09-08 06:30:40'),(67,6,1,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:40:29','2026-09-08 06:57:48'),(68,6,2,5.00,1.00,0.00,4.00,2026,'2026-09-08 06:40:29','2026-09-08 06:57:01'),(69,6,3,99.00,0.00,0.00,99.00,2026,'2026-09-08 06:40:29','2026-09-08 06:40:29'),(70,6,4,105.00,0.00,0.00,105.00,2026,'2026-09-08 06:40:29','2026-09-08 06:40:29'),(71,6,5,7.00,0.00,0.00,7.00,2026,'2026-09-08 06:40:29','2026-09-08 06:40:29'),(72,6,6,3.00,0.00,0.00,3.00,2026,'2026-09-08 06:40:29','2026-09-08 06:40:29');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (14,6,1,'2026-09-11','2026-09-12',1.00,'test','rejected','approved','rejected','pending_supervisor',4,'test',2,'rest','MEUCIQDP-rjnn8GvD_izW-fwhwHgVWDAyZT8D2jzGJ4XeXhoQQIgdQmfTdtwKHrXrbeMeLwPaKsEqPuf64pmXBler6ZBgpg','2026-09-08 06:50:33','2026-09-08 06:48:54','2026-09-08 06:57:48'),(15,6,2,'2026-09-08','2026-09-08',1.00,'atest\n','approved','approved','approved','pending_supervisor',4,'test',2,'','MEUCIF9-V2OLuaVb2ZoQZTOcuVM15SfGSDVh-I9RjrlMcBgPAiEA-jBxyDjP9tCyaSZmKv-ZhDnBfqAhIYxiMVzcfyASGTo','2026-09-08 06:57:01','2026-09-08 06:52:07','2026-09-08 06:57:01');
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
INSERT INTO `leave_types` VALUES (1,'Vacation Leave','Paid vacation leave; must be filed at least 3 days before the requested start date',7,1,0,'2026-08-26 06:55:00','2026-08-26 06:55:00'),(2,'Sick Leave','Leave for medical reasons',5,1,0,'2026-08-26 06:55:00','2026-08-26 06:55:00'),(3,'Leave Without Pay','Unpaid leave, only usable once Vacation and Sick leave balances are exhausted',99,0,1,'2026-08-26 06:55:00','2026-08-26 07:25:06'),(4,'Maternity Leave','Leave for maternity (RA 11210); female employees only',105,1,1,'2026-08-26 06:55:00','2026-08-26 06:55:00'),(5,'Paternity Leave','Leave for paternity (RA 8187); male employees only',7,1,1,'2026-08-26 06:55:00','2026-08-26 06:55:00'),(6,'Bereavement Leave','Leave for the death of an immediate family member',3,1,1,'2026-08-26 06:55:00','2026-08-26 06:55:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (10,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-08-27 06:25:48',NULL),(21,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',2,0,'2026-09-02 01:12:20',NULL),(22,1,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',7,0,'2026-09-03 03:29:25',NULL),(25,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-09-03 03:50:56',NULL),(45,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',2,0,'2026-09-08 06:32:31',NULL),(46,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',2,0,'2026-09-08 06:32:31',NULL),(47,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',4,0,'2026-09-08 06:39:12',NULL),(48,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',4,0,'2026-09-08 06:39:14',NULL),(49,4,'New Account Pending Approval','Cyril Christian Gardon has requested account activation.','info','user',6,0,'2026-09-08 06:45:57',NULL),(50,4,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',14,0,'2026-09-08 06:48:54',NULL),(51,2,'New Leave Request','New leave request awaiting HR approval','info','leave_request',14,0,'2026-09-08 06:50:33',NULL),(52,6,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-11 to 2026-09-12. It now awaits HR approval.','info','leave_request',14,0,'2026-09-08 06:50:33',NULL),(53,4,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',15,0,'2026-09-08 06:52:07',NULL),(54,2,'New Leave Request','New leave request awaiting HR approval','info','leave_request',15,0,'2026-09-08 06:55:12',NULL),(55,6,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-08 to 2026-09-08. It now awaits HR approval.','info','leave_request',15,0,'2026-09-08 06:55:12',NULL),(56,6,'Leave Request Approved','Your leave request from 2026-09-08 to 2026-09-08 has been approved.','info','leave_request',15,0,'2026-09-08 06:57:01',NULL),(57,6,'Leave Request Rejected','Your leave request from 2026-09-11 to 2026-09-12 has been rejected.','info','leave_request',14,0,'2026-09-08 06:57:48',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (4,1,'9d644fe40a7335ef22ca54b89e3209a9a15b885070c74e303c1ae4460318816e',2,'203.177.49.42','2026-08-26 07:00:05','2026-08-26 05:52:02'),(26,1,'849b6098df773bd47471547225ab32abc42251b970bcdc7d98b33dff7957dbf4',5,'136.158.103.18','2026-08-26 12:59:36','2026-08-26 11:39:44'),(29,1,'9057d05753845ea9ba4ff8b49e5a729f16cb963f95f6c89b9945d7b7fce5d1ee',2,'209.35.170.100','2026-08-27 01:18:19','2026-08-27 00:03:56'),(91,1,'61c4e4bde3ff5cb3277cb52b75ed524626180c886c8b68df3bfbb57072ecd917',11,'216.247.85.11','2026-10-03 03:51:47','2026-09-03 03:48:46'),(94,1,'e49e33319cee79c94601494bbbe14c41844cc4610cd52e904a800673e50c96f1',9,'216.247.85.11','2026-10-03 03:51:40','2026-09-03 03:51:40'),(156,4,'79cce1913e5854e0909928527a2a9f02db21d70ed47d725b1a10b639efe4bfc1',21,'203.177.49.42','2026-10-08 07:05:32','2026-09-08 06:54:51'),(157,1,'ed1989a2fd10de20675a3ac4ef72aaa333736049c648c14e2674f2cc065ade30',11,'203.177.49.42','2026-10-08 08:40:48','2026-09-08 06:56:19'),(158,2,'171f5ad7ed3fa482fd3c70f4754daee9d9fcc0ef390589b9bbe27353e68b1a6b',25,'175.158.217.57','2026-10-08 06:57:01','2026-09-08 06:56:35'),(159,2,'499cb7beec87e4678a06b44b9a270c988c6c34d2ee6afe9837af4bb9c81893e7',19,'180.193.218.250','2026-10-08 08:40:48','2026-09-08 06:57:26');
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
INSERT INTO `user_id_sequence` VALUES (1,7);
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@thelewiscollege.edu.ph','$2y$10$VYHGcBlY1AY9YAnbwcxG9uj5fjLUT9WwOks2TuBj/hxOtS/APudJy','System Administrator','ADMIN',NULL,'male',NULL,'admin',NULL,7,'active',1,NULL,NULL,1,'2026-08-26 03:32:46','2026-08-27 00:45:08'),(2,'ronnieformento','ronnieformento@thelewiscollege.edu.ph','$2y$10$yMsVzGzX98GzUgUo.iAl2.XaKj174rI3mQVJH01g6sIF1n5nP2TY2','Ronnie Formento','ADMIN','HR Officer','female',1,'hr',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwV0AMUJe8L1U/iKiGiaZ\nHIIWFR2zLYL5yjJ8escGHJnJwIIC4SJJ47I5XoCn3Q4pQNoM5hgbUKCdl1URxUeq\nEM3SX6VV+V+TOgso1W5JjDPoSJBJDP+MdvjSVsJeoqlIyoP79hqZBzFn+N3yYa7A\nxdArIGfexWVgbad4O6QrwU6pMmkK3uSrhV19HkraP7EiE5M/i9Lopu5fUonSvdHl\nZtFgZyYEhW2Wu+UuulnGzUFKH4gRPaWp+QRQvCw2njtBKsZCmH3g3PSv23ZNSNRc\nw5Bf1ZQjiQkEfNFIIeBUzmFB+KjFvUdVI5zbpAkWvx5BGMhRcdJ3Iq+kQRng1BNR\nIEH40mwF8P507zAZBex1j5o0/C5iEqw1dbKrZfB7VOZxXjj5hYK/rfijOmrli48i\nd0EWtD6qOfbNpQtrES+nYHCo0WG1WiIiPJTGOb0MA4o8rpo97gjSL6WUjurfTA1j\nW+13II1HpWlgImIyzle1CkHS6Ss1uK1ttDFG0WEk4Hj4E3ZNw3xIKshxV6c4FFXH\nlALEe+deebAryF8FQ+XVL7Hgep+rnoZ04tlzrgP+SjDmcc12qj9XWjgM2mNv8CHh\n/IWerNNnDMpNffQyGKCOIAS6rTQSYv3gbS4bUGlmkPXyTuYM3eXY0kisZlXUClHh\ngEsi9mKrEY80hDLmv98V0ckCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-08 06:07:08','2026-09-08 06:36:04'),(4,'josefjurendelcastro','josefjurendelcastro@thelewiscollege.edu.ph','$2y$10$RdSeBEMz.KVZRpW7YvxtuOMKG0PRVMjN.3LIMUHGGt5.Q1vd.OoeC','Josef Jurendel Castro','CCS','Dean','male',1,'manager',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvL7jtEh3phd3TtRUCQ1e\nm8ysiUAnMT25LbRsBp5zTj1hYkdQTYVeIDhWn3MLNtU21i6bwMSqDSPnzjwUd/XA\nMuEdvTpsTAFHoZoFDDbNR/zDYusyl6y3gfV/MmbtTsXXgoF70zc4RKR0lxfjATRW\naacjPni6xNK5i27YJwLWUuAlK+GNjuI4DH2+lq+wsZQqnn1CeHOZRcvo355C8Tv4\n+u+c8RLoHn+9eSxoUBcXu7uLnKcxkyzVTjC3GdWvAU9EdmGnIyz9U+H4/ShmC3+B\nus6PraA9j5GkTKgSgltcIVZNYJwaRjtD17bd+s570Svg/VEovbVC6pyYTqNq78KM\n4v/iCTMhkAt+d9oHFYKoUKgkmZKq0RNIaspWikjd11Ce9FwlZWtjG5SmatPli5Qc\nxd6+WB6Mi1wekSU2n2llMqd0VvYZINCTrarrqNYLc4aeZdNI0kqvw1I9nIhrPio6\nXI2tLuabLRm1Nrhce/qNzbC6WZJ61WGU2vpOc8hc2eb14fpRiV7o5ypNAVt5g5g6\nLPin/1+AaoZjohqAZ1Kn1JVqNw5TpPP/pJrMmJaY1pf1SvbQ1OyJ2HOVdnfa/poX\njNAmxDwqr++yWeZHAtvzQGzNy+iN9LWGtjXeepXLPa6HwLpe/zubkFg/hTv7+Gdk\nedV4UKg97coGRZ+BOKUX/FsCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-08 06:30:40','2026-09-08 06:39:39'),(6,'cyrilchristiangardon','cyrilchristiangardon@thelewiscollege.edu.ph','$2y$10$xNsFdqEBY9UcCs8ikI.P2OxWItbv.nyA7Uz4i42yRZhXVFI25nJLO','Cyril Christian Gardon','CCS','Instructor','male',4,'employee',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlzH2u6GnJPrU7jfdc1fv\n2gQHNB6bpSTT7WOSiCFD1WMyLVeiw16Ok30ZT1J9s6cD4uo5RRyOJPZf0eTdjZcT\nYh4hUtz/qWf1KHOnleIpMCAtFrHBaaw/cricNmklDDy0TGdtMTeq5w3Dlik8HJ99\nqIsk9j2meXHWUHwiZPi1F/98P228JfVb4JS5Vht1gQyxa3E8HJHliPMF0l76ZNjG\n6ErJuPVp8cXpFyh5eJcvaEtWG7+RQ659J5DrKgpqHWu/Yv7+2JuNq8aM4BE/bZdB\nOPLLkgk2h/lYdEEBBRfIvqkDXGGSIlRojvEff5vt9xqLR8gNk1DtDmAxTNtVgP4Y\n8pE2dqp+KWwPzGnEgyNLYPO0dyNWtIB55W9jXbyDhzARc/HZjy/oUi0d1XNoZLzw\ntMjW5edK2QcxcC2lVyRnVbCHYg7j1uYaupScyAXUSrpXP53pil430+cKb51IciYR\nY01O5JvmnHfNrwmKOKbMa+JXglFwTq78x7ITUSMlsIbSdYecQX5zeW2x6L4h3jBS\n785F7C1+4bg6OuEKUlR3PFZRvlsuFfw3fD12mg5MzNjNOMOZ5j9mJVZYsN6D+7PP\nAk5cCeD78cHudo2pf/b9pvyMSX4H5gCC/UlQYs/+6xnCx3dKgHDCoLBiV4U/JUCh\nPS0Rpr0e7hRgIFRoR0BKWC0CAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-08 06:40:29','2026-09-08 06:48:20');
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
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_challenges`
--

LOCK TABLES `webauthn_challenges` WRITE;
/*!40000 ALTER TABLE `webauthn_challenges` DISABLE KEYS */;
INSERT INTO `webauthn_challenges` VALUES (24,1,'nOaG8AxHqTmPl5JQ6vsq6Fnbl8HmbAAv5PXRGsRoxKU','approval','device_change',7,'2026-08-27 06:34:27','2026-08-27 06:29:27'),(30,1,'Wt_XMjjKEHtAbwUgwi71oHMLGmVrf_yizu5JGB2u4xI','approval','device_change',9,'2026-08-27 10:07:17','2026-08-27 10:02:17'),(56,1,'bz1aPmo4Qs2MCBX1nZ9jBmiqN7mFnmOwfhE94u3R-BY','approval','device_change',15,'2026-09-03 05:17:35','2026-09-03 05:12:35'),(84,1,'gRDqvlswaewclA50ETWEkTDz1bW3VE9otA2YR0m1IpQ','approval','device_change',19,'2026-09-08 06:58:12','2026-09-08 06:53:12'),(92,2,'ii1TnWQxknv8nHgaEfzMGQNQyxwq-fBHB7B5bq80hQYNrLKXfqTe-n_Rl-gq71zOsuKlRP11Bs4CMhS2K8Jc5Q','approval','leave_request',14,'2026-09-08 07:02:33','2026-09-08 06:57:33'),(93,2,'nL2p3tddQaUAP8aYDxUX5b8Hf4adPUKqe_5m82wUtMkNrLKXfqTe-n_Rl-gq71zOsuKlRP11Bs4CMhS2K8Jc5Q','approval','leave_request',14,'2026-09-08 07:02:39','2026-09-08 06:57:39');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_credentials`
--

LOCK TABLES `webauthn_credentials` WRITE;
/*!40000 ALTER TABLE `webauthn_credentials` DISABLE KEYS */;
INSERT INTO `webauthn_credentials` VALUES (11,1,'Gek3yl-BEN-cOw64S_DBmw','pQECAyYgASFYIA315ZomqJtEDCGqUXPYH5Mf1k0I5uxG5JcFUC8guURhIlggdbFyoX6P9c7avpRo7ayArYGVr9A7prU+HQnt+fE6T9Y=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'laptop','ae0b268077de8046ff0c36bc810656983c652257c17979a8f903b722d0aae064','Chrome • Windows PC','2026-09-07 00:45:20','2026-09-08 06:56:31'),(14,4,'QUaj0NkA8e36VBF7Wceq5w','pQECAyYgASFYIOu8ngztWuHIOj6+Xh+yyQE+LzMDvxgX5EXL6t+fQVrIIlgg8G8AghoSzRAjJHQlCvCjX4DljycPU/q7kZlLuQVvG+U=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'Passkey','6220888a45abdcda8d583a34fc97d2faa3aff57df20af69a955ed4600576df02','Chrome • Android Device','2026-09-08 06:49:44','2026-09-08 06:55:12'),(15,2,'z3A7Rii0Y71unspAo885iO7hLnE','pQECAyYgASFYIKos/fksgTSI9lp4bnjcQAiycGkP5/SGtXxmA7LE/U99IlggwEOW/0/0ZzszGsKwsyV5+KBBkaTeS7a9tIy46oRQo3U=','none',NULL,'fbfc3007-154e-4ecc-8c0b-6e020557d7bd','[]',0,'Passkey','30c190c18197ac61c2be6da06dfec5df73f010d40c364d4a6f28b519372f4e3f','Safari • iPhone','2026-09-08 06:56:46','2026-09-08 06:57:01');
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

-- Dump completed on 2026-09-08  8:41:50
