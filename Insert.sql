CREATE TABLE IF NOT EXISTS `ricky_report` (
  `id` int(11) NOT NULL DEFAULT 0,
  `identifier` longtext DEFAULT NULL,
  `reportInfo` longtext DEFAULT NULL,
  `messages` longtext DEFAULT NULL,
  `staff` longtext DEFAULT NULL,
  `closed` longtext DEFAULT NULL,
  `closedFrom` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ricky_report_annotation` (
  `identifier` varchar(150) NOT NULL DEFAULT '',
  `annotation` longtext DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `ricky_report_staffchat` (
  `identifier` longtext DEFAULT NULL,
  `name` longtext DEFAULT NULL,
  `type` longtext DEFAULT NULL,
  `content` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;