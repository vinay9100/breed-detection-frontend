-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 01, 2026 at 07:29 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bsai`
--

-- --------------------------------------------------------

--
-- Table structure for table `animal_detections`
--

CREATE TABLE `animal_detections` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `breed_name` varchar(100) NOT NULL,
  `confidence_score` float NOT NULL,
  `yield_estimate` float DEFAULT NULL,
  `animal_type` varchar(50) DEFAULT NULL,
  `fat_content` varchar(50) DEFAULT NULL,
  `detected_at` datetime DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `milk_yield_range` varchar(100) DEFAULT NULL,
  `animal_ear_tag` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `animal_detections`
--

INSERT INTO `animal_detections` (`id`, `user_id`, `breed_name`, `confidence_score`, `yield_estimate`, `animal_type`, `fat_content`, `detected_at`, `image_path`, `milk_yield_range`, `animal_ear_tag`) VALUES
(142, 17, 'Murrah', 96.4, 13.5, 'Buffalo', '7.5%', '2026-03-17 08:52:08', 'uploads/scan_17_20260317_142207.jpg', '12-15L/day', 'ET-123'),
(143, 17, 'Sahiwal', 85.8, 16.5, 'Cow', '4.2%', '2026-03-17 09:05:22', 'uploads/scan_17_20260317_143522.jpg', '15-18L/day', 'ET-321'),
(144, 17, 'Murrah', 96.4, 13.5, 'Buffalo', '7.5%', '2026-03-17 09:10:00', 'uploads/scan_17_20260317_143959.jpg', '12-15L/day', 'ET-'),
(145, 17, 'Kankrej', 86.5, 12.5, 'Cow', '4.8%', '2026-03-17 09:10:59', 'uploads/scan_17_20260317_144059.jpg', '10-15L/day', 'ET-'),
(146, 17, 'Kankrej', 86.5, 12.5, 'Cow', '4.8%', '2026-03-17 09:13:13', 'uploads/scan_17_20260317_144059.jpg', '10-15L/day', NULL),
(147, 17, 'Gir', 85.8, 13.5, 'Cow', '4.5%', '2026-03-17 09:14:13', 'uploads/scan_17_20260317_144413.jpg', '12-15L/day', 'ET-'),
(148, 17, 'Gir', 85.8, 13.5, 'Cow', '4.5%', '2026-03-17 09:14:16', 'uploads/scan_17_20260317_144413.jpg', '12-15L/day', NULL),
(149, 17, 'Sahiwal', 87.5, 16.5, 'Cow', '4.2%', '2026-03-17 09:37:14', 'uploads/scan_17_20260317_150712.jpg', '15-18L/day', 'ET-5357'),
(150, 17, 'Sahiwal', 87.5, 16.5, 'Cow', '4.2%', '2026-03-17 09:37:19', 'uploads/scan_17_20260317_150712.jpg', '15-18L/day', NULL),
(151, 17, 'Murrah', 96.4, 13.5, 'Buffalo', '7.5%', '2026-03-17 09:37:36', 'uploads/scan_17_20260317_150736.jpg', '12-15L/day', 'ET-'),
(152, 17, 'Sahiwal', 83.8, 16.5, 'Cow', '4.2%', '2026-03-17 09:55:52', 'uploads/scan_17_20260317_152552.jpg', '15-18L/day', 'ET-'),
(153, 17, 'Sahiwal', 83.8, 16.5, 'Cow', '4.2%', '2026-03-17 09:55:59', 'uploads/scan_17_20260317_152552.jpg', '15-18L/day', NULL),
(155, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-17 10:15:19', 'uploads/scan_17_20260317_154518.jpg', '25-30L/day', NULL),
(156, 17, 'Jaffrabadi', 91.7, 17.5, 'Buffalo', '8.5%', '2026-03-17 10:15:36', 'uploads/scan_17_20260317_154536.jpg', '15-20L/day', NULL),
(157, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-17 10:16:31', 'uploads/scan_17_20260317_154630.jpg', '1-3L/day', NULL),
(158, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-17 10:16:42', 'uploads/scan_17_20260317_154642.jpg', '10-15L/day', NULL),
(160, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-17 10:17:56', 'uploads/scan_17_20260317_154756.jpg', '25-30L/day', 'ET-'),
(162, 17, 'Sahiwal', 86.6, 16.5, 'Cow', '4.2%', '2026-03-18 03:01:20', 'uploads/scan_17_20260318_083120.jpg', '15-18L/day', NULL),
(163, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-18 03:08:47', 'uploads/scan_17_20260318_083847.jpg', '1-3L/day', 'ET-765'),
(164, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-18 03:08:51', 'uploads/scan_17_20260318_083847.jpg', '1-3L/day', NULL),
(166, 17, 'Kankrej', 82.5, 12.5, 'Cow', '4.8%', '2026-03-18 03:16:55', 'uploads/scan_17_20260318_084655.jpg', '10-15L/day', 'ET-'),
(167, 17, 'Kankrej', 82.5, 12.5, 'Cow', '4.8%', '2026-03-18 03:17:04', 'uploads/scan_17_20260318_084655.jpg', '10-15L/day', NULL),
(168, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-18 03:18:48', 'uploads/scan_17_20260318_084848.jpg', '25-30L/day', 'ET-'),
(169, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-18 03:27:21', 'uploads/scan_17_20260318_085721.jpg', '10-15L/day', 'ET-'),
(170, 17, 'Kankrej', 83.2, 12.5, 'Cow', '4.8%', '2026-03-18 03:28:23', 'uploads/scan_17_20260318_085823.jpg', '10-15L/day', 'ET-'),
(171, 17, 'Sahiwal', 83.3, 16.5, 'Cow', '4.2%', '2026-03-18 03:29:03', 'uploads/scan_17_20260318_085903.jpg', '15-18L/day', 'ET-'),
(172, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-18 03:29:42', 'uploads/scan_17_20260318_085942.jpg', '1-3L/day', 'ET-'),
(173, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-18 03:40:28', 'uploads/scan_17_20260318_091027.jpg', '25-30L/day', 'ET-'),
(174, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-18 03:40:33', 'uploads/scan_17_20260318_091027.jpg', '25-30L/day', NULL),
(175, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-18 03:41:34', 'uploads/scan_17_20260318_091134.jpg', '6-10L/day', 'ET-'),
(176, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-18 03:42:49', 'uploads/scan_17_20260318_091249.jpg', '10-15L/day', 'ET-'),
(177, 17, 'Sahiwal', 89.3, 16.5, 'Cow', '4.2%', '2026-03-18 03:44:44', 'uploads/scan_17_20260318_091444.jpg', '15-18L/day', 'ET-423'),
(178, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 03:22:05', 'uploads/scan_17_20260319_085205.jpg', '25-30L/day', 'ET-'),
(179, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-19 03:32:49', 'uploads/scan_17_20260319_090248.jpg', '6-10L/day', 'ET-'),
(180, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-19 03:32:51', 'uploads/scan_17_20260319_090248.jpg', '6-10L/day', NULL),
(181, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 03:35:47', 'uploads/scan_17_20260319_090547.jpg', '25-30L/day', 'ET-'),
(182, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 03:49:49', 'uploads/scan_17_20260319_091949.jpg', '25-30L/day', 'ET-'),
(183, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 03:50:13', 'uploads/scan_17_20260319_091949.jpg', '25-30L/day', NULL),
(184, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-19 03:50:18', 'uploads/scan_17_20260319_092018.jpg', '1-3L/day', 'ET-'),
(185, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:23:16', 'uploads/scan_17_20260319_105315.jpg', '25-30L/day', 'ET-'),
(186, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:23:24', 'uploads/scan_17_20260319_105315.jpg', '25-30L/day', NULL),
(187, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:23:54', 'uploads/scan_17_20260319_105354.jpg', '25-30L/day', 'ET-8758'),
(188, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-19 05:24:48', 'uploads/scan_17_20260319_105447.jpg', '6-10L/day', 'ET-'),
(189, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:37:03', 'uploads/scan_17_20260319_110701.jpg', '25-30L/day', 'ET-45u'),
(190, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:37:55', 'uploads/scan_17_20260319_110701.jpg', '25-30L/day', NULL),
(191, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-19 05:38:04', 'uploads/scan_17_20260319_110804.jpg', '1-3L/day', 'ET-45u'),
(192, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:39:34', 'uploads/scan_17_20260319_110934.jpg', '25-30L/day', 'ET-'),
(193, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:42:51', 'uploads/scan_17_20260319_111250.jpg', '25-30L/day', 'ET-'),
(194, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:49:22', 'uploads/scan_17_20260319_111921.jpg', '25-30L/day', 'ET-'),
(195, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-19 05:49:29', 'uploads/scan_17_20260319_111929.jpg', '1-3L/day', 'ET-'),
(196, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:52:42', 'uploads/scan_17_20260319_112241.jpg', '25-30L/day', 'ET-'),
(197, 17, 'Khillari', 86.9, 2, 'Cow', '4.2%', '2026-03-19 05:52:47', 'uploads/scan_17_20260319_112247.jpg', '1-3L/day', 'ET-'),
(198, 17, 'Kankrej', 84.5, 12.5, 'Cow', '4.8%', '2026-03-19 05:55:50', 'uploads/scan_17_20260319_112549.jpg', '10-15L/day', 'ET-'),
(199, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-19 05:55:55', 'uploads/scan_17_20260319_112555.jpg', '6-10L/day', 'ET-'),
(200, 17, 'Toda', 97.9, 8, 'Buffalo', '8.0%', '2026-03-19 05:56:14', 'uploads/scan_17_20260319_112614.jpg', '6-10L/day', 'ET-'),
(201, 17, 'Sahiwal', 88.4, 16.5, 'Cow', '4.2%', '2026-03-19 05:58:51', 'uploads/scan_17_20260319_112850.jpg', '15-18L/day', 'ET-'),
(202, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 05:58:56', 'uploads/scan_17_20260319_112856.jpg', '25-30L/day', 'ET-'),
(203, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:04:26', 'uploads/scan_17_20260319_113426.jpg', '6-10L/day', 'ET-'),
(204, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:04:30', 'uploads/scan_17_20260319_113426.jpg', '6-10L/day', NULL),
(205, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-19 06:04:43', 'uploads/scan_17_20260319_113443.jpg', '1-3L/day', 'ET-'),
(206, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-19 06:04:47', 'uploads/scan_17_20260319_113443.jpg', '1-3L/day', NULL),
(207, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:04:55', 'uploads/scan_17_20260319_113455.jpg', '25-30L/day', 'ET-'),
(208, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113950.jpg', '25-30L/day', 'ET-'),
(209, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(210, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(211, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(212, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(213, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(214, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(215, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:52', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(216, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:53', 'uploads/scan_17_20260319_113952.jpg', '25-30L/day', 'ET-'),
(217, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:53', 'uploads/scan_17_20260319_113953.jpg', '25-30L/day', 'ET-'),
(218, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:53', 'uploads/scan_17_20260319_113953.jpg', '25-30L/day', 'ET-'),
(219, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:53', 'uploads/scan_17_20260319_113953.jpg', '25-30L/day', 'ET-'),
(220, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:09:53', 'uploads/scan_17_20260319_113953.jpg', '25-30L/day', 'ET-'),
(221, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-19 06:10:07', 'uploads/scan_17_20260319_114007.jpg', '1-3L/day', 'ET-'),
(222, 17, 'Sahiwal', 87.3, 16.5, 'Cow', '4.2%', '2026-03-19 06:12:45', 'uploads/scan_17_20260319_114245.jpg', '15-18L/day', 'ET-'),
(223, 17, 'Sahiwal', 89.4, 16.5, 'Cow', '4.2%', '2026-03-19 06:12:46', 'uploads/scan_17_20260319_114245.jpg', '15-18L/day', 'ET-'),
(224, 17, 'Sahiwal', 82.7, 16.5, 'Cow', '4.2%', '2026-03-19 06:12:46', 'uploads/scan_17_20260319_114246.jpg', '15-18L/day', 'ET-'),
(225, 17, 'Sahiwal', 89, 16.5, 'Cow', '4.2%', '2026-03-19 06:12:46', 'uploads/scan_17_20260319_114246.jpg', '15-18L/day', 'ET-'),
(226, 17, 'Sahiwal', 82.8, 16.5, 'Cow', '4.2%', '2026-03-19 06:12:46', 'uploads/scan_17_20260319_114246.jpg', '15-18L/day', 'ET-'),
(227, 17, 'Gir', 82.6, 13.5, 'Cow', '4.5%', '2026-03-19 06:12:53', 'uploads/scan_17_20260319_114252.jpg', '12-15L/day', 'ET-'),
(228, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:13:06', 'uploads/scan_17_20260319_114306.jpg', '25-30L/day', 'ET-'),
(229, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-19 06:16:27', 'uploads/scan_17_20260319_114625.jpg', '1-3L/day', 'ET-'),
(230, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-19 06:16:32', 'uploads/scan_17_20260319_114625.jpg', '1-3L/day', NULL),
(231, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:17:15', 'uploads/scan_17_20260319_114715.jpg', '25-30L/day', 'ET-'),
(232, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115501.jpg', '6-10L/day', 'ET-'),
(233, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(234, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(235, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(236, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(237, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(238, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:03', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(239, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115503.jpg', '6-10L/day', 'ET-'),
(240, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(241, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(242, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(243, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(244, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(245, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(246, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(247, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(248, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(249, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(250, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:04', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(251, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:05', 'uploads/scan_17_20260319_115504.jpg', '6-10L/day', 'ET-'),
(252, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:25:05', 'uploads/scan_17_20260319_115505.jpg', '6-10L/day', 'ET-'),
(253, 17, 'Sahiwal', 86.1, 16.5, 'Cow', '4.2%', '2026-03-19 06:25:10', 'uploads/scan_17_20260319_115510.jpg', '15-18L/day', 'ET-'),
(254, 17, 'Sahiwal', 85.8, 16.5, 'Cow', '4.2%', '2026-03-19 06:25:10', 'uploads/scan_17_20260319_115510.jpg', '15-18L/day', 'ET-'),
(255, 17, 'Sahiwal', 89.2, 16.5, 'Cow', '4.2%', '2026-03-19 06:25:11', 'uploads/scan_17_20260319_115510.jpg', '15-18L/day', 'ET-'),
(256, 17, 'Sahiwal', 86.8, 16.5, 'Cow', '4.2%', '2026-03-19 06:25:25', 'uploads/scan_17_20260319_115525.jpg', '15-18L/day', 'ET-'),
(257, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:29:23', 'uploads/scan_17_20260319_115923.jpg', '25-30L/day', 'ET-'),
(258, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:38:59', 'uploads/scan_17_20260319_120857.jpg', '25-30L/day', 'ET-'),
(259, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 06:39:02', 'uploads/scan_17_20260319_120857.jpg', '25-30L/day', NULL),
(260, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 06:39:08', 'uploads/scan_17_20260319_120907.jpg', '6-10L/day', 'ET-'),
(261, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 07:02:47', 'uploads/scan_17_20260319_123245.jpg', '25-30L/day', 'ET-'),
(262, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 07:02:51', 'uploads/scan_17_20260319_123245.jpg', '25-30L/day', NULL),
(263, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 07:08:35', 'uploads/scan_17_20260319_123835.jpg', '25-30L/day', NULL),
(264, 16, 'Sahiwal', 84.2, 16.5, 'Cow', '4.2%', '2026-03-19 07:13:57', 'uploads/scan_16_20260319_124357.jpg', '15-18L/day', NULL),
(265, 16, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-19 08:09:11', 'uploads/scan_16_20260319_133910.jpg', '12-15L/day', NULL),
(266, 16, 'Gir', 83.8, 13.5, 'Cow', '4.5%', '2026-03-19 08:09:16', 'uploads/scan_16_20260319_133916.jpg', '12-15L/day', NULL),
(267, 16, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-19 08:09:23', 'uploads/scan_16_20260319_133923.jpg', '6-10L/day', NULL),
(268, 16, 'Toda', 83.7, 8, 'Buffalo', '8.0%', '2026-03-19 08:10:30', 'uploads/scan_16_20260319_134030.jpg', '6-10L/day', NULL),
(269, 16, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 08:12:14', 'uploads/scan_16_20260319_134214.jpg', '25-30L/day', NULL),
(270, 16, 'Brown Swiss', 86.3, 22.5, 'Cow', '4.0%', '2026-03-19 08:13:21', 'uploads/scan_16_20260319_134321.jpg', '20-25L/day', NULL),
(271, 16, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-19 08:14:13', 'uploads/scan_16_20260319_134413.jpg', '25-30L/day', NULL),
(272, 16, 'Sahiwal', 86.7, 16.5, 'Cow', '4.2%', '2026-03-19 08:28:58', 'uploads/scan_16_20260319_135858.jpeg', '15-18L/day', NULL),
(273, 16, 'Sahiwal', 83, 16.5, 'Cow', '4.2%', '2026-03-19 08:29:11', 'uploads/scan_16_20260319_135911.jpeg', '15-18L/day', NULL),
(274, 17, 'Kankrej', 81.9, 12.5, 'Cow', '4.8%', '2026-03-19 08:41:07', 'uploads/scan_17_20260319_141107.jpeg', '10-15L/day', NULL),
(275, 16, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-19 09:25:12', 'uploads/scan_16_20260319_145510.jpg', '12-15L/day', NULL),
(276, 16, 'Sahiwal', 83.9, 16.5, 'Cow', '4.2%', '2026-03-19 09:25:28', 'uploads/scan_16_20260319_145528.jpg', '15-18L/day', NULL),
(277, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-19 09:28:20', 'uploads/scan_17_20260319_145819.jpg', '10-15L/day', 'ET-'),
(278, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 04:55:33', 'uploads/scan_17_20260320_102533.jpg', '25-30L/day', NULL),
(279, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 04:56:15', 'uploads/scan_17_20260320_102615.jpg', '25-30L/day', 'ET-'),
(280, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 04:56:22', 'uploads/scan_17_20260320_102622.jpg', '6-10L/day', 'ET-'),
(281, 16, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 04:58:23', 'uploads/scan_16_20260320_102823.jpg', '25-30L/day', NULL),
(282, 16, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 04:59:45', 'uploads/scan_16_20260320_102945.jpg', '1-3L/day', NULL),
(283, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:04:25', 'uploads/scan_17_20260320_103425.jpg', '25-30L/day', 'ET-456876'),
(284, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:06:49', 'uploads/scan_17_20260320_103648.jpg', '25-30L/day', 'ET-'),
(285, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:06:55', 'uploads/scan_17_20260320_103648.jpg', '25-30L/day', NULL),
(286, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:07:01', 'uploads/scan_17_20260320_103700.jpg', '1-3L/day', 'ET-'),
(287, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:07:56', 'uploads/scan_17_20260320_103755.jpg', '1-3L/day', 'ET-'),
(288, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:10:26', 'uploads/scan_17_20260320_104026.jpg', '1-3L/day', 'ET-'),
(289, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:10:30', 'uploads/scan_17_20260320_104026.jpg', '1-3L/day', NULL),
(290, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 05:17:56', 'uploads/scan_17_20260320_104755.jpg', '6-10L/day', NULL),
(291, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:18:54', 'uploads/scan_17_20260320_104853.jpg', '25-30L/day', 'ET-'),
(292, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:19:00', 'uploads/scan_17_20260320_104900.jpg', '1-3L/day', 'ET-'),
(293, 17, 'Sahiwal', 87.1, 16.5, 'Cow', '4.2%', '2026-03-20 05:22:54', 'uploads/scan_17_20260320_105254.jpg', '15-18L/day', NULL),
(294, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:23:05', 'uploads/scan_17_20260320_105305.jpg', '1-3L/day', NULL),
(295, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 05:23:15', 'uploads/scan_17_20260320_105315.jpg', '10-15L/day', NULL),
(296, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 05:23:59', 'uploads/scan_17_20260320_105359.jpg', '10-15L/day', 'ET-'),
(297, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 05:24:04', 'uploads/scan_17_20260320_105404.jpg', '10-15L/day', 'ET-'),
(298, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-20 05:24:08', 'uploads/scan_17_20260320_105408.jpg', '1-3L/day', 'ET-'),
(299, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:24:12', 'uploads/scan_17_20260320_105412.jpg', '25-30L/day', 'ET-'),
(300, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-20 05:24:17', 'uploads/scan_17_20260320_105417.jpg', '12-15L/day', 'ET-'),
(301, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-20 05:30:16', 'uploads/scan_17_20260320_110016.jpg', '12-15L/day', NULL),
(302, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 05:30:54', 'uploads/scan_17_20260320_110054.jpg', '10-15L/day', 'ET-'),
(303, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 05:30:59', 'uploads/scan_17_20260320_110054.jpg', '10-15L/day', NULL),
(304, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 05:31:03', 'uploads/scan_17_20260320_110103.jpg', '25-30L/day', 'ET-'),
(305, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:12:44', 'uploads/scan_17_20260320_124244.jpg', '25-30L/day', NULL),
(306, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 07:13:44', 'uploads/scan_17_20260320_124344.jpg', '6-10L/day', 'ET-'),
(307, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 07:13:48', 'uploads/scan_17_20260320_124344.jpg', '6-10L/day', NULL),
(308, 17, 'Sahiwal', 85.5, 16.5, 'Cow', '4.2%', '2026-03-20 07:13:52', 'uploads/scan_17_20260320_124352.jpg', '15-18L/day', 'ET-'),
(309, 17, 'Sahiwal', 89.1, 16.5, 'Cow', '4.2%', '2026-03-20 07:14:02', 'uploads/scan_17_20260320_124402.jpg', '15-18L/day', 'ET-'),
(310, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-20 07:14:07', 'uploads/scan_17_20260320_124407.jpg', '12-15L/day', 'ET-'),
(311, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:14:14', 'uploads/scan_17_20260320_124414.jpg', '25-30L/day', 'ET-'),
(312, 17, 'Gir', 83.2, 13.5, 'Cow', '4.5%', '2026-03-20 07:14:32', 'uploads/scan_17_20260320_124432.jpg', '12-15L/day', 'ET-'),
(313, 17, 'Sahiwal', 84.7, 16.5, 'Cow', '4.2%', '2026-03-20 07:24:45', 'uploads/scan_17_20260320_125445.jpg', '15-18L/day', 'ET-'),
(314, 17, 'Sahiwal', 84.7, 16.5, 'Cow', '4.2%', '2026-03-20 07:24:50', 'uploads/scan_17_20260320_125445.jpg', '15-18L/day', NULL),
(315, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:25:02', 'uploads/scan_17_20260320_125501.jpg', '25-30L/day', 'ET-'),
(316, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 07:36:24', 'uploads/scan_17_20260320_130624.jpg', '10-15L/day', 'ET-'),
(317, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 07:36:33', 'uploads/scan_17_20260320_130633.jpg', '6-10L/day', 'ET-'),
(318, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:43:58', 'uploads/scan_17_20260320_131358.jpg', '25-30L/day', NULL),
(319, 17, 'Sahiwal', 83.2, 16.5, 'Cow', '4.2%', '2026-03-20 07:44:08', 'uploads/scan_17_20260320_131408.jpg', '15-18L/day', NULL),
(320, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-20 07:44:28', 'uploads/scan_17_20260320_131428.jpg', '10-15L/day', NULL),
(321, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-20 07:45:15', 'uploads/scan_17_20260320_131515.jpg', '12-15L/day', NULL),
(322, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-20 07:45:59', 'uploads/scan_17_20260320_131559.jpg', '10-15L/day', 'ET-'),
(323, 17, 'Sahiwal', 84.7, 16.5, 'Cow', '4.2%', '2026-03-20 07:46:07', 'uploads/scan_17_20260320_131607.jpg', '15-18L/day', 'ET-'),
(324, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:46:14', 'uploads/scan_17_20260320_131614.jpg', '25-30L/day', 'ET-'),
(325, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-20 07:46:25', 'uploads/scan_17_20260320_131625.jpg', '12-15L/day', 'ET-'),
(326, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:59:35', 'uploads/scan_17_20260320_132935.jpg', '25-30L/day', 'ET-'),
(327, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-20 07:59:39', 'uploads/scan_17_20260320_132935.jpg', '25-30L/day', NULL),
(328, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 08:00:20', 'uploads/scan_17_20260320_133019.jpg', '6-10L/day', 'ET-'),
(329, 25, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-20 09:06:25', 'uploads/scan_25_20260320_143625.jpg', '6-10L/day', NULL),
(330, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-23 03:20:06', 'uploads/scan_17_20260323_085005.jpg', '25-30L/day', 'ET-'),
(331, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-23 03:20:10', 'uploads/scan_17_20260323_085005.jpg', '25-30L/day', NULL),
(332, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-23 03:20:14', 'uploads/scan_17_20260323_085013.jpg', '10-15L/day', 'ET-'),
(333, 16, 'Sahiwal', 85.9, 16.5, 'Cow', '4.2%', '2026-03-23 04:17:18', 'uploads/scan_16_20260323_094717.jpeg', '15-18L/day', NULL),
(334, 16, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-23 06:38:42', 'uploads/scan_16_20260323_120842.jpg', '10-15L/day', NULL),
(335, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-23 06:42:52', 'uploads/scan_17_20260323_121252.jpg', '1-3L/day', 'ET-974563'),
(336, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-23 06:42:59', 'uploads/scan_17_20260323_121252.jpg', '1-3L/day', NULL),
(337, 17, 'Sahiwal', 84, 16.5, 'Cow', '4.2%', '2026-03-24 06:55:16', 'uploads/scan_17_20260324_122514.jpg', '15-18L/day', 'ET-'),
(338, 17, 'Sahiwal', 84, 16.5, 'Cow', '4.2%', '2026-03-24 06:55:21', 'uploads/scan_17_20260324_122514.jpg', '15-18L/day', NULL),
(339, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-24 06:55:34', 'uploads/scan_17_20260324_122534.jpg', '1-3L/day', 'ET-'),
(340, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-24 06:57:54', 'uploads/scan_17_20260324_122754.jpg', '25-30L/day', 'ET-'),
(341, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-24 06:57:54', 'uploads/scan_17_20260324_122754.jpg', '6-10L/day', 'ET-'),
(342, 17, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-24 06:58:03', 'uploads/scan_17_20260324_122754.jpg', '6-10L/day', NULL),
(343, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-24 06:58:13', 'uploads/scan_17_20260324_122813.jpg', '10-15L/day', 'ET-'),
(344, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-24 06:58:18', 'uploads/scan_17_20260324_122818.jpg', '10-15L/day', 'ET-'),
(345, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-24 06:58:30', 'uploads/scan_17_20260324_122830.jpg', '25-30L/day', 'ET-'),
(346, 17, 'Sahiwal', 83.2, 16.5, 'Cow', '4.2%', '2026-03-24 06:59:01', 'uploads/scan_17_20260324_122901.jpg', '15-18L/day', 'ET-'),
(347, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 07:00:01', 'uploads/scan_17_20260324_123001.jpg', '12-15L/day', 'ET-'),
(348, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 07:09:37', 'uploads/scan_17_20260324_123937.jpg', '12-15L/day', 'ET-'),
(349, 16, 'Sahiwal', 82.9, 16.5, 'Cow', '4.2%', '2026-03-24 07:26:03', 'uploads/scan_16_20260324_125602.jpg', '15-18L/day', NULL),
(350, 17, 'Sahiwal', 84, 16.5, 'Cow', '4.2%', '2026-03-24 07:37:41', 'uploads/scan_17_20260324_130741.jpg', '15-18L/day', 'ET-'),
(351, 16, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 08:46:29', 'uploads/scan_16_20260324_141628.jpg', '12-15L/day', NULL),
(352, 16, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 08:49:20', 'uploads/scan_16_20260324_141919.jpg', '12-15L/day', NULL),
(353, 16, 'Gir', 82.4, 13.5, 'Cow', '4.5%', '2026-03-24 08:50:07', 'uploads/scan_16_20260324_142007.jpg', '12-15L/day', NULL),
(354, 16, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 09:11:56', 'uploads/scan_16_20260324_144155.jpg', '12-15L/day', NULL),
(355, 17, 'Gir', 89.5, 13.5, 'Cow', '4.5%', '2026-03-24 09:13:51', 'uploads/scan_17_20260324_144351.jpg', '12-15L/day', 'ET-'),
(356, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-24 09:14:09', 'uploads/scan_17_20260324_144409.jpg', '12-15L/day', 'ET-'),
(357, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-24 09:14:13', 'uploads/scan_17_20260324_144413.jpg', '10-15L/day', 'ET-'),
(358, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-24 09:14:17', 'uploads/scan_17_20260324_144417.jpg', '1-3L/day', 'ET-'),
(359, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-25 02:49:43', 'uploads/scan_17_20260325_081942.jpg', '1-3L/day', NULL),
(360, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-25 02:53:26', 'uploads/scan_17_20260325_082326.jpg', '12-15L/day', 'ET-7646'),
(361, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-25 02:53:33', 'uploads/scan_17_20260325_082326.jpg', '12-15L/day', NULL),
(362, 17, 'Gir', 88.8, 13.5, 'Cow', '4.5%', '2026-03-25 02:55:09', 'uploads/scan_17_20260325_082509.jpg', '12-15L/day', 'ET-7646'),
(363, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-25 02:56:19', 'uploads/scan_17_20260325_082619.jpg', '10-15L/day', 'ET-3454'),
(364, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-25 03:02:04', 'uploads/scan_17_20260325_083204.jpg', '10-15L/day', 'ET-'),
(365, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-25 03:17:48', 'uploads/scan_17_20260325_084748.jpg', '1-3L/day', 'ET-'),
(366, 17, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-25 03:17:53', 'uploads/scan_17_20260325_084748.jpg', '1-3L/day', NULL),
(367, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-25 03:18:25', 'uploads/scan_17_20260325_084825.jpg', '12-15L/day', 'ET-'),
(368, 16, 'Sahiwal', 83.9, 16.5, 'Cow', '4.2%', '2026-03-25 03:19:33', 'uploads/scan_16_20260325_084933.jpg', '15-18L/day', NULL),
(369, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-25 04:16:07', 'uploads/scan_17_20260325_094606.jpg', '10-15L/day', 'ET-'),
(370, 17, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-25 04:16:33', 'uploads/scan_17_20260325_094606.jpg', '10-15L/day', NULL),
(371, 17, 'Kankrej', 100, 12.5, 'Cow', '4.8%', '2026-03-25 04:24:47', 'uploads/scan_17_20260325_095447.jpg', '10-15L/day', NULL),
(372, 17, 'Gir', 87.2, 13.5, 'Cow', '4.5%', '2026-03-25 04:25:02', 'uploads/scan_17_20260325_095502.jpg', '12-15L/day', NULL),
(373, 17, 'Sahiwal', 84.4, 16.5, 'Cow', '4.2%', '2026-03-25 04:25:51', 'uploads/scan_17_20260325_095551.jpg', '15-18L/day', 'ET-'),
(374, 17, 'Sahiwal', 84.4, 16.5, 'Cow', '4.2%', '2026-03-25 04:26:16', 'uploads/scan_17_20260325_095551.jpg', '15-18L/day', NULL),
(375, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-25 04:26:21', 'uploads/scan_17_20260325_095621.jpg', '12-15L/day', 'ET-'),
(376, 17, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-03-25 04:26:43', 'uploads/scan_17_20260325_095621.jpg', '12-15L/day', NULL),
(377, 16, 'Sahiwal', 85.5, 16.5, 'Cow', '4.2%', '2026-03-25 04:28:10', 'uploads/scan_16_20260325_095810.jpg', '15-18L/day', NULL),
(378, 16, 'Sahiwal', 84.5, 16.5, 'Cow', '4.2%', '2026-03-25 04:32:43', 'uploads/scan_16_20260325_100242.jpg', '15-18L/day', NULL),
(379, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-25 04:34:08', 'uploads/scan_17_20260325_100408.jpg', '25-30L/day', 'ET-'),
(380, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-25 04:35:00', 'uploads/scan_17_20260325_100408.jpg', '25-30L/day', NULL),
(381, 26, 'Sahiwal', 89.3, 16.5, 'Cow', '4.2%', '2026-03-25 04:42:21', 'uploads/scan_26_20260325_101221.jpeg', '15-18L/day', NULL),
(382, 26, 'Kankrej', 81.9, 12.5, 'Cow', '4.8%', '2026-03-26 04:14:54', 'uploads/scan_26_20260326_094454.jpeg', '10-15L/day', NULL),
(383, 16, 'Toda', 84.6, 8, 'Buffalo', '8.0%', '2026-03-26 04:19:55', 'uploads/scan_16_20260326_094955.jpg', '6-10L/day', NULL),
(384, 16, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 04:20:34', 'uploads/scan_16_20260326_095034.jpg', '3-5L/day', NULL),
(385, 17, 'Toda', 86.2, 8, 'Buffalo', '8.0%', '2026-03-26 04:22:22', 'uploads/scan_17_20260326_095221.jpg', '6-10L/day', 'ET-'),
(386, 17, 'Toda', 86.2, 8, 'Buffalo', '8.0%', '2026-03-26 04:22:42', 'uploads/scan_17_20260326_095221.jpg', '6-10L/day', NULL),
(387, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 04:22:47', 'uploads/scan_17_20260326_095247.jpg', '3-5L/day', 'ET-'),
(388, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 04:23:07', 'uploads/scan_17_20260326_095247.jpg', '3-5L/day', NULL),
(389, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 04:30:37', 'uploads/scan_17_20260326_100037.jpg', '3-5L/day', 'ET-'),
(390, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 04:31:00', 'uploads/scan_17_20260326_100037.jpg', '3-5L/day', NULL),
(391, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-26 04:31:07', 'uploads/scan_17_20260326_100107.jpg', '25-30L/day', 'ET-'),
(392, 17, 'Holstein Friesian', 100, 27.5, 'Cow', '3.5%', '2026-03-26 04:31:26', 'uploads/scan_17_20260326_100107.jpg', '25-30L/day', NULL),
(393, 26, 'Kankrej', 81.9, 12.5, 'Cow', '4.8%', '2026-03-26 04:53:54', 'uploads/scan_26_20260326_102353.jpeg', '10-15L/day', NULL),
(394, 26, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 05:22:04', 'uploads/scan_26_20260326_105204.jpg', '3-5L/day', NULL),
(395, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-26 05:33:02', 'uploads/scan_17_20260326_110301.jpg', '3-5L/day', NULL),
(396, 16, 'Kankrej', 85.7, 12.5, 'Cow', '4.8%', '2026-03-26 08:24:40', 'uploads/scan_16_20260326_135439.jpg', '10-15L/day', NULL),
(397, 16, 'Kankrej', 86.9, 12.5, 'Cow', '4.8%', '2026-03-26 08:25:06', 'uploads/scan_16_20260326_135506.jpg', '10-15L/day', NULL),
(398, 16, 'Deoni', 84.9, 4, 'Cow', '4.3%', '2026-03-26 08:25:33', 'uploads/scan_16_20260326_135532.jpg', '3-5L/day', NULL),
(399, 16, 'Khillari', 100, 2, 'Cow', '4.2%', '2026-03-26 08:40:37', 'uploads/scan_16_20260326_141037.jpg', '1-3L/day', NULL),
(400, 17, 'Kankrej', 81.9, 12.5, 'Cow', '4.8%', '2026-03-26 09:25:30', 'uploads/scan_17_20260326_145529.jpeg', '10-15L/day', NULL),
(401, 16, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-27 04:15:50', 'uploads/scan_16_20260327_094549.jpg', '3-5L/day', NULL),
(402, 17, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-28 04:33:08', 'uploads/scan_17_20260328_100307.jpg', '3-5L/day', NULL),
(403, 28, 'Murrah', 96.2, 13.5, 'Buffalo', '7.5%', '2026-03-30 07:30:40', 'uploads/scan_28_20260330_130039.jpg', '12-15L/day', NULL),
(404, 28, 'Toda', 100, 8, 'Buffalo', '8.0%', '2026-03-30 07:32:42', 'uploads/scan_28_20260330_130242.jpg', '6-10L/day', NULL),
(405, 28, 'Toda', 84.9, 8, 'Buffalo', '8.0%', '2026-03-30 07:47:16', 'uploads/scan_28_20260330_131714.jpg', '6-10L/day', NULL),
(406, 28, 'Sahiwal', 88.2, 16.5, 'Cow', '4.2%', '2026-03-30 08:01:12', 'uploads/scan_28_20260330_133111.jpg', '15-18L/day', NULL),
(407, 28, 'Toda', 99.1, 8, 'Buffalo', '8.0%', '2026-03-30 08:01:51', 'uploads/scan_28_20260330_133151.jpg', '6-10L/day', NULL),
(408, 28, 'Toda', 97.6, 8, 'Buffalo', '8.0%', '2026-03-30 08:11:13', 'uploads/scan_28_20260330_134113.jpg', '6-10L/day', NULL),
(409, 28, 'Murrah', 96.2, 13.5, 'Buffalo', '7.5%', '2026-03-30 08:11:49', 'uploads/scan_28_20260330_134149.jpg', '12-15L/day', NULL),
(410, 16, 'Toda', 99.1, 8, 'Buffalo', '8.0%', '2026-03-30 08:16:24', 'uploads/scan_16_20260330_134624.jpg', '6-10L/day', NULL),
(411, 16, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-03-30 08:29:22', 'uploads/scan_16_20260330_135922.jpg', '1-3L/day', NULL),
(412, 16, 'Toda', 85, 8, 'Buffalo', '8.0%', '2026-03-30 08:33:25', 'uploads/scan_16_20260330_140324.jpg', '6-10L/day', NULL),
(413, 16, 'Deoni', 100, 4, 'Cow', '4.3%', '2026-03-30 09:08:28', 'uploads/scan_16_20260330_143826.jpg', '3-5L/day', NULL),
(414, 16, 'Khillari', 100, 2, 'Cow', '4.2%', '2026-03-30 09:09:37', 'uploads/scan_16_20260330_143937.jpg', '1-3L/day', NULL),
(415, 16, 'Kankrej', 82.1, 12.5, 'Cow', '4.8%', '2026-03-30 09:16:08', 'uploads/scan_16_20260330_144608.jpg', '10-15L/day', NULL),
(416, 16, 'Khillari', 100, 2, 'Cow', '4.2%', '2026-03-30 09:25:14', 'uploads/scan_16_20260330_145513.jpg', '1-3L/day', NULL),
(417, 16, 'Toda', 100, 8, 'Buffalo', '8.0%', '2026-03-30 10:43:24', 'uploads/scan_16_20260330_161323.jpg', '6-10L/day', NULL),
(418, 16, 'Toda', 87.3, 8, 'Buffalo', '8.0%', '2026-04-01 04:37:47', 'uploads/scan_16_20260401_100747.jpg', '6-10L/day', NULL),
(419, 29, 'Toda', 86.2, 8, 'Buffalo', '8.0%', '2026-04-01 04:53:49', 'uploads/scan_29_20260401_102349.jpg', '6-10L/day', NULL),
(420, 29, 'Murrah', 95.7, 13.5, 'Buffalo', '7.5%', '2026-04-01 05:04:04', 'uploads/scan_29_20260401_103404.jpg', '12-15L/day', NULL),
(421, 29, 'Khillari', 84.1, 2, 'Cow', '4.2%', '2026-04-01 05:08:25', 'uploads/scan_29_20260401_103825.jpg', '1-3L/day', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `disease_alerts`
--

CREATE TABLE `disease_alerts` (
  `id` int(11) NOT NULL,
  `disease_name` varchar(255) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `location` varchar(255) NOT NULL,
  `severity` varchar(50) NOT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `disease_alerts`
--

INSERT INTO `disease_alerts` (`id`, `disease_name`, `message`, `location`, `severity`, `created_at`) VALUES
(1, 'Foot and Mouth Disease', 'FMD outbreak detected nearby. Vaccinate cattle immediately.', 'Chennai', 'High', NULL),
(2, 'Lumpy Skin Disease', 'Cases reported in your district. Monitor livestock for skin nodules.', 'Hyderabad', 'Medium', NULL),
(3, 'Vaccination Drive', 'BPA conducting free FMD vaccination drive at your nearest center tomorrow.', 'Karnal', 'Medium', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `milk_yields`
--

CREATE TABLE `milk_yields` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `animal_id` int(11) DEFAULT NULL,
  `yield_amount` float NOT NULL,
  `fat_content` float DEFAULT NULL,
  `recorded_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `created_at`) VALUES
