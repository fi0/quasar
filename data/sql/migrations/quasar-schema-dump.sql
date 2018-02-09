-- MySQL dump 10.13  Distrib 5.7.21, for osx10.13 (x86_64)
--
-- Host: quasar.c9ajz690mens.us-east-1.rds.amazonaws.com    Database: cio
-- ------------------------------------------------------
-- Server version	5.7.17-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `cio`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cio` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `cio`;

--
-- Table structure for table `blink`
--

DROP TABLE IF EXISTS `blink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blink` (
  `blink_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(26) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`blink_id`),
  KEY `event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `customer_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `email_address` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mobile` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_name` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`customer_id`,`email_address`,`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_event`
--

DROP TABLE IF EXISTS `customer_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer_event` (
  `event_type` varchar(26) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  `customer_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `id_event_id` (`customer_id`,`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_event`
--

DROP TABLE IF EXISTS `email_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_event` (
  `blink_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_name` varchar(26) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_page` text COLLATE utf8mb4_unicode_ci,
  `customer_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_id` varchar(26) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(26) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_name` text COLLATE utf8mb4_unicode_ci,
  `subject` text COLLATE utf8mb4_unicode_ci,
  `campaign_id` int(11) DEFAULT NULL,
  `campaign_name` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`blink_id`,`event_id`,`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_log`
--

DROP TABLE IF EXISTS `event_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_log` (
  `meta` json DEFAULT NULL,
  `data` json DEFAULT NULL,
  `northstar_id` varchar(26) COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS (json_unquote(json_extract(`data`,'$.data.customer_id'))) VIRTUAL,
  `event_id` varchar(26) COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS (json_unquote(json_extract(`data`,'$.event_id'))) VIRTUAL,
  KEY `event_id` (`event_id`),
  KEY `nsid` (`northstar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `legacy_sub_backlog`
--

DROP TABLE IF EXISTS `legacy_sub_backlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legacy_sub_backlog` (
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NOT NULL,
  `northstar_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `allcolls` (`status`,`timestamp`,`northstar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `gladiator`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `gladiator` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `gladiator`;

--
-- Table structure for table `competitions`
--

DROP TABLE IF EXISTS `competitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competitions` (
  `id` int(11) NOT NULL,
  `leaderboard_msg_day` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rules` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `competition_dates_start` datetime DEFAULT NULL,
  `competition_dates_end` datetime DEFAULT NULL,
  `contest_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`contest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contest`
--

DROP TABLE IF EXISTS `contest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contest` (
  `id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `campaign_run_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sender_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sender_email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`,`campaign_id`,`campaign_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `contest_id` int(11) NOT NULL,
  `label` text COLLATE utf8mb4_unicode_ci,
  `subject` text COLLATE utf8mb4_unicode_ci,
  `body` text COLLATE utf8mb4_unicode_ci,
  `signoff` text COLLATE utf8mb4_unicode_ci,
  `protip` text COLLATE utf8mb4_unicode_ci,
  `show_images` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type_name` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type_key` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`,`contest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contest_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `subscribed` tinyint(1) DEFAULT NULL,
  `unsubscribed` tinyint(1) DEFAULT NULL,
  `waiting_room_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`,`contest_id`,`campaign_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `waiting_room`
--

DROP TABLE IF EXISTS `waiting_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `waiting_room` (
  `id` int(11) NOT NULL,
  `open` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `contest_id` int(11) NOT NULL,
  `signup_date_start` datetime DEFAULT NULL,
  `signup_date_end` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`contest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `quasar`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `quasar` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `quasar`;

--
-- Table structure for table `campaign_activity`
--

DROP TABLE IF EXISTS `campaign_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_activity` (
  `northstar_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `signup_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `campaign_run_id` int(11) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  `why_participated` text COLLATE utf8mb4_unicode_ci,
  `signup_source` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signup_details` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signup_created_at` datetime NOT NULL,
  `signup_updated_at` datetime NOT NULL,
  `post_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` text COLLATE utf8mb4_unicode_ci,
  `caption` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remote_addr` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_source` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(192) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_type` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submission_created_at` datetime DEFAULT NULL,
  `submission_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`northstar_id`,`signup_id`,`campaign_id`,`campaign_run_id`,`post_id`),
  UNIQUE KEY `updates` (`northstar_id`,`signup_id`,`signup_created_at`,`signup_updated_at`,`submission_created_at`),
  KEY `northstar_id` (`northstar_id`),
  KEY `campaign_id` (`campaign_id`),
  KEY `campaign_run_id` (`campaign_run_id`),
  KEY `submission_updated_at` (`submission_updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `log` AFTER INSERT ON `campaign_activity` FOR EACH ROW BEGIN  
INSERT IGNORE INTO campaign_activity_log SELECT * FROM campaign_activity WHERE northstar_id = NEW.northstar_id AND signup_id = NEW.signup_id AND campaign_id = NEW.campaign_id AND campaign_run_id = NEW.campaign_run_id AND post_id = NEW.post_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `campaign_activity_details`
--

DROP TABLE IF EXISTS `campaign_activity_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_activity_details` (
  `post_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hostname` varchar(192) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referral_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `partner_comms_opt_in` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `source_details` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voter_registration_status` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voter_registration_source` varchar(192) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voter_registration_method` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voting_method_preference` varchar(192) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_subscribed` tinyint(1) DEFAULT NULL,
  `sms_subscribed` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`post_id`,`created_at`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaign_activity_log`
--

DROP TABLE IF EXISTS `campaign_activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_activity_log` (
  `northstar_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `signup_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `campaign_run_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `why_participated` text COLLATE utf8mb4_unicode_ci,
  `signup_source` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signup_details` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signup_created_at` datetime NOT NULL,
  `signup_updated_at` datetime NOT NULL,
  `post_id` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `url` text COLLATE utf8mb4_unicode_ci,
  `caption` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remote_addr` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_source` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(192) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_type` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submission_created_at` datetime NOT NULL,
  `submission_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`northstar_id`,`signup_id`,`signup_created_at`,`signup_updated_at`,`submission_created_at`),
  KEY `northstar_id` (`northstar_id`),
  KEY `campaign_id` (`campaign_id`),
  KEY `campaign_run_id` (`campaign_run_id`),
  KEY `submission_updated_at` (`submission_updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaign_info`
--

DROP TABLE IF EXISTS `campaign_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_info` (
  `campaign_node_id` int(11) DEFAULT NULL,
  `campaign_node_id_title` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_run_id` int(11) NOT NULL,
  `campaign_run_id_title` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_url` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_type` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_language` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `campaign_run_start_date` datetime DEFAULT NULL,
  `campaign_run_end_date` datetime DEFAULT NULL,
  `campaign_created_date` datetime DEFAULT NULL,
  `campaign_action_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_cause_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_cta` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_noun` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign_verb` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`campaign_run_id`,`campaign_language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `member_event_log`
--

DROP TABLE IF EXISTS `member_event_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_event_log` (
  `event_id` varchar(116) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_serial_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `northstar_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timestamp` datetime DEFAULT NULL,
  `action_type` varchar(16) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `action_id` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `source` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `event_id` (`event_id`,`northstar_id`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `moco_profile_import`
--

DROP TABLE IF EXISTS `moco_profile_import`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moco_profile_import` (
  `moco_id` int(11) NOT NULL,
  `mobile` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opted_out_at` datetime DEFAULT NULL,
  `opted_out_source` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street1` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street2` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_city` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_state` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_zip` int(11) DEFAULT NULL,
  `addr_country` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_city` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_state` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_zip` int(11) DEFAULT NULL,
  `loc_country` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_latlong` point DEFAULT NULL,
  PRIMARY KEY (`moco_id`,`mobile`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `moco_profile_import_v1`
--

DROP TABLE IF EXISTS `moco_profile_import_v1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moco_profile_import_v1` (
  `moco_id` int(11) NOT NULL,
  `mobile` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opted_out_at` datetime DEFAULT NULL,
  `opted_out_source` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street1` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street2` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_city` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_state` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_zip` int(11) DEFAULT NULL,
  `addr_country` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_city` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_state` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_zip` int(11) DEFAULT NULL,
  `loc_country` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loc_latlong` point DEFAULT NULL,
  PRIMARY KEY (`moco_id`,`mobile`,`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `monitoring`
--

DROP TABLE IF EXISTS `monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoring` (
  `output` bigint(20) DEFAULT NULL,
  `query` text COLLATE utf8mb4_unicode_ci,
  `table` text COLLATE utf8mb4_unicode_ci,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `monitoring_24012018`
--

DROP TABLE IF EXISTS `monitoring_24012018`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoring_24012018` (
  `index` bigint(20) DEFAULT NULL,
  `output` bigint(20) DEFAULT NULL,
  `query` text COLLATE utf8mb4_unicode_ci,
  `table` text COLLATE utf8mb4_unicode_ci,
  `timestamp` text COLLATE utf8mb4_unicode_ci,
  KEY `ix_quasar_monitoring_index` (`index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phoenix_user_log_poc`
--

DROP TABLE IF EXISTS `phoenix_user_log_poc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phoenix_user_log_poc` (
  `uid` int(11) NOT NULL,
  `name` varchar(60) NOT NULL,
  `mail` varchar(254) NOT NULL,
  `created` int(11) NOT NULL,
  `access` int(11) NOT NULL,
  `login` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL,
  `timezone` varchar(32) DEFAULT NULL,
  `language` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`uid`,`created`,`access`,`login`),
  KEY `uid-index` (`uid`),
  KEY `mail` (`mail`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_game_log`
--

DROP TABLE IF EXISTS `sms_game_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_game_log` (
  `event_id` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `uid` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `action` varchar(8) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `action_id` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `run_nid` bigint(20) DEFAULT NULL,
  `run_name` varchar(255) CHARACTER SET ucs2
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `northstar_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_logged_in` datetime DEFAULT NULL,
  `last_accessed` datetime DEFAULT NULL,
  `drupal_uid` int(24) DEFAULT NULL,
  `source` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `facebook_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birthdate` datetime DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street1` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street2` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_city` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_state` varchar(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_zip` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agg_id` int(16) DEFAULT NULL,
  `cgg_id` int(16) DEFAULT NULL,
  `customer_io_subscription_status` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_io_subscription_timestamp` datetime DEFAULT NULL,
  `moco_commons_profile_id` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sms_status` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_detail` varchar(96) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`northstar_id`),
  UNIQUE KEY `id_plus_address` (`northstar_id`,`addr_street1`,`addr_street2`,`addr_city`,`addr_state`,`addr_zip`,`country`),
  KEY `drupal_uid` (`drupal_uid`),
  KEY `cgg_id` (`cgg_id`),
  KEY `agg_id` (`agg_id`),
  KEY `email` (`email`),
  KEY `mobile` (`mobile`),
  KEY `customer_io_subscription_status` (`customer_io_subscription_status`),
  KEY `moco_id` (`moco_commons_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER userlog AFTER UPDATE ON users
FOR EACH ROW BEGIN  
INSERT IGNORE INTO users_log SELECT * FROM users WHERE northstar_id = NEW.northstar_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users_log`
--

DROP TABLE IF EXISTS `users_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_log` (
  `northstar_id` varchar(26) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_logged_in` datetime NOT NULL,
  `last_accessed` datetime NOT NULL,
  `drupal_uid` int(24) DEFAULT NULL,
  `source` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `facebook_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birthdate` datetime DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street1` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_street2` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_city` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_state` varchar(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_zip` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agg_id` int(16) DEFAULT NULL,
  `cgg_id` int(16) DEFAULT NULL,
  `customer_io_subscription_status` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_io_subscription_timestamp` datetime DEFAULT NULL,
  `moco_commons_profile_id` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sms_status` varchar(48) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_detail` varchar(96) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`northstar_id`,`last_logged_in`,`last_accessed`),
  KEY `drupal_uid` (`drupal_uid`),
  KEY `cgg_id` (`cgg_id`),
  KEY `agg_id` (`agg_id`),
  KEY `email` (`email`),
  KEY `mobile` (`mobile`),
  KEY `customer_io_subscription_status` (`customer_io_subscription_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `quasar_etl_status`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `quasar_etl_status` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `quasar_etl_status`;

--
-- Table structure for table `moco_campaign_messages_list`
--

DROP TABLE IF EXISTS `moco_campaign_messages_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moco_campaign_messages_list` (
  `campaign_id` int(11) NOT NULL,
  `last_page` int(11) DEFAULT NULL,
  `campaign_scrape_completed` tinyint(1) DEFAULT NULL,
  `status` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`campaign_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `moco_campaign_messages_page`
--

DROP TABLE IF EXISTS `moco_campaign_messages_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moco_campaign_messages_page` (
  `last_page` int(11) NOT NULL,
  PRIMARY KEY (`last_page`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `moco_profile_scraper_page`
--

DROP TABLE IF EXISTS `moco_profile_scraper_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moco_profile_scraper_page` (
  `last_page_scraped` int(11) NOT NULL,
  PRIMARY KEY (`last_page_scraped`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `northstar_ingestion`
--

DROP TABLE IF EXISTS `northstar_ingestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `northstar_ingestion` (
  `counter_name` varchar(32) NOT NULL,
  `counter_value` int(11) DEFAULT NULL,
  PRIMARY KEY (`counter_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rogue_ingestion`
--

DROP TABLE IF EXISTS `rogue_ingestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rogue_ingestion` (
  `counter_name` varchar(32) NOT NULL,
  `counter_value` int(11) DEFAULT NULL,
  PRIMARY KEY (`counter_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-09 13:16:58
