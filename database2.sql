-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.7.33 - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             12.21.0.7344
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for db_toko
CREATE DATABASE IF NOT EXISTS `db_toko` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `db_toko`;

-- Dumping structure for table db_toko.products
CREATE TABLE IF NOT EXISTS `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) DEFAULT NULL,
  `harga` decimal(12,2) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL,
  `kategori` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- Dumping data for table db_toko.products: ~5 rows (approximately)
INSERT INTO `products` (`id`, `nama`, `harga`, `stok`, `kategori`, `created_at`) VALUES
	(1, 'Laptop ASUS', 8500000.00, 6, 'Elektronik', '2026-09-17 06:32:42'),
	(3, 'Keyboard Rexus', 450000.00, 20, 'Aksesoris', '2026-09-17 06:33:55'),
	(4, 'Keyboard Rexus', 450000.00, 26, 'Aksesoris', NULL),
	(5, 'Keyboard Rexus', 450000.00, 26, 'Aksesoris', NULL),
	(6, 'PC iqoo', 990.00, 0, 'Aksesoris', NULL);

-- Dumping structure for table db_toko.siswa
CREATE TABLE IF NOT EXISTS `siswa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nipd` varchar(20) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `jenis_kelamin` enum('P','L') DEFAULT NULL,
  `kelas` varchar(100) DEFAULT NULL,
  `jurusan` varchar(100) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `nis` (`nipd`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

-- Dumping data for table db_toko.siswa: ~5 rows (approximately)
INSERT INTO `siswa` (`id`, `nipd`, `nama`, `jenis_kelamin`, `kelas`, `jurusan`, `alamat`) VALUES
	(1, '242510064', 'Melvin cuihuy', NULL, 'XII', 'RPL', 'parungpanjang'),
	(2, '242510070', 'Nurlita', NULL, 'XII', 'RPL', 'parungpanjang'),
	(3, '242510071', 'Oktapia Nurpadilah', NULL, 'XII', 'RPL', 'parungpanjang'),
	(4, '242510077', 'Robiyatunnisa', NULL, 'XII', 'RPL', 'parungpanjang'),
	(5, '242510079', 'Siti Nur Kholisha', NULL, 'XII', 'RPL', 'parungpanjang');

-- Dumping structure for table db_toko.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(200) DEFAULT NULL,
  `status` enum('Aktif','Nonaktif') DEFAULT 'Aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- Dumping data for table db_toko.users: ~7 rows (approximately)
INSERT INTO `users` (`id`, `nama`, `email`, `password`, `status`, `created_at`) VALUES
	(1, 'Siti Nur Kholisha', 'Kholishas@gmail.com', '$2b$10$tGBAPqWfuDF4UdX6pLdhl.gsldROxDaGg.ksuS2KA9HtswFJLE4vy', 'Aktif', '2026-09-25 02:22:42'),
	(2, 'Novita Damayanti', 'nopiuhuy@gmail.com', '$2b$10$5GTFwQDnI..F.2XVxfnu1.DSpoyASM5tdGToJbtTXZGuEDVW1HCqi', 'Nonaktif', '2026-09-25 02:22:43'),
	(4, 'Melvin Olivia', 'olivoil@gmail.com', '$2b$10$qtXp4hfGbFWj/OTMhr2/guJEDYwi5luB2mH96eTdABK/AGXB1Nqgu', 'Aktif', '2026-09-25 02:22:45'),
	(5, 'Ratu', 'ratuuhuy@gmail.com', '$2b$10$e/62f7ivPa32TaqvxIBvPuov.2NDk6Oy/UCF.jQST.kIzg9AhLPrK', 'Aktif', '2026-09-25 02:22:46'),
	(7, 'Nurlita', 'litaa@gmail.com', '$2b$10$AzyKIQeIgHBJc3rt4xx1.uCwYeoVXWiumFbor6sDZR3JrGtNFBnPO', 'Aktif', '2026-09-25 02:22:47'),
	(8, 'Nura', 'lrtrtra@gmail.com', '$2b$10$Ii1x5SG5GaoLtxR98SxvpuQ2yku4IIErr1.VC/kyLVr0IfYD8.Zf2', 'Aktif', '2026-09-25 02:22:48'),
	(9, 'Noera', 'tiiroe@gmail.com', '$2b$10$lUtfVkbFLnNhxGOCnMfz2ecDJl3Yye8wPBNqx/UHw1msORtjntiLq', 'Aktif', '2026-09-25 02:22:48');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