(4, 16, 'Vaccination Scheduled', 'A new vaccination for \'FMD\' has been scheduled for 2026-03-21.', 'success', 1, '2026-03-16 05:11:20'),
(10, 16, 'Vaccination Scheduled', 'A new vaccination for \'LSD\' has been scheduled for 2026-03-26.', 'success', 1, '2026-03-16 08:02:02'),
(11, 17, 'Vaccination Scheduled', 'A new vaccination for \'Lmd\' has been scheduled for 2026-03-27.', 'success', 1, '2026-03-18 03:06:24'),
(12, 16, 'Vaccination Scheduled', 'A new vaccination for \'FMD\' has been scheduled for 2026-03-24.', 'success', 1, '2026-03-20 05:01:27'),
(13, 16, 'Vaccination Scheduled', 'A new vaccination for \'LMD\' has been scheduled for 2026-03-12.', 'success', 1, '2026-03-23 06:40:10'),
(14, 16, 'Vaccination Scheduled', 'A new vaccination for \'Lmd\' has been scheduled for 2026-03-20.', 'success', 1, '2026-03-24 07:40:06'),
(15, 26, 'Vaccination Scheduled', 'A new vaccination for \'lsd\' has been scheduled for 2026-05-15.', 'success', 1, '2026-03-26 05:16:03'),
(16, 16, 'Vaccination Scheduled', 'A new vaccination for \'LSD\' has been scheduled for 2026-03-15.', 'success', 1, '2026-03-27 04:14:07'),
(17, 16, 'Vaccination Scheduled', 'A new vaccination for \'fcfh\' has been scheduled for 2026-03-28.', 'success', 1, '2026-03-28 03:34:27'),
(18, 16, 'Vaccination Scheduled', 'A new vaccination for \'FMD\' has been scheduled for 2026-03-30.', 'success', 0, '2026-03-30 02:53:22'),
(19, 28, 'Vaccination Scheduled', 'A new vaccination for \'132456789\' has been scheduled for 2664-07-01.', 'success', 0, '2026-03-30 08:07:16'),
(20, 16, 'Vaccination Scheduled', 'A new vaccination for \'LMD\' has been scheduled for 1991-06-12.', 'success', 0, '2026-03-30 08:42:26'),
(21, 16, 'Vaccination Scheduled', 'A new vaccination for \'FMD\' has been scheduled for 2026-04-22.', 'success', 0, '2026-03-30 09:35:34'),
(22, 29, 'Vaccination Scheduled', 'A new vaccination for \'FMD\' has been scheduled for 2026-04-01.', 'success', 0, '2026-04-01 05:11:03');

