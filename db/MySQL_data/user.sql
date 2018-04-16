        DROP TABLE IF EXISTS `user`;
        CREATE TABLE `user` (
        `user_id` VARCHAR(225) NOT NULL,
      `username` VARCHAR(255) DEFAULT NULL,
      `first_name` VARCHAR(255) DEFAULT NULL,
      `last_name` VARCHAR(255) DEFAULT NULL,
      `password_hash` VARCHAR(255) DEFAULT NULL,
      `last_password_date` datetime DEFAULT NULL,
      `password_attempt` INT(11) DEFAULT NULL,
      `login_attempt` INT(11) DEFAULT NULL,
      `email` VARCHAR(255) DEFAULT NULL,
      `active` tinyint(1) NOT NULL  DEFAULT '0',
      `notify` tinyint(1) NOT NULL  DEFAULT '0',
      `role` VARCHAR(255) DEFAULT NULL,
      `site_code` VARCHAR(255) DEFAULT NULL,
      `district_code` VARCHAR(255) DEFAULT NULL,
      `creator` VARCHAR(255) DEFAULT NULL,
      `plain_password` VARCHAR(255) DEFAULT NULL,
      `un_or_block_reason` VARCHAR(255) DEFAULT NULL,
      `signature` VARCHAR(255) DEFAULT NULL,
      `_rev` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`user_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO user (user_id, username, first_name, last_name, password_hash, last_password_date, password_attempt, login_attempt, email, active, notify, role, site_code, district_code, creator, plain_password, un_or_block_reason, signature, _rev, updated_at, created_at) VALUES 
('dafaf1b98315133e4adf08e1c71e7179', "admin","EDRS","Administrator","$2a$10$V00x3sZWza7WvF3KCA./eOb2JU.kbvuLOA9AqVkLmGljEPP0/il7a","2018-04-08 08:26:46",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator","HQ",NULL, "admin",NULL, NULL, NULL, "1-03f719b5756ff2fdfd6cc700851f4ca6","2018-04-08 08:26:46","2018-04-08 08:26:46"),('cc267f245f0937bbb2a99e7d57207dda', "adminbt","EDRS BT","Administrator","$2a$10$o7HbvOTBdp8kyq6ldxFFveYlPJf3LzTgQtlyk8v0giMVnUVDcqLb6","2018-04-08 18:59:28",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator",NULL, "BT","admin",NULL, NULL, NULL, "1-760acb1e8c779fe90f125a35de9f711d","2018-04-08 18:59:37","2018-04-08 18:59:37"),('7368a16ee195dbf6e369490b681326d4', "adrbt","ADR","BT","$2a$10$8IJo2K0.t0.V.FFE.Nk7S.gq6/8SshHFk0Sf5mTs40g8XLMYQJVhG","2018-04-08 19:05:34",'0','0',NULL, 'true',0, "ADR",NULL, "BT","admin",NULL, NULL, NULL, "1-79cf7abdc08262ea705f21b04e787b38","2018-04-08 19:06:58","2018-04-08 19:06:58"),('7368a16ee195dbf6e369490b6812f020', "clerkbt","Clerk","BT","$2a$10$tooAoc2JZbsbQdYRUmn64O.6NFlVrwAVsS2lutFAk6X5Zu5C4Mfje","2018-04-08 19:05:34",'0','0',NULL, 'true',0, "Data Clerk",NULL, "BT","admin",NULL, NULL, NULL, "1-778c65e1a099b4bc32881e5df71a2557","2018-04-08 19:16:10","2018-04-08 19:16:10"),('7368a16ee195dbf6e369490b6812d71a', "lobt","LO","BT","$2a$10$fQRrK6ipkl2jgQ/COe39wOOGlU0zsH.ayBj9LP2xKyTEaoRUar5/q","2018-04-08 19:05:34",'0','0',NULL, 'true',0, "Logistics Officer",NULL, "BT","admin",NULL, NULL, NULL, "1-e26eb2e150a16f3025d06437516e9593","2018-04-08 19:16:57","2018-04-08 19:16:57");
