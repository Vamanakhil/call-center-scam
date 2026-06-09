-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
-- Host: 192.168.10.100    Database: golden_crm
-- ------------------------------------------------------
-- Server version   8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

USE golden_crm;

-- --------------------------------------------------------
-- Table structure for table `victims`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `victims`;
CREATE TABLE `victims` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `amount_paid` int(11) DEFAULT 0,
  `closer_id` varchar(50) DEFAULT NULL,
  `status` enum('ACTIVE','BURNED','PENDING','REFUND_PENDING') DEFAULT 'PENDING',
  `registered_on` date DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `closer_idx` (`closer_id`),
  KEY `status_idx` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=488 DEFAULT CHARSET=utf8mb4;

-- Sample victim data (487 rows in production)
INSERT INTO `victims` VALUES
  (1,'Suresh Pillai','+91 9000000001','suresh.pillai@gmail.com',145000,'rahul.s','BURNED','2025-11-12','Complained to police on 14-Mar-2026'),
  (2,'Anita Joshi','+91 9000000002','anita.joshi@gmail.com',78000,'rahul.s','ACTIVE','2026-01-22',NULL),
  (3,'Ramesh Kapoor','+91 9000000003','ramesh.kapoor@gmail.com',232000,'priya.v','ACTIVE','2025-12-08',NULL),
  (4,'Kavita Reddy','+91 9000000004','kavita.reddy@gmail.com',89000,'amit.p','BURNED','2026-02-15','Sent legal notice'),
  (5,'Manish Bose','+91 9000000005','manish.bose@gmail.com',450000,'rahul.s','ACTIVE','2025-10-30',NULL),
  (6,'Pooja Das','+91 9000000006','pooja.das@gmail.com',165000,'sneha.i','PENDING','2026-03-01',NULL),
  (7,'Pradeep Iyer','+91 9000000007','pradeep.iyer@gmail.com',78000,'amit.p','BURNED','2026-01-15','Filed complaint 10-Apr-2026'),
  (8,'Meera Nair','+91 9000000008','meera.nair@gmail.com',320000,'rahul.s','ACTIVE','2025-11-20',NULL),
  (9,'Rakesh Gupta','+91 9000000009','rakesh.gupta@gmail.com',95000,'priya.v','BURNED','2026-02-28',NULL),
  (10,'Swati Mukherjee','+91 9000000010','swati.mukherjee@gmail.com',210000,'sneha.i','ACTIVE','2026-01-10',NULL),
  (11,'Vivek Banerjee','+91 9000000011','vivek.banerjee@gmail.com',45000,'rahul.s','BURNED','2026-03-22','Refusing to pay more'),
  (12,'Anjali Trivedi','+91 9000000012','anjali.trivedi@gmail.com',178000,'rahul.s','ACTIVE','2025-12-15',NULL);

-- --------------------------------------------------------
-- Table structure for table `transactions`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `victim_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `upi` varchar(100) NOT NULL,
  `bank_ref` varchar(50) NOT NULL,
  `txn_time` datetime NOT NULL,
  `status` enum('PENDING','CONFIRMED','FAILED','REFUNDED') DEFAULT 'PENDING',
  PRIMARY KEY (`id`),
  KEY `victim_idx` (`victim_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2315 DEFAULT CHARSET=utf8mb4;

-- Sample transaction data (2314 rows in production)
INSERT INTO `transactions` VALUES
  (1,1,25000,'arjun.collect@okhdfcbank','HDFC2026041810253412','2026-04-18 10:25:34','CONFIRMED'),
  (2,1,120000,'arjun.collect@okhdfcbank','HDFC2026041815410207','2026-04-18 15:41:02','CONFIRMED'),
  (3,2,30000,'arjun.collect@okhdfcbank','HDFC2026041711473256','2026-04-17 11:47:32','CONFIRMED'),
  (4,2,48000,'arjun.collect@okhdfcbank','HDFC2026041812530811','2026-04-18 12:53:08','CONFIRMED'),
  (5,3,50000,'arjun.collect@okhdfcbank','HDFC2026041609321547','2026-04-16 09:32:15','CONFIRMED'),
  (6,3,182000,'arjun.collect@okhdfcbank','HDFC2026041817224823','2026-04-18 17:22:48','CONFIRMED'),
  (7,4,25000,'arjun.collect@okhdfcbank','HDFC2026041414125871','2026-04-14 14:12:58','CONFIRMED'),
  (8,4,64000,'arjun.collect@okhdfcbank','HDFC2026041816251722','2026-04-18 16:25:17','CONFIRMED'),
  (9,5,100000,'arjun.collect@okhdfcbank','HDFC2026041508543098','2026-04-15 08:54:30','CONFIRMED'),
  (10,5,350000,'arjun.collect@okhdfcbank','HDFC2026041809231245','2026-04-18 09:23:12','CONFIRMED');

-- --------------------------------------------------------
-- Table structure for table `call_logs`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `call_logs`;
CREATE TABLE `call_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` varchar(50) NOT NULL,
  `victim_id` int(11) NOT NULL,
  `call_time` datetime NOT NULL,
  `duration_sec` int(11) DEFAULT NULL,
  `outcome` enum('CONNECTED','VOICEMAIL','NO_ANSWER','REJECTED') DEFAULT NULL,
  `recording_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_idx` (`agent_id`),
  KEY `victim_idx` (`victim_id`)
) ENGINE=InnoDB AUTO_INCREMENT=892 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `users` (admin credentials)
-- --------------------------------------------------------

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('ADMIN','AGENT','MANAGER','VIEWER') NOT NULL,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_idx` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `users` VALUES
  (1,'arjun.m','$2y$10$abc...xyz','ADMIN','2026-04-18 11:25:00'),
  (2,'rahul.s','$2y$10$def...uvw','AGENT','2026-04-18 11:00:00'),
  (3,'priya.v','$2y$10$ghi...rst','AGENT','2026-04-18 10:30:00'),
  (4,'amit.p','$2y$10$jkl...opq','AGENT','2026-04-18 09:45:00'),
  (5,'sneha.i','$2y$10$mno...lmn','AGENT','2026-04-18 11:15:00'),
  (6,'vikas.n','$2y$10$pqr...ijk','IT_ADMIN','2026-04-18 02:14:00'),
  (7,'crm_app','$2y$10$stu...hij','APP','2026-04-18 11:25:00');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