-- --------------------------------------------------------

--
-- Table structure for table `registered_animals`
--

CREATE TABLE `registered_animals` (
  `id` int(11) NOT NULL,
  `bpa_id` int(11) NOT NULL,
  `animal_name` varchar(100) DEFAULT NULL,
  `ear_tag_number` varchar(50) NOT NULL,
  `species` varchar(50) NOT NULL,
  `sex` varchar(20) NOT NULL,
  `breed` varchar(100) NOT NULL,
  `dob` varchar(20) DEFAULT NULL,
  `owner_name` varchar(100) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `village` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `registered_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registered_animals`
--

INSERT INTO `registered_animals` (`id`, `bpa_id`, `animal_name`, `ear_tag_number`, `species`, `sex`, `breed`, `dob`, `owner_name`, `address`, `village`, `district`, `state`, `registered_at`) VALUES
(9, 17, NULL, 'ET-7564', 'Cattle', 'Female', 'Sahiwal', '01/09/2024', 'Chai', 'Calvin', 'Karunasagara', 'Jabalpur', 'Madhya Pradesh', '2026-03-17 09:56:41'),
(10, 17, 'Jamali', 'ET-765', 'Cattle', 'Male', 'Khillari', '05/09/2024', 'Gaya I', 'Nakkapalem', 'Najur', 'Guntur', 'Andhra Pradesh', '2026-03-18 03:13:26'),
(11, 17, 'Karachi', 'ET-986', 'Cattle', 'Female', 'Kankrej', '01/09/2024', 'Gunslinger', 'Iuuksx', 'Biajn', 'Faridabad', 'Haryana', '2026-03-18 03:18:37'),
(12, 17, 'Hotly', 'ET-654', 'Cattle', 'Female', 'Holstein Friesian', '03/09/2024', 'Happy re', 'Himalaya', 'Hafuxi', 'Dharamshala', 'Himachal Pradesh', '2026-03-18 03:41:24'),
(13, 17, 'Udal', 'ET-758', 'Buffalo', 'Female', 'Toda', '19/08/2023', 'Jamal Ramesh', 'Highflying', 'Hsvfhkvhu', 'Jamshedpur', 'Jharkhand', '2026-03-19 03:33:38'),
(14, 17, 'Jkgov;fig', 'ET-4u6', 'Cattle', 'Female', 'Kohli to', '01/09/2024', 'Gho', 'Rgfbed', 'Gb', 'Mangaluru', 'Karnataka', '2026-03-19 06:17:09'),
(15, 17, NULL, 'ET-', '', '', '', NULL, '', NULL, '', '', '', '2026-03-19 07:03:46'),
(16, 17, NULL, 'ET-88795', 'Cattle', 'Female', 'Hoary', '01/09/2024', 'Whbfjkiwpe', 'We’d ', 'We’d d', 'Dhanbad', 'Jharkhand', '2026-03-20 08:00:13'),
(17, 17, 'Saraa', 'ET-974563', 'Cattle', 'Female', 'Khillari', '02/09/2024', 'Suresh', 'Exchange', 'Gerthtrth', 'Guntur', 'Andhra Pradesh', '2026-03-23 06:43:31');

-- --------------------------------------------------------

--
-- Table structure for table `timetable_tasks`
--

CREATE TABLE `timetable_tasks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `is_completed` tinyint(1) DEFAULT NULL,
  `scheduled_for` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timetable_tasks`
--

INSERT INTO `timetable_tasks` (`id`, `user_id`, `day_number`, `title`, `description`, `is_completed`, `scheduled_for`) VALUES
(274, 16, 1, 'Breed Selection Check', 'Review the best breeds for your local climate and water availability.', 0, '2026-03-28 03:47:31'),
(275, 16, 2, 'Feed Optimization', 'Balance the ratio of green fodder and dry fodder based on animal weight.', 0, '2026-03-29 03:47:31'),
(276, 16, 3, 'Watering Routine', 'Ensure animals have access to clean, mineral-rich water at least 3 times a day.', 0, '2026-03-30 03:47:31'),
(277, 16, 4, 'Health Inspection', 'Check eyes, muzzle, and coat for any signs of early infection or pests.', 0, '2026-03-31 03:47:31'),
(278, 16, 5, 'Shed Sanitation', 'Thoroughly clean the shed floor and ensure proper ventilation.', 0, '2026-04-01 03:47:31'),
(279, 16, 6, 'Routine Maintenance Day 6', 'Continue standard care procedures and record daily yield.', 0, '2026-04-02 03:47:31'),
(280, 16, 7, 'Routine Maintenance Day 7', 'Continue standard care procedures and record daily yield.', 0, '2026-04-03 03:47:31'),
(281, 16, 8, 'Routine Maintenance Day 8', 'Continue standard care procedures and record daily yield.', 0, '2026-04-04 03:47:31'),
(282, 16, 9, 'Routine Maintenance Day 9', 'Continue standard care procedures and record daily yield.', 0, '2026-04-05 03:47:31'),
(283, 16, 10, 'Routine Maintenance Day 10', 'Continue standard care procedures and record daily yield.', 0, '2026-04-06 03:47:31'),
(284, 16, 11, 'Routine Maintenance Day 11', 'Continue standard care procedures and record daily yield.', 0, '2026-04-07 03:47:31'),
(285, 16, 12, 'Routine Maintenance Day 12', 'Continue standard care procedures and record daily yield.', 0, '2026-04-08 03:47:31'),
(286, 16, 13, 'Routine Maintenance Day 13', 'Continue standard care procedures and record daily yield.', 0, '2026-04-09 03:47:31'),
(287, 16, 14, 'Routine Maintenance Day 14', 'Continue standard care procedures and record daily yield.', 0, '2026-04-10 03:47:31'),
(288, 16, 15, 'Routine Maintenance Day 15', 'Continue standard care procedures and record daily yield.', 0, '2026-04-11 03:47:31'),
(289, 16, 16, 'Routine Maintenance Day 16', 'Continue standard care procedures and record daily yield.', 0, '2026-04-12 03:47:31'),
(290, 16, 17, 'Routine Maintenance Day 17', 'Continue standard care procedures and record daily yield.', 0, '2026-04-13 03:47:31'),
(291, 16, 18, 'Routine Maintenance Day 18', 'Continue standard care procedures and record daily yield.', 0, '2026-04-14 03:47:31'),
(292, 16, 19, 'Routine Maintenance Day 19', 'Continue standard care procedures and record daily yield.', 0, '2026-04-15 03:47:31'),
(293, 16, 20, 'Routine Maintenance Day 20', 'Continue standard care procedures and record daily yield.', 0, '2026-04-16 03:47:31'),
(294, 16, 21, 'Routine Maintenance Day 21', 'Continue standard care procedures and record daily yield.', 0, '2026-04-17 03:47:31'),
(295, 17, 1, 'Breed Selection Check', 'Review the best breeds for your local climate and water availability.', 0, '2026-03-28 04:34:49'),
(296, 17, 2, 'Feed Optimization', 'Balance the ratio of green fodder and dry fodder based on animal weight.', 0, '2026-03-29 04:34:49'),
(297, 17, 3, 'Watering Routine', 'Ensure animals have access to clean, mineral-rich water at least 3 times a day.', 0, '2026-03-30 04:34:49'),
(298, 17, 4, 'Health Inspection', 'Check eyes, muzzle, and coat for any signs of early infection or pests.', 0, '2026-03-31 04:34:49'),
(299, 17, 5, 'Shed Sanitation', 'Thoroughly clean the shed floor and ensure proper ventilation.', 0, '2026-04-01 04:34:49'),
(300, 17, 6, 'Routine Maintenance Day 6', 'Continue standard care procedures and record daily yield.', 0, '2026-04-02 04:34:49'),
(301, 17, 7, 'Routine Maintenance Day 7', 'Continue standard care procedures and record daily yield.', 0, '2026-04-03 04:34:49'),
(302, 17, 8, 'Routine Maintenance Day 8', 'Continue standard care procedures and record daily yield.', 0, '2026-04-04 04:34:49'),
(303, 17, 9, 'Routine Maintenance Day 9', 'Continue standard care procedures and record daily yield.', 0, '2026-04-05 04:34:49'),
(304, 17, 10, 'Routine Maintenance Day 10', 'Continue standard care procedures and record daily yield.', 0, '2026-04-06 04:34:49'),
(305, 17, 11, 'Routine Maintenance Day 11', 'Continue standard care procedures and record daily yield.', 0, '2026-04-07 04:34:49'),
(306, 17, 12, 'Routine Maintenance Day 12', 'Continue standard care procedures and record daily yield.', 0, '2026-04-08 04:34:49'),
(307, 17, 13, 'Routine Maintenance Day 13', 'Continue standard care procedures and record daily yield.', 0, '2026-04-09 04:34:49'),
(308, 17, 14, 'Routine Maintenance Day 14', 'Continue standard care procedures and record daily yield.', 0, '2026-04-10 04:34:49'),
(309, 17, 15, 'Routine Maintenance Day 15', 'Continue standard care procedures and record daily yield.', 0, '2026-04-11 04:34:49'),
(310, 17, 16, 'Routine Maintenance Day 16', 'Continue standard care procedures and record daily yield.', 0, '2026-04-12 04:34:49'),
(311, 17, 17, 'Routine Maintenance Day 17', 'Continue standard care procedures and record daily yield.', 0, '2026-04-13 04:34:49'),
(312, 17, 18, 'Routine Maintenance Day 18', 'Continue standard care procedures and record daily yield.', 0, '2026-04-14 04:34:49'),
(313, 17, 19, 'Routine Maintenance Day 19', 'Continue standard care procedures and record daily yield.', 0, '2026-04-15 04:34:49'),
(314, 17, 20, 'Routine Maintenance Day 20', 'Continue standard care procedures and record daily yield.', 0, '2026-04-16 04:34:49'),
(315, 17, 21, 'Routine Maintenance Day 21', 'Continue standard care procedures and record daily yield.', 0, '2026-04-17 04:34:49');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT NULL,
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_created_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `profile_photo` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `full_name`, `phone_number`, `is_verified`, `otp_code`, `otp_created_at`, `created_at`, `profile_photo`) VALUES
(16, 'vinaykumarreddyramala892@gmail.com', '$2b$12$FY7AjCfKTRfOuJKLl0kO/.d9OIlPLjEmmcNDAI.IEDIcZmFZOzVde', 'farmer', 'Vinay kumar', '9100260333', 1, NULL, NULL, '2026-03-16 05:05:18', 'uploads/profiles/user_16.jpeg'),
(17, 'vinaykumarreddyramala197@gmail.com', '$2b$12$w4NSDJwGc0K3mSN18FyLfuXNFYVbsSqCw0AtH8Gl/Hc2yshdgp.YK', 'bpa', 'Vinay', NULL, 1, NULL, NULL, '2026-03-17 08:50:03', 'uploads/profiles/user_17.jpeg'),
(23, 'balajireddybb135@gmail.com', '$2b$12$M515LZD/bfxDzBpypRrW1OEC9dex7o82WKKGd2mzP9/H.BuSTasIK', 'farmer', 'Balaji', NULL, 1, NULL, NULL, '2026-03-20 08:21:48', 'uploads/profiles/user_23.jpg'),
(24, 'ravi@gmail.com', '$2b$12$PuLxlfQu6OJBqgft57wTGuSi7qhj9i5coCkMZz..Ax8faLpwISRLq', 'farmer', 'ergfngfhj', NULL, 0, '686438', '2026-03-20 08:30:22', '2026-03-20 08:30:22', NULL),
(25, 'ravitejareddy1866@gmail.com', '$2b$12$qxuof.XMh5EtcKQetKusbOzbC9kxVHuSxHS7R.70iw.lIYkikCvXu', 'farmer', 'ravitejareddy', NULL, 1, NULL, NULL, '2026-03-20 08:42:57', 'uploads/profiles/user_25.jpg'),
(26, 'shunushunu91@gmail.com', '$2b$12$EYgm6puqvqbys.N0QJT1MuDukuN1oOASQmq6xCplM/I9TjkhJzQua', 'farmer', 'vinay', '9102609876', 1, NULL, NULL, '2026-03-25 04:38:34', 'uploads/profiles/user_26.jpeg'),
(28, 'y.0a@gmail.com', '$2b$12$oY5m7Mcs9ta2q8U6FMhFDejRHoqalVW4wFthErOxbksenP4Dn/gjO', 'farmer', '7410', NULL, 1, NULL, NULL, '2026-03-30 07:25:01', NULL),
(29, 'lokeshkumar142005@gmail.com', '$2b$12$qsfZhV1kPBg7A52rfv3dNOqaCubWbGdlg.w5Fjqzr/2cd6FzTRCea', 'farmer', 'Lokesh', '8825489412', 1, NULL, NULL, '2026-04-01 04:49:20', 'uploads/profiles/user_29.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `vaccination_schedules`
--

CREATE TABLE `vaccination_schedules` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `animal_id` int(11) DEFAULT NULL,
  `vaccine_name` varchar(255) NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `planned_date` datetime NOT NULL,
  `completion_date` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vaccination_schedules`
--

INSERT INTO `vaccination_schedules` (`id`, `user_id`, `animal_id`, `vaccine_name`, `type`, `planned_date`, `completion_date`, `status`) VALUES
(14, 16, NULL, 'FMD', 'Monthly', '2026-03-21 05:11:00', '2026-03-17 04:34:48', 'completed'),
(21, 17, NULL, 'Lmd', 'Monthly', '2026-03-27 03:06:00', NULL, 'scheduled'),
(24, 16, NULL, 'Lmd', 'Monthly', '2026-03-20 07:39:00', '2026-03-27 02:59:35', 'completed'),
(25, 26, NULL, 'lsd', 'Routine', '2026-05-15 00:00:00', '2026-03-26 05:16:10', 'completed'),
(26, 16, NULL, 'LSD', 'Monthly', '2026-03-15 04:13:00', '2026-03-27 07:26:03', 'completed'),
(28, 16, NULL, 'FMD', 'Bi-annual', '2026-03-30 02:53:13', '2026-03-30 02:53:36', 'completed'),
(29, 28, NULL, '132456789', 'One-time', '2664-07-01 08:06:00', NULL, 'scheduled'),
(30, 16, NULL, 'LMD', 'Monthly', '1991-06-12 08:41:00', '2026-03-30 09:12:02', 'completed'),
(31, 16, NULL, 'FMD', 'Monthly', '2026-04-22 09:35:00', NULL, 'scheduled'),
(32, 29, NULL, 'FMD', 'Annual', '2026-04-01 05:10:48', '2026-04-01 05:11:06', 'completed');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `animal_detections`
--
ALTER TABLE `animal_detections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `ix_animal_detections_id` (`id`),
  ADD KEY `ix_animal_detections_breed_name` (`breed_name`),
  ADD KEY `ix_animal_detections_detected_at` (`detected_at`),
  ADD KEY `ix_animal_detections_animal_ear_tag` (`animal_ear_tag`);

--
-- Indexes for table `disease_alerts`
--
ALTER TABLE `disease_alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ix_disease_alerts_id` (`id`);

--
-- Indexes for table `milk_yields`
--
ALTER TABLE `milk_yields`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `animal_id` (`animal_id`),
  ADD KEY `ix_milk_yields_id` (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `ix_notifications_id` (`id`);

--
-- Indexes for table `registered_animals`
--
ALTER TABLE `registered_animals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ix_registered_animals_ear_tag_number` (`ear_tag_number`),
  ADD KEY `bpa_id` (`bpa_id`),
  ADD KEY `ix_registered_animals_id` (`id`);

--
-- Indexes for table `timetable_tasks`
--
ALTER TABLE `timetable_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `ix_timetable_tasks_id` (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ix_users_email` (`email`),
  ADD KEY `ix_users_id` (`id`);

--
-- Indexes for table `vaccination_schedules`
--
ALTER TABLE `vaccination_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `animal_id` (`animal_id`),
  ADD KEY `ix_vaccination_schedules_id` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `animal_detections`
--
ALTER TABLE `animal_detections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=422;

--
-- AUTO_INCREMENT for table `disease_alerts`
--
ALTER TABLE `disease_alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `milk_yields`
--
ALTER TABLE `milk_yields`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `registered_animals`
--
ALTER TABLE `registered_animals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `timetable_tasks`
--
ALTER TABLE `timetable_tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=316;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `vaccination_schedules`
--
ALTER TABLE `vaccination_schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `animal_detections`
--
ALTER TABLE `animal_detections`
  ADD CONSTRAINT `animal_detections_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `milk_yields`
--
ALTER TABLE `milk_yields`
  ADD CONSTRAINT `milk_yields_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `milk_yields_ibfk_2` FOREIGN KEY (`animal_id`) REFERENCES `registered_animals` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `registered_animals`
--
ALTER TABLE `registered_animals`
  ADD CONSTRAINT `registered_animals_ibfk_1` FOREIGN KEY (`bpa_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `timetable_tasks`
--
ALTER TABLE `timetable_tasks`
  ADD CONSTRAINT `timetable_tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vaccination_schedules`
--
ALTER TABLE `vaccination_schedules`
  ADD CONSTRAINT `vaccination_schedules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vaccination_schedules_ibfk_2` FOREIGN KEY (`animal_id`) REFERENCES `registered_animals` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
