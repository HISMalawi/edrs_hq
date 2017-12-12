        DROP TABLE IF EXISTS `icd_codes`;
        CREATE TABLE `icd_codes` (
        `icd_code_id` VARCHAR(225) NOT NULL,
      `code` VARCHAR(255) DEFAULT NULL,
      `description` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`icd_code_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
