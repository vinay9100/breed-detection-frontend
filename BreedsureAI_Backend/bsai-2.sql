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
(17, 'vinaykumarreddyramala197@gmail.com', '$2b$12$w4NSDJwGc0K3mSN18FyLfuXNFYVbsSqCw0AtH8Gl/Hc2yshdgp.YK', 'bpa', 'Vinay', NULL, 1, NULL, NULL, '2026-03-17 08:50:03', 'uploads/profiles/user_17.jpeg');

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
