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
) ENGINE=InnoDB AUTO_INCREMENT=299 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (5,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:02'),(6,1,'update_user','user',2,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 05:52:25'),(10,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 06:08:07'),(22,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:28'),(23,1,'login_failed','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:32'),(24,1,'login_success','user',1,NULL,'[]','203.177.49.42','4fe3a21309fe6cf55dd217a5932009a091c17e050ac8a46fbffac1e3be034f0c','2026-08-26 07:39:37'),(29,1,'login_failed','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:01'),(30,1,'login_success','user',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:09'),(31,1,'device_request_approved','device_change_request',1,NULL,'[]','216.247.84.100','28816a44f29c444c4b258113a631ee0fedacd64b62285bd08481c64a75411879','2026-08-26 07:57:31'),(37,1,'login_success','user',1,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:39:44'),(39,1,'device_request_approved','device_change_request',2,NULL,'[]','136.158.103.18','27ef20cb662fb1fef649d0d970bc278536e54d43b98c3f938f8ac0d01c828eca','2026-08-26 11:42:09'),(45,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:03:56'),(46,1,'device_request_approved','device_change_request',4,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:06'),(47,1,'device_request_approved','device_change_request',3,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:04:09'),(48,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:20:15'),(52,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:35:42'),(57,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:44:43'),(58,1,'password_changed','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:08'),(59,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 00:45:18'),(63,1,'login_success','user',1,NULL,'[]','209.35.170.100','80db1dffbfe23764524d6e2491626a8d6d67df262b486da3779339b737bb68be','2026-08-27 01:56:42'),(70,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:41:18'),(71,1,'webauthn_credential_registered','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:05'),(72,1,'device_request_approved','device_change_request',5,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:42:22'),(76,1,'login_success','user',1,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:44:28'),(78,1,'device_request_approved','device_change_request',6,NULL,'[]','209.35.170.109','3e2c3ada85a83db98d21f6b85055d24b843ab23e257ea72a3e5375c5d0dc7c9e','2026-08-27 03:47:13'),(88,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:01'),(89,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:03'),(90,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:06'),(91,1,'update_user','user',4,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 06:26:16'),(101,1,'login_success','user',1,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:29:10'),(102,1,'device_request_approved','device_change_request',7,NULL,'[]','110.54.141.165','a30d66619d2c2b32597d35629d6d8016a65d5ce412658141354d90ae03405a92','2026-08-27 06:30:17'),(117,1,'login_failed','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:40'),(118,1,'login_success','user',1,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:00:42'),(119,1,'device_request_approved','device_change_request',8,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:01:03'),(123,1,'device_request_approved','device_change_request',9,NULL,'[]','110.54.141.165','053a22a8909be5d8c37a06ccbf0f5141d86c844e11ad39b05ebf4ffe5de7f183','2026-08-27 10:02:38'),(130,1,'login_failed','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:52'),(131,1,'login_success','user',1,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-01 23:58:55'),(132,2,'login_success_google','user',2,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-02 00:01:28'),(133,2,'login_success_google','user',2,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-02 00:03:00'),(134,2,'login_success_google','user',2,NULL,'[]','111.90.199.104','5e3d856c7e1dae491a6d05e123b1bf3b75babbe1f764919879de1e64de6fa8b0','2026-09-02 00:55:24'),(135,2,'login_success_google','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-02 01:11:58'),(136,2,'password_set','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-02 01:12:20'),(137,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-02 01:12:33'),(138,NULL,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 02:44:40'),(139,NULL,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 02:44:44'),(140,NULL,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 02:44:51'),(141,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 02:45:26'),(142,3,'login_success_google','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:01:30'),(143,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:02:14'),(144,3,'password_set','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:05:02'),(145,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:05:13'),(146,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:05:53'),(147,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:06:56'),(148,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:19:50'),(149,NULL,'update_user','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:23:27'),(150,3,'login_success','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:23:57'),(151,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:24:27'),(152,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:24:57'),(153,1,'update_user','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:25:08'),(154,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:28:10'),(155,3,'login_success','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:28:52'),(156,3,'create_leave_request','leave_request',7,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:29:25'),(157,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:30:08'),(158,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:30:33'),(159,NULL,'update_user','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:42:38'),(160,2,'login_success','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:44:16'),(161,2,'webauthn_credential_registered','user',2,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:45:41'),(162,2,'approve_leave_request_supervisor','leave_request',7,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:46:02'),(163,3,'login_failed','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:46:32'),(164,3,'login_success','user',3,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:46:36'),(165,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:21'),(166,1,'approve_leave_request','leave_request',7,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:47:49'),(167,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:48:46'),(168,4,'login_success_google','user',4,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:50:37'),(169,4,'password_set','user',4,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 03:50:56'),(170,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:29'),(171,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:51:40'),(172,1,'update_user','user',4,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:52:21'),(173,2,'device_change_requested','user',2,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:00'),(174,2,'login_failed_untrusted_device','user',2,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:00'),(175,1,'login_success','user',1,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:24'),(176,1,'device_request_approved','device_change_request',11,NULL,'[]','216.247.85.11','52287b1f8219b818f3d9b58c67ed34a74ca7de5185a0c763df4bbe16fa17a86c','2026-09-03 03:53:49'),(177,1,'login_success','user',1,NULL,'[]','216.247.85.11','ca17bafed0caded41410a2e166d914800f63345e49625f64f97b9588e2e4d64c','2026-09-03 04:15:57'),(178,2,'login_success','user',2,NULL,'[]','180.193.218.250','11cc95c0c2a4ee4f202bdba3cfed7615f506dd3b2afa51fff4e3fe4565937b7e','2026-09-03 04:21:05'),(179,2,'webauthn_credential_removed','user',2,NULL,'[]','180.193.218.250','11cc95c0c2a4ee4f202bdba3cfed7615f506dd3b2afa51fff4e3fe4565937b7e','2026-09-03 04:21:17'),(180,2,'webauthn_credential_registered','user',2,NULL,'[]','180.193.218.250','11cc95c0c2a4ee4f202bdba3cfed7615f506dd3b2afa51fff4e3fe4565937b7e','2026-09-03 04:21:57'),(181,4,'device_change_requested','user',4,NULL,'[]','203.177.49.42','915e5ed24d3d9588eb77f7951d802aeec51a3c88b0724763bcd75c1204763d5d','2026-09-03 04:22:45'),(182,4,'login_failed_untrusted_device','user',4,NULL,'[]','203.177.49.42','915e5ed24d3d9588eb77f7951d802aeec51a3c88b0724763bcd75c1204763d5d','2026-09-03 04:22:45'),(183,1,'device_request_approved','device_change_request',12,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:23:00'),(184,4,'login_success','user',4,NULL,'[]','203.177.49.42','915e5ed24d3d9588eb77f7951d802aeec51a3c88b0724763bcd75c1204763d5d','2026-09-03 04:23:04'),(185,4,'webauthn_credential_registered','user',4,NULL,'[]','203.177.49.42','915e5ed24d3d9588eb77f7951d802aeec51a3c88b0724763bcd75c1204763d5d','2026-09-03 04:23:38'),(186,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:24:44'),(187,3,'create_leave_request','leave_request',8,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:25:24'),(188,3,'update_leave_request','leave_request',8,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:25:39'),(189,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 04:28:34'),(190,2,'approve_leave_request_supervisor','leave_request',8,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:30:50'),(191,4,'approve_leave_request','leave_request',8,NULL,'[]','203.177.49.42','915e5ed24d3d9588eb77f7951d802aeec51a3c88b0724763bcd75c1204763d5d','2026-09-03 04:31:32'),(192,2,'device_change_requested','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-03 04:32:13'),(193,2,'login_failed_untrusted_device','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-03 04:32:13'),(194,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:21'),(195,1,'device_request_approved','device_change_request',13,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 04:32:40'),(196,2,'login_success','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-03 04:32:53'),(197,1,'webauthn_credential_removed','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:00'),(198,2,'device_change_requested','user',2,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:22'),(199,2,'login_failed_untrusted_device','user',2,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:22'),(200,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:10:31'),(201,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:16'),(202,1,'device_request_approved','device_change_request',14,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:27'),(203,2,'login_success','user',2,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:41'),(204,2,'webauthn_credential_removed','user',2,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:11:48'),(205,4,'device_change_requested','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:12:16'),(206,4,'login_failed_untrusted_device','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:12:16'),(207,1,'login_success','user',1,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-03 05:12:25'),(208,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:14:20'),(209,1,'device_request_approved','device_change_request',15,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-03 05:15:45'),(210,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:17:42'),(211,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:17:43'),(212,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:17:46'),(213,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:17:55'),(214,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:18:34'),(215,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:18:38'),(216,NULL,'update_user','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:18:44'),(217,NULL,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:13'),(218,NULL,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:25'),(219,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:37'),(220,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:36:54'),(221,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:00'),(222,1,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:03'),(223,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:08'),(224,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:15'),(225,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:37:17'),(226,NULL,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:40:43'),(227,NULL,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:40:46'),(228,NULL,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:40:48'),(229,NULL,'update_user','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:40:51'),(230,NULL,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:40:53'),(231,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:07'),(232,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:16'),(233,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:20'),(234,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:53'),(235,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:41:59'),(236,1,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:01'),(237,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:14'),(238,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:22'),(239,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:26'),(240,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:31'),(241,1,'update_user','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:42:33'),(242,NULL,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:32'),(243,NULL,'update_user','user',4,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:34'),(244,2,'device_change_requested','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:50'),(245,2,'login_failed_untrusted_device','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:50'),(246,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 00:44:55'),(247,1,'webauthn_credential_registered','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:20'),(248,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:31'),(249,1,'device_request_approved','device_change_request',16,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:41'),(250,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:55'),(251,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:45:58'),(252,3,'login_failed','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:46:23'),(253,3,'login_failed','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:46:24'),(254,3,'login_failed','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:46:32'),(255,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:46:36'),(256,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:53:02'),(257,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:53:05'),(258,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:53:39'),(259,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:53:58'),(260,2,'create_leave_request','leave_request',9,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:54:18'),(261,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:54:52'),(262,3,'create_leave_request','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:55:24'),(263,4,'device_change_requested','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:55:57'),(264,4,'login_failed_untrusted_device','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:55:57'),(265,1,'login_success','user',1,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:01'),(266,1,'device_request_approved','device_change_request',17,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:20'),(267,1,'approve_leave_request_supervisor','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:31'),(268,1,'approve_leave_request','leave_request',9,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:56:42'),(269,1,'reject_leave_request','leave_request',10,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:57:00'),(270,4,'login_success','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:57:10'),(271,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:58:04'),(272,2,'create_leave_request','leave_request',11,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:59:44'),(273,4,'login_success','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 00:59:55'),(274,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:00:17'),(275,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:07:40'),(276,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:07:42'),(277,4,'login_success','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:08:14'),(278,4,'login_success','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-07 01:09:28'),(279,4,'webauthn_credential_registered','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-07 01:09:51'),(280,4,'webauthn_approval_device_mismatch','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:10:24'),(281,4,'webauthn_approval_device_mismatch','user',4,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:10:54'),(282,4,'login_success','user',4,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-07 01:11:03'),(283,4,'approve_leave_request','leave_request',11,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-07 01:11:16'),(284,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:11:39'),(285,2,'device_change_requested','user',2,NULL,'[]','180.193.218.250','9c78eb57befc179164846f153ccc9a6e69685eed595db70a6515d1abe6f0a15a','2026-09-07 01:13:39'),(286,1,'login_success','user',1,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:13:58'),(287,1,'device_request_approved','device_change_request',18,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:14:10'),(288,2,'login_success','user',2,NULL,'[]','203.177.49.42','5d15922b269a6497b5477a7954254a121bf6fca534990e4eab97a69042188112','2026-09-07 01:16:04'),(289,2,'webauthn_credential_registered','user',2,NULL,'[]','203.177.49.42','5d15922b269a6497b5477a7954254a121bf6fca534990e4eab97a69042188112','2026-09-07 01:16:25'),(290,3,'login_success','user',3,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:16:45'),(291,3,'create_leave_request','leave_request',12,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:17:04'),(292,2,'login_success','user',2,NULL,'[]','203.177.49.42','b7b372091415ea717dbe22b2472f2a612371c1804bd42a3fb6972cb2810b9e10','2026-09-07 01:17:31'),(293,2,'webauthn_approval_device_mismatch','user',2,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:18:39'),(294,2,'approve_leave_request_supervisor','leave_request',12,NULL,'[]','203.177.49.42','5d15922b269a6497b5477a7954254a121bf6fca534990e4eab97a69042188112','2026-09-07 01:19:20'),(295,4,'approve_leave_request','leave_request',12,NULL,'[]','203.177.49.42','77a49251f00936f1820d1bffac7f97ac392e09f749ca9bd43706d7240a6a56dd','2026-09-07 01:19:43'),(296,3,'login_success','user',3,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:24:34'),(297,3,'create_leave_request','leave_request',13,NULL,'[]','180.193.218.250','7758d40c9cd09735e93827135d4a07a4aba0742014f448625b231b7af4d91e76','2026-09-07 01:25:01'),(298,2,'approve_leave_request_supervisor','leave_request',13,NULL,'[]','203.177.49.42','5d15922b269a6497b5477a7954254a121bf6fca534990e4eab97a69042188112','2026-09-07 01:25:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_change_requests`
--

LOCK TABLES `device_change_requests` WRITE;
/*!40000 ALTER TABLE `device_change_requests` DISABLE KEYS */;
INSERT INTO `device_change_requests` VALUES (11,2,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/151.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"216.247.85.11\",\"browser\":\"Chrome 151\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','216.247.85.11','Chrome 151','approved','2026-09-03 03:53:00','2026-09-03 03:53:49',1),(12,4,'18b29f2812d02213e2414e8a5dac6cae21a878fc75078aeaed76c3643171e04e','{\"user_agent\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) CriOS\\/151.0.7922.112 Mobile\\/15E148 Safari\\/604.1\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Safari 604\",\"os\":\"iOS 26.5.0\",\"device\":\"iPhone\",\"screen_resolution\":\"414x720\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"iPhone\",\"hardware_concurrency\":4,\"device_memory\":\"unknown\"}','203.177.49.42','Safari 604','approved','2026-09-03 04:22:45','2026-09-03 04:23:00',1),(13,2,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"180.193.218.250\",\"browser\":\"Chrome 152\",\"os\":\"Windows 10\",\"device\":\"Windows PC\",\"screen_resolution\":\"1536x730\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Win32\",\"hardware_concurrency\":12,\"device_memory\":16}','180.193.218.250','Chrome 152','approved','2026-09-03 04:32:13','2026-09-03 04:32:39',1),(14,2,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/151.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Chrome 151\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','203.177.49.42','Chrome 151','approved','2026-09-03 05:10:22','2026-09-03 05:11:27',1),(15,4,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"user_agent\":\"Mozilla\\/5.0 (Linux; Android 10; K) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/151.0.0.0 Mobile Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Chrome 151\",\"os\":\"Android 10\",\"device\":\"Android Device\",\"screen_resolution\":\"411x786\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Linux armv81\",\"hardware_concurrency\":8,\"device_memory\":4}','203.177.49.42','Chrome 151','approved','2026-09-03 05:12:16','2026-09-03 05:15:45',1),(16,2,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"180.193.218.250\",\"browser\":\"Chrome 152\",\"os\":\"Windows 10\",\"device\":\"Windows PC\",\"screen_resolution\":\"1536x730\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Win32\",\"hardware_concurrency\":12,\"device_memory\":16}','180.193.218.250','Chrome 152','approved','2026-09-07 00:44:50','2026-09-07 00:45:41',1),(17,4,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/152.0.0.0 Safari\\/537.36\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"203.177.49.42\",\"browser\":\"Chrome 152\",\"os\":\"Windows 10\",\"device\":\"Windows PC\",\"screen_resolution\":\"1536x730\",\"timezone\":\"Asia\\/Manila\",\"language\":\"en-US\",\"platform\":\"Win32\",\"hardware_concurrency\":12,\"device_memory\":16}','203.177.49.42','Chrome 152','approved','2026-09-07 00:55:57','2026-09-07 00:56:20',1),(18,2,'e44a38aebe8bea57ff7f26d2a63aec715d43b6e6a4d61828e67cca151f060db4','{\"user_agent\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) CriOS\\/152.0.7977.64 Mobile\\/15E148 Safari\\/604.1\",\"accept_language\":\"en-US,en;q=0.9\",\"accept_encoding\":\"gzip, deflate, br, zstd\",\"ip_address\":\"180.193.218.250\",\"browser\":\"Safari 604\",\"os\":\"iOS 26.5.0\",\"device\":\"iPhone\",\"screen_resolution\":\"unknown\",\"timezone\":\"UTC\",\"language\":\"\",\"platform\":\"\",\"hardware_concurrency\":\"unknown\",\"device_memory\":\"unknown\"}','180.193.218.250','Safari 604','approved','2026-09-07 01:13:39','2026-09-07 01:14:10',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_fingerprints`
--

LOCK TABLES `device_fingerprints` WRITE;
/*!40000 ALTER TABLE `device_fingerprints` DISABLE KEYS */;
INSERT INTO `device_fingerprints` VALUES (2,1,'0c82c8f821f00d8940a23e7b440b36ea2ae0f9fed0b06894671b3291fb3b78fa','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"110.54.141.165\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','110.54.141.165','Chrome 151',1,'2026-08-27 10:00:42','2026-08-26 05:52:02','2026-08-27 10:00:42'),(5,1,'25befb4fd7a4be2871b71dbdc19479a6559a154a7f7fcd620b393dd464e14999','{\"os\": \"macOS 10.15.7\", \"device\": \"Mac\", \"browser\": \"Chrome 150\", \"language\": \"en-US\", \"platform\": \"MacIntel\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"136.158.103.18\", \"user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36\", \"device_memory\": 8, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1470x835\", \"hardware_concurrency\": 8}','136.158.103.18','Chrome 150',1,'2026-08-26 11:39:44','2026-08-26 11:39:44','2026-08-26 11:39:44'),(9,1,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','203.177.49.42','Chrome 151',1,'2026-09-03 05:12:25','2026-08-27 06:29:10','2026-09-03 05:12:25'),(11,1,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"180.193.218.250\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','180.193.218.250','Chrome 152',1,'2026-09-07 01:13:58','2026-09-01 23:58:55','2026-09-07 01:13:58'),(12,2,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 152',1,'2026-09-07 01:17:31','2026-09-02 00:01:28','2026-09-07 01:17:31'),(13,3,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"180.193.218.250\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','180.193.218.250','Chrome 152',1,'2026-09-07 01:24:34','2026-09-03 03:01:30','2026-09-07 01:24:34'),(14,4,'609a9deb05528e7dea36d41f1da1859ea0f71a03e48661668376bdbb36e4c72a','{\"os\": \"Windows 10\", \"device\": \"Windows PC\", \"browser\": \"Chrome 152\", \"language\": \"en-US\", \"platform\": \"Win32\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36\", \"device_memory\": 16, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"1536x730\", \"hardware_concurrency\": 12}','203.177.49.42','Chrome 152',1,'2026-09-07 01:08:14','2026-09-03 03:50:37','2026-09-07 01:08:14'),(15,2,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','203.177.49.42','Chrome 151',1,'2026-09-03 05:11:41','2026-09-03 03:53:49','2026-09-03 05:11:41'),(16,4,'18b29f2812d02213e2414e8a5dac6cae21a878fc75078aeaed76c3643171e04e','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/151.0.7922.112 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x720\", \"hardware_concurrency\": 4}','203.177.49.42','Safari 604',0,'2026-09-03 04:23:04','2026-09-03 04:23:00','2026-09-03 05:15:45'),(17,4,'d54a2ef9a64c7bb38e3c6653bbfb832e29c9a95c524c0abfc3c6c39d1769852b','{\"os\": \"Android 10\", \"device\": \"Android Device\", \"browser\": \"Chrome 151\", \"language\": \"en-US\", \"platform\": \"Linux armv81\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36\", \"device_memory\": 4, \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"411x786\", \"hardware_concurrency\": 8}','203.177.49.42','Chrome 151',1,'2026-09-07 01:11:03','2026-09-03 05:15:45','2026-09-07 01:11:03'),(18,2,'e44a38aebe8bea57ff7f26d2a63aec715d43b6e6a4d61828e67cca151f060db4','{\"os\": \"iOS 26.5.0\", \"device\": \"iPhone\", \"browser\": \"Safari 604\", \"language\": \"en-US\", \"platform\": \"iPhone\", \"timezone\": \"Asia/Manila\", \"ip_address\": \"203.177.49.42\", \"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 26_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/152.0.7977.64 Mobile/15E148 Safari/604.1\", \"device_memory\": \"unknown\", \"accept_encoding\": \"gzip, deflate, br, zstd\", \"accept_language\": \"en-US,en;q=0.9\", \"screen_resolution\": \"414x720\", \"hardware_concurrency\": 4}','203.177.49.42','Safari 604',1,'2026-09-07 01:16:04','2026-09-07 01:14:10','2026-09-07 01:16:04');
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_signatures`
--

LOCK TABLES `digital_signatures` WRITE;
/*!40000 ALTER TABLE `digital_signatures` DISABLE KEYS */;
INSERT INTO `digital_signatures` VALUES (10,7,'leave_request',2,'MEUCICM4EGRy1wHoOvZ26-EkRhCbSMNB4XeLZNArn-8cspx8AiEAot2ifNAAdi54gauxYLvTmeGwZxfwnVjksQ6jM-65QTE','{\"type\":\"webauthn\",\"signature\":\"MEUCICM4EGRy1wHoOvZ26-EkRhCbSMNB4XeLZNArn-8cspx8AiEAot2ifNAAdi54gauxYLvTmeGwZxfwnVjksQ6jM-65QTE\",\"credential_id\":\"64Jvm2enyeQehWGtlWKlNw\",\"assertion\":{\"id\":\"64Jvm2enyeQehWGtlWKlNw\",\"rawId\":\"64Jvm2enyeQehWGtlWKlNw\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiZmtWN2ZyOVY1aDcwcXRtY3FURzdjemhsNGNyYm4ya3hYblhSS3h5VndoZ2h5N0VQOFk0dXVOZWlmLXpEU3MxVWNCcTU1WnBTRmNQZU9CQlVENnZoV0EiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCICM4EGRy1wHoOvZ26-EkRhCbSMNB4XeLZNArn-8cspx8AiEAot2ifNAAdi54gauxYLvTmeGwZxfwnVjksQ6jM-65QTE\",\"userHandle\":\"Mg\"}},\"challenge\":\"fkV7fr9V5h70qtmcqTG7czhl4crbn2kxXnXRKxyVwhghy7EP8Y4uuNeif-zDSs1UcBq55ZpSFcPeOBBUD6vhWA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIF92g0nCapUY3nQX79Ny7YYMvgQIJrHF3c74aDjlXqT0Ilgg487CMoTk1HuEmqBwEeXZDuEMBxz45e9wr+O9bnTUORw=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"21cbb10ff18e2eb8d7a27fecc34acd54701ab9e59a5215c3de3810540fabe158\"}','2026-09-03 03:46:02',1,'2026-09-03 03:46:02'),(11,7,'leave_request',1,'MEUCIFtxnYecLBwU7-z2XOdxHm4oGgtYEWMdVVqrdW_OtKmNAiEAzayF6YDva3GIDVRXL2L9WH1NXG6n1HBcwwNqKlyke-Q','{\"type\":\"webauthn\",\"signature\":\"MEUCIFtxnYecLBwU7-z2XOdxHm4oGgtYEWMdVVqrdW_OtKmNAiEAzayF6YDva3GIDVRXL2L9WH1NXG6n1HBcwwNqKlyke-Q\",\"credential_id\":\"IUypUhusbQ3uA2VZfGuwpw\",\"assertion\":{\"id\":\"IUypUhusbQ3uA2VZfGuwpw\",\"rawId\":\"IUypUhusbQ3uA2VZfGuwpw\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiWHZnSW1wc3lnUXZIdHA4cFJvX1F1WmpXVjk0ZmpHcGluNmJJblFfTGdUSWh5N0VQOFk0dXVOZWlmLXpEU3MxVWNCcTU1WnBTRmNQZU9CQlVENnZoV0EiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIFtxnYecLBwU7-z2XOdxHm4oGgtYEWMdVVqrdW_OtKmNAiEAzayF6YDva3GIDVRXL2L9WH1NXG6n1HBcwwNqKlyke-Q\",\"userHandle\":\"MQ\"}},\"challenge\":\"XvgImpsygQvHtp8pRo_QuZjWV94fjGpin6bInQ_LgTIhy7EP8Y4uuNeif-zDSs1UcBq55ZpSFcPeOBBUD6vhWA\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":1,\"credential\":{\"public_key\":\"pQECAyYgASFYIFbia5QbnmIhRGHFTeg+y8hkPzw935hXPJXg3C1aNmMlIlggAJlVNHZcvjXId9Nl20oJB6A2D5ruj0GEA\\/czPHuMv4A=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"21cbb10ff18e2eb8d7a27fecc34acd54701ab9e59a5215c3de3810540fabe158\"}','2026-09-03 03:47:49',1,'2026-09-03 03:47:49'),(12,8,'leave_request',2,'MEQCIE9h7d65XC9QxEuFVNEMXXQ3LceRwNCrGLYiOuIeKIDWAiBhgrY8nxKUmbRiszoqhexoth0R9Wo5U_qFmtTOOYpsPA','{\"type\":\"webauthn\",\"signature\":\"MEQCIE9h7d65XC9QxEuFVNEMXXQ3LceRwNCrGLYiOuIeKIDWAiBhgrY8nxKUmbRiszoqhexoth0R9Wo5U_qFmtTOOYpsPA\",\"credential_id\":\"bQsI1wfF2XWwCKN05GuZkg\",\"assertion\":{\"id\":\"bQsI1wfF2XWwCKN05GuZkg\",\"rawId\":\"bQsI1wfF2XWwCKN05GuZkg\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiZzdaT3J4WWh2QVQ4Y0hoOGcwQjR2WjRlY2w3VF9SSmF0VGhHV1pDa2c4SXNVbl9MX3FDbTlqbEw3RS1hZ0tmaUMwb3RKaXZUVVJGR2ZrZkwtQ2h5cWciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEQCIE9h7d65XC9QxEuFVNEMXXQ3LceRwNCrGLYiOuIeKIDWAiBhgrY8nxKUmbRiszoqhexoth0R9Wo5U_qFmtTOOYpsPA\",\"userHandle\":\"Mg\"}},\"challenge\":\"g7ZOrxYhvAT8cHh8g0B4vZ4ecl7T_RJatThGWZCkg8IsUn_L_qCm9jlL7E-agKfiC0otJivTURFGfkfL-Chyqg\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYIKPG1wyEDV49ILUVZcyvRJsfjereHm09+u\\/6jBxFNEATIlggIeBx0NrGd7XBAhlsxfJ8jaIsHiq+uQQhK2W3fsaCdnE=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"2c527fcbfea0a6f6394bec4f9a80a7e20b4a2d262bd35111467e47cbf82872aa\"}','2026-09-03 04:30:50',1,'2026-09-03 04:30:50'),(13,8,'leave_request',4,'MEQCIAerhdZZTi3qXBZG-9kvEAnxYnDNE5QSgv8KB-4R55QvAiA-3y6dfaYATGG5JIzAWPHfl7FdNJQdtvcfIc8loeusng','{\"type\":\"webauthn\",\"signature\":\"MEQCIAerhdZZTi3qXBZG-9kvEAnxYnDNE5QSgv8KB-4R55QvAiA-3y6dfaYATGG5JIzAWPHfl7FdNJQdtvcfIc8loeusng\",\"credential_id\":\"1qI_Px26QlfU0YH4l_Wa5_zu_Es\",\"assertion\":{\"id\":\"1qI_Px26QlfU0YH4l_Wa5_zu_Es\",\"rawId\":\"1qI_Px26QlfU0YH4l_Wa5_zu_Es\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiVk5TRURXZmFPdk1qbXlveUNVaXA1a3c5WFlTUWZrQzM3LWdhSVNsOWtpNHNVbl9MX3FDbTlqbEw3RS1hZ0tmaUMwb3RKaXZUVVJGR2ZrZkwtQ2h5cWciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEQCIAerhdZZTi3qXBZG-9kvEAnxYnDNE5QSgv8KB-4R55QvAiA-3y6dfaYATGG5JIzAWPHfl7FdNJQdtvcfIc8loeusng\",\"userHandle\":\"NA\"}},\"challenge\":\"VNSEDWfaOvMjmyoyCUip5kw9XYSQfkC37-gaISl9ki4sUn_L_qCm9jlL7E-agKfiC0otJivTURFGfkfL-Chyqg\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIF+lz0s49Ef9eiWKt8tD8ZaYvspLSgx6A+xT6Zbg1gyLIlgggQgQGP5SoUDyktxJfZGZzn7NZAI6zbx37gvd67zq0is=\",\"attestation_type\":\"none\",\"aaguid\":\"fbfc3007-154e-4ecc-8c0b-6e020557d7bd\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"2c527fcbfea0a6f6394bec4f9a80a7e20b4a2d262bd35111467e47cbf82872aa\"}','2026-09-03 04:31:32',1,'2026-09-03 04:31:32'),(14,10,'leave_request',1,'MEUCIAxD0iPe8b2vSNWi1_mMeWJAunItridUUPWjK02jDSFVAiEA_pZbhMTVTXMwYKUAwtBdXPIxVoISwCwYLpRY5rnmHv4','{\"type\":\"webauthn\",\"signature\":\"MEUCIAxD0iPe8b2vSNWi1_mMeWJAunItridUUPWjK02jDSFVAiEA_pZbhMTVTXMwYKUAwtBdXPIxVoISwCwYLpRY5rnmHv4\",\"credential_id\":\"Gek3yl-BEN-cOw64S_DBmw\",\"assertion\":{\"id\":\"Gek3yl-BEN-cOw64S_DBmw\",\"rawId\":\"Gek3yl-BEN-cOw64S_DBmw\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiNHpuTC1KQTc0TkczZFN1dURiUkUwVWhIU0tzZWh1QVNudTNfZnFraUhOQzRPX05SQ1k1ZDkyOVhJTFc4YnRkN0c4VWZHaEM4VWRET0FQX0E2eHRZdmciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIAxD0iPe8b2vSNWi1_mMeWJAunItridUUPWjK02jDSFVAiEA_pZbhMTVTXMwYKUAwtBdXPIxVoISwCwYLpRY5rnmHv4\",\"userHandle\":\"MQ\"}},\"challenge\":\"4znL-JA74NG3dSuuDbRE0UhHSKsehuASnu3_fqkiHNC4O_NRCY5d929XILW8btd7G8UfGhC8UdDOAP_A6xtYvg\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":1,\"credential\":{\"public_key\":\"pQECAyYgASFYIA315ZomqJtEDCGqUXPYH5Mf1k0I5uxG5JcFUC8guURhIlggdbFyoX6P9c7avpRo7ayArYGVr9A7prU+HQnt+fE6T9Y=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"b83bf351098e5df76f5720b5bc6ed77b1bc51f1a10bc51d0ce00ffc0eb1b58be\"}','2026-09-07 00:56:31',1,'2026-09-07 00:56:31'),(15,9,'leave_request',1,'MEYCIQDUVgyjNlpWHHWKh6wj_FI-TexVLgk9nDFtPr_Z5X7EOwIhAIVE8MRalq3F--EE8VwEEbC-W5jyvuE-agIBnTk091aU','{\"type\":\"webauthn\",\"signature\":\"MEYCIQDUVgyjNlpWHHWKh6wj_FI-TexVLgk9nDFtPr_Z5X7EOwIhAIVE8MRalq3F--EE8VwEEbC-W5jyvuE-agIBnTk091aU\",\"credential_id\":\"Gek3yl-BEN-cOw64S_DBmw\",\"assertion\":{\"id\":\"Gek3yl-BEN-cOw64S_DBmw\",\"rawId\":\"Gek3yl-BEN-cOw64S_DBmw\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiZU8yR1FtZXJjVW1pSzFkVzBIWnlEZXlHblFhaGNVVWtSc3R5TzFnbHhxeVdCYUwzbWZjLUlySDR3VnEwbEhGMlFsOG9uYmNzQ3Z6VEx0Nk93cHlKWFEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEYCIQDUVgyjNlpWHHWKh6wj_FI-TexVLgk9nDFtPr_Z5X7EOwIhAIVE8MRalq3F--EE8VwEEbC-W5jyvuE-agIBnTk091aU\",\"userHandle\":\"MQ\"}},\"challenge\":\"eO2GQmercUmiK1dW0HZyDeyGnQahcUUkRstyO1glxqyWBaL3mfc-IrH4wVq0lHF2Ql8onbcsCvzTLt6OwpyJXQ\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":1,\"credential\":{\"public_key\":\"pQECAyYgASFYIA315ZomqJtEDCGqUXPYH5Mf1k0I5uxG5JcFUC8guURhIlggdbFyoX6P9c7avpRo7ayArYGVr9A7prU+HQnt+fE6T9Y=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"9605a2f799f73e22b1f8c15ab4947176425f289db72c0afcd32ede8ec29c895d\"}','2026-09-07 00:56:42',1,'2026-09-07 00:56:42'),(16,11,'leave_request',4,'MEYCIQDiLqipyboJWmQk28ym2q91lSS2uVSg9LlcxV1thKFfiAIhALEWPV7g_3VnyiS8R_XUoa6Zi-VvS_HPqNWo18bd1xtr','{\"type\":\"webauthn\",\"signature\":\"MEYCIQDiLqipyboJWmQk28ym2q91lSS2uVSg9LlcxV1thKFfiAIhALEWPV7g_3VnyiS8R_XUoa6Zi-VvS_HPqNWo18bd1xtr\",\"credential_id\":\"LPmImDSFpvr9lFWNfaxizQ\",\"assertion\":{\"id\":\"LPmImDSFpvr9lFWNfaxizQ\",\"rawId\":\"LPmImDSFpvr9lFWNfaxizQ\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiaVl3VnFaTUtSMmZVaHg4NEJac3Fnb1d6bW1tcU5EV05Ic2FHNU0wOUlUckVJcHlkenAybGt1MkszeF9iM1pkYVN6S0lrazNRUlVTTjhsNjVXUW53dXciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZSwib3RoZXJfa2V5c19jYW5fYmVfYWRkZWRfaGVyZSI6ImRvIG5vdCBjb21wYXJlIGNsaWVudERhdGFKU09OIGFnYWluc3QgYSB0ZW1wbGF0ZS4gU2VlIGh0dHBzOi8vZ29vLmdsL3lhYlBleCJ9\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEYCIQDiLqipyboJWmQk28ym2q91lSS2uVSg9LlcxV1thKFfiAIhALEWPV7g_3VnyiS8R_XUoa6Zi-VvS_HPqNWo18bd1xtr\",\"userHandle\":\"NA\"}},\"challenge\":\"iYwVqZMKR2fUhx84BZsqgoWzmmmqNDWNHsaG5M09ITrEIpydzp2lku2K3x_b3ZdaSzKIkk3QRUSN8l65WQnwuw\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIJYoF\\/6ervuuDjrA9y3cI++WaLYlp01P0sHMb7qQn8maIlgg6OpWxJ2Xd5JKKYAbNL7IewjVl\\/MXa5PWbm7npf+OR2k=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"c4229c9dce9da592ed8adf1fdbdd975a4b3288924dd045448df25eb95909f0bb\"}','2026-09-07 01:11:16',1,'2026-09-07 01:11:16'),(17,12,'leave_request',2,'MEUCIEwFSeBQwz-hnGpigpPd_28b2qXKgRoRtR2pYLH2UntlAiEAhHL89l-53hMCyZms_-j2R0A8le4kZwEpXVhyFqp4psc','{\"type\":\"webauthn\",\"signature\":\"MEUCIEwFSeBQwz-hnGpigpPd_28b2qXKgRoRtR2pYLH2UntlAiEAhHL89l-53hMCyZms_-j2R0A8le4kZwEpXVhyFqp4psc\",\"credential_id\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"assertion\":{\"id\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"rawId\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiZ0ZYX3ZQUEZ2QWJGTWV5bHpWS0hDekVlc3hENWd3cXdnREVMMjByUXF0TG1GNUlqNDNuenFKcHpGQnZuVkpmWWVmOFNPOURrN1A5VzF0cTVaOTVuQXciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIEwFSeBQwz-hnGpigpPd_28b2qXKgRoRtR2pYLH2UntlAiEAhHL89l-53hMCyZms_-j2R0A8le4kZwEpXVhyFqp4psc\",\"userHandle\":\"Mg\"}},\"challenge\":\"gFX_vPPFvAbFMeylzVKHCzEesxD5gwqwgDEL20rQqtLmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYINHYR34mSprZM+cJGQU6pvMk\\/oetrRu46dJ0Ld3jCzYoIlgg7kA\\/iRjdt4IIok5uN+jTWLeL8FkHhq6ikv5GpkGC8PE=\",\"attestation_type\":\"none\",\"aaguid\":\"fbfc3007-154e-4ecc-8c0b-6e020557d7bd\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"e6179223e379f3a89a73141be75497d879ff123bd0e4ecff56d6dab967de6703\"}','2026-09-07 01:19:20',1,'2026-09-07 01:19:20'),(18,12,'leave_request',4,'MEUCIQDB6i54IUAgxrLcjrMNJs3JR_OtZGSCkBoYJg7OMEeybgIgcx2sOaqM3vouJonx5UTL0XGdUdNU08ejRKDg85CvlRc','{\"type\":\"webauthn\",\"signature\":\"MEUCIQDB6i54IUAgxrLcjrMNJs3JR_OtZGSCkBoYJg7OMEeybgIgcx2sOaqM3vouJonx5UTL0XGdUdNU08ejRKDg85CvlRc\",\"credential_id\":\"LPmImDSFpvr9lFWNfaxizQ\",\"assertion\":{\"id\":\"LPmImDSFpvr9lFWNfaxizQ\",\"rawId\":\"LPmImDSFpvr9lFWNfaxizQ\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiSENTU2JUNDBZaXVrdmd3MkkzUWlnRS1vZUdTaUlVTmJpNjJWZ1Z1STdMVG1GNUlqNDNuenFKcHpGQnZuVkpmWWVmOFNPOURrN1A5VzF0cTVaOTVuQXciLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIQDB6i54IUAgxrLcjrMNJs3JR_OtZGSCkBoYJg7OMEeybgIgcx2sOaqM3vouJonx5UTL0XGdUdNU08ejRKDg85CvlRc\",\"userHandle\":\"NA\"}},\"challenge\":\"HCSSbT40Yiukvgw2I3QigE-oeGSiIUNbi62VgVuI7LTmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":4,\"credential\":{\"public_key\":\"pQECAyYgASFYIJYoF\\/6ervuuDjrA9y3cI++WaLYlp01P0sHMb7qQn8maIlgg6OpWxJ2Xd5JKKYAbNL7IewjVl\\/MXa5PWbm7npf+OR2k=\",\"attestation_type\":\"none\",\"aaguid\":\"ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"e6179223e379f3a89a73141be75497d879ff123bd0e4ecff56d6dab967de6703\"}','2026-09-07 01:19:43',1,'2026-09-07 01:19:43'),(19,13,'leave_request',2,'MEUCIHO3XsqJiwAysiIqrI06_RjiXs4WYaWRR01KSDae3MweAiEAy4aFhOZByCEwjuzW1OP8LPiCq5RVN-hE3lIVXafclb4','{\"type\":\"webauthn\",\"signature\":\"MEUCIHO3XsqJiwAysiIqrI06_RjiXs4WYaWRR01KSDae3MweAiEAy4aFhOZByCEwjuzW1OP8LPiCq5RVN-hE3lIVXafclb4\",\"credential_id\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"assertion\":{\"id\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"rawId\":\"UnXj8rbbeNH8_mTA9jW3UA1c_08\",\"type\":\"public-key\",\"response\":{\"clientDataJSON\":\"eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiWWlaQXotelJ3RmNseXNnMTVKU1JNMkxDZzhaSDR0MExxeWR3Wkh4bXpsYTRRT1lRNENRSDROWWZET09UeW9GN2ZsUi12SG9rdzVlTDAtdHpLajh3elEiLCJvcmlnaW4iOiJodHRwczovL2xlYXZlc3luYy51cC5yYWlsd2F5LmFwcCIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"authenticatorData\":\"2vrbCgXRBD6a5rABUTMZKgxFgBUWftjehTwSCmCBGkgdAAAAAA\",\"signature\":\"MEUCIHO3XsqJiwAysiIqrI06_RjiXs4WYaWRR01KSDae3MweAiEAy4aFhOZByCEwjuzW1OP8LPiCq5RVN-hE3lIVXafclb4\",\"userHandle\":\"Mg\"}},\"challenge\":\"YiZAz-zRwFclysg15JSRM2LCg8ZH4t0LqydwZHxmzla4QOYQ4CQH4NYfDOOTyoF7flR-vHokw5eL0-tzKj8wzQ\",\"rp_id\":\"leavesync.up.railway.app\",\"origin\":\"https:\\/\\/leavesync.up.railway.app\",\"user_id\":2,\"credential\":{\"public_key\":\"pQECAyYgASFYINHYR34mSprZM+cJGQU6pvMk\\/oetrRu46dJ0Ld3jCzYoIlgg7kA\\/iRjdt4IIok5uN+jTWLeL8FkHhq6ikv5GpkGC8PE=\",\"attestation_type\":\"none\",\"aaguid\":\"fbfc3007-154e-4ecc-8c0b-6e020557d7bd\",\"transports\":[],\"sign_count\":0},\"document_hash\":\"b840e610e02407e0d61f0ce393ca817b7e547ebc7a24c3978bd3eb732a3f30cd\"}','2026-09-07 01:25:24',1,'2026-09-07 01:25:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` VALUES (1,1,1,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(2,1,2,5.00,0.00,0.00,5.00,2026,'2026-08-26 07:19:28','2026-08-26 07:19:28'),(15,1,3,99.00,0.00,0.00,99.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(16,1,4,105.00,0.00,0.00,105.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(17,1,5,7.00,0.00,0.00,7.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(18,1,6,3.00,0.00,0.00,3.00,2026,'2026-08-26 07:27:40','2026-08-26 07:27:40'),(25,2,1,7.00,2.00,0.00,5.00,2026,'2026-09-02 00:01:28','2026-09-07 01:11:16'),(26,2,2,5.00,0.00,0.00,5.00,2026,'2026-09-02 00:01:28','2026-09-02 00:01:28'),(27,2,3,99.00,0.00,0.00,99.00,2026,'2026-09-02 00:01:28','2026-09-02 00:01:28'),(28,2,4,105.00,0.00,0.00,105.00,2026,'2026-09-02 00:01:28','2026-09-02 00:01:28'),(29,2,5,7.00,0.00,0.00,7.00,2026,'2026-09-02 00:01:28','2026-09-02 00:01:28'),(30,2,6,3.00,0.00,0.00,3.00,2026,'2026-09-02 00:01:28','2026-09-02 00:01:28'),(31,3,1,7.00,4.00,1.00,4.00,2026,'2026-09-03 03:01:30','2026-09-07 01:25:01'),(32,3,2,5.00,0.00,0.00,5.00,2026,'2026-09-03 03:01:30','2026-09-03 03:01:30'),(33,3,3,99.00,0.00,0.00,99.00,2026,'2026-09-03 03:01:30','2026-09-03 03:01:30'),(34,3,4,105.00,0.00,0.00,105.00,2026,'2026-09-03 03:01:30','2026-09-03 03:01:30'),(35,3,5,7.00,0.00,0.00,7.00,2026,'2026-09-03 03:01:30','2026-09-03 03:01:30'),(36,3,6,3.00,0.00,0.00,3.00,2026,'2026-09-03 03:01:30','2026-09-03 03:01:30'),(37,4,1,7.00,0.00,0.00,7.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37'),(38,4,2,5.00,0.00,0.00,5.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37'),(39,4,3,99.00,0.00,0.00,99.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37'),(40,4,4,105.00,0.00,0.00,105.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37'),(41,4,5,7.00,0.00,0.00,7.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37'),(42,4,6,3.00,0.00,0.00,3.00,2026,'2026-09-03 03:50:37','2026-09-03 03:50:37');
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (7,3,1,'2026-09-07','2026-09-07',1.00,'test','approved','approved','approved','pending_supervisor',2,'test',1,'test','MEUCIFtxnYecLBwU7-z2XOdxHm4oGgtYEWMdVVqrdW_OtKmNAiEAzayF6YDva3GIDVRXL2L9WH1NXG6n1HBcwwNqKlyke-Q','2026-09-03 03:47:49','2026-09-03 03:29:25','2026-09-03 03:47:49'),(8,3,1,'2026-09-07','2026-09-07',1.00,'test','approved','approved','approved','pending_supervisor',2,'test',4,'','MEQCIAerhdZZTi3qXBZG-9kvEAnxYnDNE5QSgv8KB-4R55QvAiA-3y6dfaYATGG5JIzAWPHfl7FdNJQdtvcfIc8loeusng','2026-09-03 04:31:32','2026-09-03 04:25:23','2026-09-03 04:31:32'),(9,2,1,'2026-09-10','2026-09-10',1.00,'test','approved','not_required','approved','pending_supervisor',1,NULL,1,'','MEYCIQDUVgyjNlpWHHWKh6wj_FI-TexVLgk9nDFtPr_Z5X7EOwIhAIVE8MRalq3F--EE8VwEEbC-W5jyvuE-agIBnTk091aU','2026-09-07 00:56:42','2026-09-07 00:54:18','2026-09-07 00:56:42'),(10,3,1,'2026-09-11','2026-09-14',4.00,'test','rejected','approved','rejected','pending_supervisor',1,'test',1,'test','MEUCIAxD0iPe8b2vSNWi1_mMeWJAunItridUUPWjK02jDSFVAiEA_pZbhMTVTXMwYKUAwtBdXPIxVoISwCwYLpRY5rnmHv4','2026-09-07 00:56:31','2026-09-07 00:55:24','2026-09-07 00:57:00'),(11,2,1,'2026-09-11','2026-09-11',1.00,'test','approved','not_required','approved','pending_supervisor',1,NULL,4,'test','MEYCIQDiLqipyboJWmQk28ym2q91lSS2uVSg9LlcxV1thKFfiAIhALEWPV7g_3VnyiS8R_XUoa6Zi-VvS_HPqNWo18bd1xtr','2026-09-07 01:11:16','2026-09-07 00:59:44','2026-09-07 01:11:16'),(12,3,1,'2026-09-18','2026-09-21',2.00,'test','approved','approved','approved','pending_supervisor',2,'',4,'test','MEUCIQDB6i54IUAgxrLcjrMNJs3JR_OtZGSCkBoYJg7OMEeybgIgcx2sOaqM3vouJonx5UTL0XGdUdNU08ejRKDg85CvlRc','2026-09-07 01:19:43','2026-09-07 01:17:04','2026-09-07 01:19:43'),(13,3,1,'2026-09-30','2026-09-30',1.00,'test\n','pending','approved','pending','pending_supervisor',2,'test',NULL,NULL,'MEUCIHO3XsqJiwAysiIqrI06_RjiXs4WYaWRR01KSDae3MweAiEAy4aFhOZByCEwjuzW1OP8LPiCq5RVN-hE3lIVXafclb4','2026-09-07 01:25:24','2026-09-07 01:25:01','2026-09-07 01:25:24');
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
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (10,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-08-27 06:25:48',NULL),(21,1,'New Account Pending Approval','Josef Jurendel Castro has requested account activation.','info','user',2,0,'2026-09-02 01:12:20',NULL),(22,1,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',7,0,'2026-09-03 03:29:25',NULL),(23,3,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-07 to 2026-09-07. It now awaits HR approval.','info','leave_request',7,0,'2026-09-03 03:46:02',NULL),(24,3,'Leave Request Approved','Your leave request from 2026-09-07 to 2026-09-07 has been approved.','info','leave_request',7,0,'2026-09-03 03:47:49',NULL),(25,1,'New Account Pending Approval','Ronnie Formento has requested account activation.','info','user',4,0,'2026-09-03 03:50:56',NULL),(26,2,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',8,0,'2026-09-03 04:25:24',NULL),(27,4,'New Leave Request','New leave request awaiting HR approval','info','leave_request',8,0,'2026-09-03 04:30:50',NULL),(28,3,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-07 to 2026-09-07. It now awaits HR approval.','info','leave_request',8,0,'2026-09-03 04:30:50',NULL),(29,3,'Leave Request Approved','Your leave request from 2026-09-07 to 2026-09-07 has been approved.','info','leave_request',8,0,'2026-09-03 04:31:32',NULL),(30,4,'New Leave Request','New leave request from Josef Jurendel Castro','info','leave_request',9,0,'2026-09-07 00:54:18',NULL),(31,2,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',10,0,'2026-09-07 00:55:24',NULL),(32,4,'New Leave Request','New leave request awaiting HR approval','info','leave_request',10,0,'2026-09-07 00:56:31',NULL),(33,3,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-11 to 2026-09-14. It now awaits HR approval.','info','leave_request',10,0,'2026-09-07 00:56:31',NULL),(34,2,'Leave Request Approved','Your leave request from 2026-09-10 to 2026-09-10 has been approved.','info','leave_request',9,0,'2026-09-07 00:56:42',NULL),(35,3,'Leave Request Rejected','Your leave request from 2026-09-11 to 2026-09-14 has been rejected.','info','leave_request',10,0,'2026-09-07 00:57:00',NULL),(36,4,'New Leave Request','New leave request from Josef Jurendel Castro','info','leave_request',11,0,'2026-09-07 00:59:44',NULL),(37,2,'Leave Request Approved','Your leave request from 2026-09-11 to 2026-09-11 has been approved.','info','leave_request',11,0,'2026-09-07 01:11:16',NULL),(38,2,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',12,0,'2026-09-07 01:17:04',NULL),(39,4,'New Leave Request','New leave request awaiting HR approval','info','leave_request',12,0,'2026-09-07 01:19:20',NULL),(40,3,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-18 to 2026-09-21. It now awaits HR approval.','info','leave_request',12,0,'2026-09-07 01:19:20',NULL),(41,3,'Leave Request Approved','Your leave request from 2026-09-18 to 2026-09-21 has been approved.','info','leave_request',12,0,'2026-09-07 01:19:43',NULL),(42,2,'New Leave Request','New leave request from Cyril Christian Gardon','info','leave_request',13,0,'2026-09-07 01:25:01',NULL),(43,4,'New Leave Request','New leave request awaiting HR approval','info','leave_request',13,0,'2026-09-07 01:25:24',NULL),(44,3,'Leave Request: Supervisor Approved','Your supervisor approved your leave request from 2026-09-30 to 2026-09-30. It now awaits HR approval.','info','leave_request',13,0,'2026-09-07 01:25:24',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (4,1,'9d644fe40a7335ef22ca54b89e3209a9a15b885070c74e303c1ae4460318816e',2,'203.177.49.42','2026-08-26 07:00:05','2026-08-26 05:52:02'),(26,1,'849b6098df773bd47471547225ab32abc42251b970bcdc7d98b33dff7957dbf4',5,'136.158.103.18','2026-08-26 12:59:36','2026-08-26 11:39:44'),(29,1,'9057d05753845ea9ba4ff8b49e5a729f16cb963f95f6c89b9945d7b7fce5d1ee',2,'209.35.170.100','2026-08-27 01:18:19','2026-08-27 00:03:56'),(91,1,'61c4e4bde3ff5cb3277cb52b75ed524626180c886c8b68df3bfbb57072ecd917',11,'216.247.85.11','2026-10-03 03:51:47','2026-09-03 03:48:46'),(94,1,'e49e33319cee79c94601494bbbe14c41844cc4610cd52e904a800673e50c96f1',9,'216.247.85.11','2026-10-03 03:51:40','2026-09-03 03:51:40'),(100,3,'812715728057a111c7b3c6a37ff6b057c6f42adf7c3126a38aa7538c9841443d',13,'203.177.49.42','2026-10-03 04:49:01','2026-09-03 04:28:34'),(128,4,'26333ad5bb43b17b8600657000988d5d5cf19361c2029f88438cf8cc0415d038',17,'203.177.49.42','2026-10-08 05:24:59','2026-09-07 01:11:03'),(131,2,'181fc80b9c8163756cfc5db79ddb5fd4294ce8d6da9945f8df506c34de389d05',18,'203.177.49.42','2026-10-08 04:24:17','2026-09-07 01:16:04'),(134,3,'1c8b7b243d2ead162afb5157bd427139f0e0287d6b7610a39c2ec0348638272e',13,'180.193.218.250','2026-10-07 02:51:57','2026-09-07 01:24:34');
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
INSERT INTO `user_id_sequence` VALUES (1,5);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@thelewiscollege.edu.ph','$2y$10$VYHGcBlY1AY9YAnbwcxG9uj5fjLUT9WwOks2TuBj/hxOtS/APudJy','System Administrator','ADMIN',NULL,'male',NULL,'admin',NULL,7,'active',1,NULL,NULL,1,'2026-08-26 03:32:46','2026-08-27 00:45:08'),(2,'josefjurendelcastro','josefjurendelcastro@thelewiscollege.edu.ph','$2y$10$LSg9rX4QY4cDDflTQHGS5u3SJiz/Xuw97tTW5U.BadlDpQGbmoBz6','Josef Jurendel Castro','CCS','Instructor','male',1,'manager',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA+xh7jW9ILyTDs1fiGssB\nwrJK1IRO5E8lS39u6NWFESa4A38IXA1LE531+FLARbgXlZgaEyqrc6sh8ZUwnVh1\n7srHlsNaokLxsAIiklIAfTN2C9t6/rDoohZ/pySaH/ZLgCgsNFQqCmm89qdSXGS2\n/94zJ5wcdMRicFXF8MkhgjZi9EcoLere09yzbybbkyaKIi9Re0tnWzvLDT7ZGnN7\nkWV8QTlBP0UT5l80uVxrnawkoqMhioKvC/pieMGU/E8r6BjVh4Q4rmz3EGcuswTr\niFUtxa8jXkiqxxa9wS/BLAmlKVPxRivhwkbg23LkbS+IfTieRcRAjDQ7/eQ9hQez\nXX0Q9Wmm9yLu403F3UCK8LEB0RIWGlzyoToupdmRF2jPjpagA2+6ret+ssjgwFLA\nu4oQgRGJpsrB/IRETy//SQoY8HRbz79tPmvbdU+luIT8LUaiK6vVnuwoA9y4p1V9\n+F/kZNFZZDarsYPUS2Sw/H8AWb7O72fbqwqkAvz/7zKZl5xyFRIiomA+/fiboC2M\nD5nGE60V9+2MLX0O+VHpqp1EEr2A8oVopsx3lRwUP+BNrF2a4OHntbJ/k13om64k\nkBI6rvviWl0IJdAs/rPa4hDIoEyZ6FKOdk0e3oIeOwOiTrY4b/oBIw6/4UHfvL4T\nyeDGxx+8mJtKx+cQzdTEgeMCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-02 00:01:28','2026-09-07 00:42:26'),(3,'cyrilchristiangardon','cyrilchristiangardon@thelewiscollege.edu.ph','$2y$10$OSvCBl0BreUiRJDYV3Lw8OLRqJXWOzNVtZOIHxKGEZjpJw.xrOMHm','Cyril Christian Gardon','CCS','Instructor','male',2,'employee',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqh/9arvLpAB8A/FP99I8\nbAItYMU5QwREtaVJY9lqKfG1kJNqpch2TDXc9StGP+UhyrMmgA7Q+aJU905AvwHS\nIzm1wVngEdhNANPLmEGJKj9iuNAo8+6/124KaXNvWAj3sck4y9/y+rClarqkFJVH\nJ0fCgPf4qffx3oxzLVnAMhPIxFULcpaFnF1bm8xwv8wE3KuRK4W4Na4TuuMSrpi1\nLThNXnk+Qm43dtHBC/8B92DFOSBnd2CoW9H5TZuP4lmWX4bg7TbimU0IPuq1+3+a\nORHmMSQ/8LRYh1mJVZI3cJH5CTDPsMhcBviA8GT5WmFhkpxOqEwhvLNWND0j4sZi\npdIOQPz5NkcoakR1D9YPk3/ODjEF7CUurfyrssp3Ih9cYGNqt/ekIR4+ZUSUt/hG\n3PWqaL0vK1cPphxA159iYZtscXRyBP7dv6OBFKOI5pzM7/NV+NdJ1wQWD75mOGNw\nKstZ7GDFc86o89TEz00p55ogarO0RJCmG3+HcQQEZcCLfjszsmuPGlbnVEyL/MU2\nwlvrTz3Rz2hbgF7gwjAeAbNGKhrA0PPs7GnqI6VG6hLC7b/a9Tt6yPqmSp0AtE/Y\nERTAiGK19ItKAKmdPZbS+vwJ4PH+txDXrwec5O8lV5Er16UHhNrHeOM+Ojoh6UEz\n7IG3Z8e8U5+BurwZ5U69zRMCAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-03 03:01:30','2026-09-07 00:40:51'),(4,'ronnieformento','ronnieformento@thelewiscollege.edu.ph','$2y$10$ExX2e.Hbwo3NWagC5GyVV.xjnuuL0C5MWYTpIZerYdqAqSC1TR0AO','Ronnie Formento','ADMIN','HR Officer','male',1,'hr',NULL,NULL,'active',1,NULL,'-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqGdkrm+EHK5fFjQdC45W\nZI/+ktRrdaQUkeAEdJ4so8iv9d1r85/q2og+EuutjjY6kZ6i4DoYJ5qjSv0RUl1v\nzP6p9UmGnbaV7C5ypwIO+t0iEhhDV80eN6ki+ZbtvRhvth22LIOnvoRLSrF+98j0\nYcNU48uf0kCvT9PC5nOjud6bnBY59kVGLB4IGWXbKnRF/Xk2EoW5TqEmYafc978u\ni0g+MvrfHAWnvgoiWfRljXeysX2q6Z2TcJSWSKZ52CdbliuuDlxkDClsDj1S2SrQ\nm17ufSUYhr/5TN/39Pzt4oMWnt5gy9xRYhUaRINEPXU8HZL3oFnwpfPAduz/2H0L\nUXWP9e2eJE/xp5meUpndtJSf2yrS3c66eRNe/5F8GUw1LgpOUBCt68amB9JJsAwr\nD1foCvHRYLRaK2M1FpQVeEPWLNvCDXb+pk5QWb0NtSLFXE2WyPFedxAIbFrzeoFM\nXoOEpV7hEfZ0AWySerC9Str+6+minq6cXxOPz6eAcsCjitiJj9G/ssuhwSzQhvaV\nh4FsKUJFPqgtmwJqwaB4XNC3zBTdZqbRvkRPqIWvsM5V61bA6nbmaq46RabTq9yG\nE8CTf/ueqiPhAhn8jRfjkXJbBWdb//EAcURFrPwwKjx5Yw3AZgdXTNaNpGjB7jUM\n/l6989KLrl6wwUAZAqw0PZ8CAwEAAQ==\n-----END PUBLIC KEY-----\n',1,'2026-09-03 03:50:37','2026-09-07 00:44:34');
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
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_challenges`
--

LOCK TABLES `webauthn_challenges` WRITE;
/*!40000 ALTER TABLE `webauthn_challenges` DISABLE KEYS */;
INSERT INTO `webauthn_challenges` VALUES (24,1,'nOaG8AxHqTmPl5JQ6vsq6Fnbl8HmbAAv5PXRGsRoxKU','approval','device_change',7,'2026-08-27 06:34:27','2026-08-27 06:29:27'),(30,1,'Wt_XMjjKEHtAbwUgwi71oHMLGmVrf_yizu5JGB2u4xI','approval','device_change',9,'2026-08-27 10:07:17','2026-08-27 10:02:17'),(39,2,'4UHTJ-Ik9did_EJy_6uL8eIgJRxRKwMdyf9Mp_J8ByM','registration',NULL,NULL,'2026-09-03 04:26:24','2026-09-03 04:21:24'),(40,2,'PxkCDygCRAiZE_Nbzjw9WCmnlGq6uO7LaDLsOQbJaXQ','registration',NULL,NULL,'2026-09-03 04:26:36','2026-09-03 04:21:36'),(43,4,'cEw6jJ9NMobUIOCzchlyuk5_Rpl1tZhMHDMK21RIJZY','registration',NULL,NULL,'2026-09-03 04:28:19','2026-09-03 04:23:19'),(44,4,'O-LtSCo0qvQs0vjmF35lCBHcXU1r6Lli0ndHM-E-CMc','registration',NULL,NULL,'2026-09-03 04:28:28','2026-09-03 04:23:28'),(46,4,'jBDjykz0IQ78zcBUmOA5RsbGQwtgpDUDv4ztK-Ykauo','registration',NULL,NULL,'2026-09-03 04:28:55','2026-09-03 04:23:55'),(47,4,'5Xnm4V2DXQ302BQd_uvYbz0JW7YBPo4rXmZ_9tb6j4U','registration',NULL,NULL,'2026-09-03 04:29:06','2026-09-03 04:24:06'),(49,4,'0o_lF5csvPCLxXSu8dlYxO5HLiXIqmlEq4zGqjQwZccsUn_L_qCm9jlL7E-agKfiC0otJivTURFGfkfL-Chyqg','approval','leave_request',8,'2026-09-03 04:36:14','2026-09-03 04:31:14'),(50,4,'ryo6JaCu0ehgoUnP34KQX1HxflzB1OauG7w4afLsQq8sUn_L_qCm9jlL7E-agKfiC0otJivTURFGfkfL-Chyqg','approval','leave_request',8,'2026-09-03 04:36:19','2026-09-03 04:31:19'),(51,4,'n_BuNIPovhXToHYGNqjJgkKMqhvAETb3eziMyHYcLRcsUn_L_qCm9jlL7E-agKfiC0otJivTURFGfkfL-Chyqg','approval','leave_request',8,'2026-09-03 04:36:23','2026-09-03 04:31:23'),(56,1,'bz1aPmo4Qs2MCBX1nZ9jBmiqN7mFnmOwfhE94u3R-BY','approval','device_change',15,'2026-09-03 05:17:35','2026-09-03 05:12:35'),(65,4,'QVWZ9QU5WcmzmnQ173I6FEQHLVjk5cu3zBdEInCj5FfEIpydzp2lku2K3x_b3ZdaSzKIkk3QRUSN8l65WQnwuw','approval','leave_request',11,'2026-09-07 01:15:29','2026-09-07 01:10:29'),(66,4,'ob5QvC82vuiSqObZhxPdBJYeR8vsceTx8v4TyFgpfo7EIpydzp2lku2K3x_b3ZdaSzKIkk3QRUSN8l65WQnwuw','approval','leave_request',11,'2026-09-07 01:15:42','2026-09-07 01:10:42'),(70,2,'rWpBxy5ihD7utxEtG83rQ6733Lv595t04MjP771Vi9c','registration',NULL,NULL,'2026-09-07 01:21:18','2026-09-07 01:16:18'),(72,2,'APdl4NqtOf7ZWeoaB6G8anuFIY_7UTtAEDAyTEuAQjrmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:22:39','2026-09-07 01:17:39'),(73,2,'J0xRJ3pbYGxz6p5hP4M_w5VMBKa2onz8ZTpYWKBi1u3mF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:22:48','2026-09-07 01:17:48'),(75,2,'N-NbACdEFhY71rJM_tAxrEuFpR_o9zJk2O3QxMORh87mF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:23:52','2026-09-07 01:18:52'),(76,2,'32pjqx7ED-wG7CsUxPF7j4EEeRcwa9ddTQrUL7cr_KvmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:24:00','2026-09-07 01:19:00'),(77,2,'cgw_X6S5H_F4pJwiq2WR0ELNZWblKYWE_Bn3o_B7CcDmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:24:03','2026-09-07 01:19:03'),(78,2,'bVmDiK9K7lSw4jkDnZxODrQ9EQcaNRqZUTs_WRBlvELmF5Ij43nzqJpzFBvnVJfYef8SO9Dk7P9W1tq5Z95nAw','approval','leave_request',12,'2026-09-07 01:24:05','2026-09-07 01:19:05');
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webauthn_credentials`
--

LOCK TABLES `webauthn_credentials` WRITE;
/*!40000 ALTER TABLE `webauthn_credentials` DISABLE KEYS */;
INSERT INTO `webauthn_credentials` VALUES (11,1,'Gek3yl-BEN-cOw64S_DBmw','pQECAyYgASFYIA315ZomqJtEDCGqUXPYH5Mf1k0I5uxG5JcFUC8guURhIlggdbFyoX6P9c7avpRo7ayArYGVr9A7prU+HQnt+fE6T9Y=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'laptop','ae0b268077de8046ff0c36bc810656983c652257c17979a8f903b722d0aae064','Chrome • Windows PC','2026-09-07 00:45:20','2026-09-07 01:14:10'),(12,4,'LPmImDSFpvr9lFWNfaxizQ','pQECAyYgASFYIJYoF/6ervuuDjrA9y3cI++WaLYlp01P0sHMb7qQn8maIlgg6OpWxJ2Xd5JKKYAbNL7IewjVl/MXa5PWbm7npf+OR2k=','none',NULL,'ea9b8d66-4d01-1d21-3ce4-b6b48cb575d4','[]',0,'samsung','6220888a45abdcda8d583a34fc97d2faa3aff57df20af69a955ed4600576df02','Chrome • Android Device','2026-09-07 01:09:51','2026-09-07 01:19:43'),(13,2,'UnXj8rbbeNH8_mTA9jW3UA1c_08','pQECAyYgASFYINHYR34mSprZM+cJGQU6pvMk/oetrRu46dJ0Ld3jCzYoIlgg7kA/iRjdt4IIok5uN+jTWLeL8FkHhq6ikv5GpkGC8PE=','none',NULL,'fbfc3007-154e-4ecc-8c0b-6e020557d7bd','[]',0,'Passkey','30c190c18197ac61c2be6da06dfec5df73f010d40c364d4a6f28b519372f4e3f','Safari • iPhone','2026-09-07 01:16:25','2026-09-07 01:25:24');
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

-- Dump completed on 2026-09-08  6:04:04
