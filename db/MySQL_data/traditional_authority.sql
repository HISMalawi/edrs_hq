        DROP TABLE IF EXISTS `traditional_authority`;
        CREATE TABLE `traditional_authority` (
        `traditional_authority_id` VARCHAR(225) NOT NULL,
      `district_id` VARCHAR(255) DEFAULT NULL,
      `name` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`traditional_authority_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO traditional_authority (traditional_authority_id, district_id, name, updated_at, created_at) VALUES 
('d57fb64ac4b3c0ed3a28effc0c0681b9', "CP","Mwabulambya","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c067a6b', "CP","Mwenemisuku","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c0679b9', "CP","Mwenewenya","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c067096', "CP","Nthalire","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c066c53', "CP","Kameme","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c06603d', "CP","Chitipa Boma","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c065c9f', "KA","Kilipula","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c0655ec', "KA","Mwakaboko","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c064cbf', "KA","Kyungu","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c063cdc', "KA","Wasambo","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c063cc4', "KA","Mwirang'ombe","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c063c15', "KA","Karonga Town","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c062eb3', "NB","Kabunduli","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c062819', "NB","Fukamapiri","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c062440', "NB","Malenga Mzoma","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c062346', "NB","S/C Malanda","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c0619c0', "NB","S/C Zilakoma","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c0611cb', "NB","Mankhambira","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c06104e', "NB","S/C Fukamalaza","2017-12-05 11:39:01","2017-12-05 11:39:01"),('d57fb64ac4b3c0ed3a28effc0c060f1b', "NB","S/C Mkumbira","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c060008', "NB","Musisya","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05f8d0', "NB","S/C Nyaluwanga","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05f102', "NB","S/C Mkondowe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05ebe6', "NB","Timbiri","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05dd6a', "NB","Boghoyo","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05d0c9', "NB","Nkhata-bay Boma","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05c114', "RU","Chikulamayembe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05baa9', "RU","Mwamlowe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05b9ba', "RU","S/C Mwahenga","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05adc0', "RU","S/C Mwalweni","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05a759', "RU","S/C Kachulu","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05a079', "RU","S/C Chapinduka","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c059e9d', "RU","S/C Mwankhunikira","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c059deb', "RU","Katumbi","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05985c', "RU","S/C Zolokere","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c058eab', "RU","Nyika National Park (A)","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c057f55', "RU","Rumphi Boma","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c057dad', "MZ","M'mbelwa","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c057001', "MZ","Mtwalo","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0569b4', "MZ","S/C Kampingo Sibande","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0559f7', "MZ","S/C Jaravikuba Munthali","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05544d', "MZ","Chindi","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c054dd7', "MZ","Mzikubola","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0543f2', "MZ","Mabulabo","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c053b9f', "MZ","S/C Khosolo Gwaza Jere","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c05307c', "MZ","Mpherembe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c052bf6', "MZ","Mzukuzuku","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c052a35', "MZ","Mzimba Boma","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c051fee', "MZC","Nkhorongo Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c051659', "MZC","Lupaso Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c050db8', "MZC","Zolozolo Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c050367', "MZC","Chiputula Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04f723', "MZC","Mchengautuwa Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04f6db', "MZC","Katoto Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04f662', "MZC","Jombo Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04eccd', "MZC","Mzilawayingwe Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04eb8c', "MZC","Chasefu Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04dd1f', "MZC","Katawa Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04d4f7', "MZC","Masasa Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04cbed', "MZC","Kaning'ina Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04c709', "MZC","Vipya Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04c024', "MZC","Msongwe Ward","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04b6fb', "MZC","New Airport Site","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04b5d5', "LA","Mkumpha","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04b1ab', "KU","Kasungu Boma","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04ac2e', "KU","TA Chilowamatambe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c049fee', "KU","TA Chisikwa","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c049dd0', "KU","TA Chulu","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c049046', "KU","TA Kaluluma","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0482b1', "KU","TA Kaomba","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0477b9', "KU","TA Kapelula","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c046934', "KU","TA Kawamba","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c046634', "KU","S/C Lukwa","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c046103', "KU","S/C Mnyanja","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c045d5c', "KU","S/C Njombwa","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c04527e', "KU","TA Santhe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0443d0', "KU","S/C Simlemba","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c0435cb', "KU","TA Wimbe","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c042ec2', "KU","Kasungu National Park","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c042a31', "KK","TA Kanyenda","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c042989', "KK","SC Kafuzila","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c041a66', "KK","TA Malengachanzi","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c040e86', "KK","STA Mphonde","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c040c68', "KK","TA Mwadzama","2017-12-05 11:39:02","2017-12-05 11:39:02"),('d57fb64ac4b3c0ed3a28effc0c040b65', "KK","TA Mwansambo","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c040271', "KK","Nkhotakota Boma","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c040141', "NS","Ta Kasakula","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03f3fe', "NS","TA Chikho","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03f38d', "NS","S/C Nthondo","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03e3ff', "NS","TA Kalumo","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03de77', "NS","S/C Chilooko","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03de4b', "NS","Ntchisi Boma","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03d0d9', "DA","TA Dzoole","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03cb0f', "DA","S/C Chakhadza","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03bbd6', "DA","TA Kayembe","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03bba4', "DA","TA Chiwere","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03b599', "DA","SC Mkukula","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03ac8a', "DA","TA Msakambewa","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03a27a', "DA","TA Mponela","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c039569', "DA","Mponela Urban","2017-12-05 11:39:03","2017-12-05 11:39:03");

INSERT INTO traditional_authority (traditional_authority_id, district_id, name, updated_at, created_at) VALUES 
('d57fb64ac4b3c0ed3a28effc0c038629', "DA","Dowa Boma","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c037cb3', "SA","Maganga","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c037bf7', "SA","Kalonga","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03765e', "SA","Pemba","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03759d', "SA","SC Kambwiri","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03669b', "SA","Ndindi","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c036631', "SA","SC Kambalame","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c036622', "SA","Khombedza","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c035b36', "SA","SC Mwanza","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c035167', "SA","Kuluunda","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c034920', "SA","SC Msosa","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c034097', "SA","Salima Boma","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c033164', "LL","Mtema","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0329d0', "LL","Chadza","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03264b', "LL","Kalolo","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03230f', "LL","Chiseka","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c03155d', "LL","Mazengera","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c030dac', "LL","Chitekwere","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c030c35', "LL","Khongoni","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0307d4', "LL","Chimutu","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0303e9', "LL","Tsabango","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c030387', "LL","Njewa","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02fc64', "LL","Kabudula","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02f4a8', "LL","Malili","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02eaa4', "LL","Chitukula","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02deff', "LL","Masumbankhunda","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02dc99', "LL","Masula","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02d79b', "LLC","Area 1 (Falls)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02d4af', "LLC","Area 2 (Old town)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02d2d2', "LLC","Area 3","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02c7ce', "LLC","Area 4","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02b9da', "LLC","Area 5","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02b093', "LLC","Area 6","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02a139', "LLC","Area 7 (Kawale)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0293de', "LLC","Area 8 (Biwi)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0291fa', "LLC","Area 9","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0283de', "LLC","Area 10","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0281f9', "LLC","Area 11","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c028039', "LLC","Area 12","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c027c30', "LLC","Area 13","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c026f5c', "LLC","Area 14","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c026a59', "LLC","Area 15","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0268a1', "LLC","Area 16","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02644b', "LLC","Area 17","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c025d3f', "LLC","Area 18","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c02537e', "LLC","Area 19","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c0249b5', "LLC","Area 20 (Chilinde 1)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c023f08', "LLC","Area 21 (Chilinde)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c023a25', "LLC","Area 22","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c022cbf', "LLC","Area 23","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c022568', "LLC","Area 24","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c022237', "LLC","Area 25","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c021bb1', "LLC","Area 26 (Manyenje)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c020c93', "LLC","Area 27 (Liwewe)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c020aeb', "LLC","Area 28","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c020616', "LLC","Area 29 (Kanengo)","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01f8a6', "LLC","Area 30","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01f245', "LLC","Area 31","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01ec4a', "LLC","Area 32","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01e298', "LLC","Area 33","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01e02b', "LLC","Area 34","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01df25', "LLC","Area 35","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01cfb9', "LLC","Area 36","2017-12-05 11:39:03","2017-12-05 11:39:03"),('d57fb64ac4b3c0ed3a28effc0c01c5c8', "LLC","Area 37","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01bdf6', "LLC","Area 38 (Chimutu)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01b59a', "LLC","Area 39 (Chatata)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01afe0', "LLC","Area 40","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01a2cd', "LLC","Area 41","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c019afc', "LLC","Area 42","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c018b65', "LLC","Area 43","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c0187d8', "LLC","Area 44","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01836c', "LLC","Area 45 (Katete)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01820b', "LLC","Area 46 (Njewa)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c017624', "LLC","Area 47","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c016c85', "LLC","Area 48","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c015f58', "LLC","Area 49","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c015c3f', "LLC","Area 50 (Senti)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c014f69', "LLC","Area 51 (M'gona)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c014416', "LLC","Area 52 (Lumbadzi TC)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c013fd1', "LLC","Area 53 (Lumbadzi)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01341f', "LLC","Area 54","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c012dbd', "LLC","Area 55 (Chitukula)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c012a1a', "LLC","Area 56 (Ntandire)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c0120d5', "LLC","Area 57(Chinsapo)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c011cac', "LLC","Area 58 (Likuni)","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c011358', "MC","Mchinji Boma","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c010e8f', "MC","Mduwa","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c01051c', "MC","Mkanda","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00fe04', "MC","Dambe","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00f9ab', "MC","Mavwere","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00f3ab', "MC","Mlonyeni","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00f24c', "MC","Zulu","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00f13d', "DZ","Dedza Town","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00e38a', "DZ","Kamenya Gwaza","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00d4d1', "DZ","Kaphuka","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00cf3f', "DZ","Pemba","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00c620', "DZ","Chauma","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00bc17', "DZ","Kachindamoto","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00b45c', "DZ","Chilikumwendo","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00b39f', "DZ","Kasumbu","2017-12-05 11:39:04","2017-12-05 11:39:04");

INSERT INTO traditional_authority (traditional_authority_id, district_id, name, updated_at, created_at) VALUES 
('d57fb64ac4b3c0ed3a28effc0c00a5e3', "DZ","Tambala","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c009cb0', "NU","Ntcheu Boma","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c009ba7', "NU","Chakhumbira","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c009a6d', "NU","Champiti","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c009625', "NU","Goodson Ganya","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c008ae1', "NU","Kwataine","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c0083d3', "NU","Makwangwala","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c007ab8', "NU","Masasa","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c006f8b', "NU","Mpando","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00645a', "NU","Njolomole","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c006395', "NU","Phambala","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c006110', "MH","Mangochi Boma","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00524b', "MH","Chimwala","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00496b', "MH","Jalasi","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c004525', "MH","Makanjila","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c003dec', "MH","Mponda","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c003a87', "MH","Nankumba","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c0033b2', "MH","Lake Malawi National Park","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c002943', "MH","Chowe","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c001a18', "MH","Katuli","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c00198b', "MH","Mbwananyambi","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c001785', "MH","Namabvi","2017-12-05 11:39:04","2017-12-05 11:39:04"),('d57fb64ac4b3c0ed3a28effc0c000fbe', "MHG","Liwonde National Park","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806fff10d', "MHG","Machinga Boma","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffef4f', "MHG","Chamba","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffe88d', "MHG","Chiwalo","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffd9ea', "MHG","Liwonde","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffce2b', "MHG","Mposa","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffc390', "MHG","Nyambi","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffb595', "MHG","Liwonde Town","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffafd4', "MHG","Chikweo","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffabb9', "MHG","Kawinga","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ffa9b6', "MHG","Mlomba","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff9a71', "MHG","Ngokwe","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff9231', "MHG","Sitola","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff851f', "ZA","Mbiza","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff8264', "ZA","Kuntumanji","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff805a', "ZA","Mkumbira","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff7080', "ZA","Mwambo","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff6263', "ZA","Chikowi","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff5314', "ZA","Malemia","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff4b88', "ZA","Mlumbe","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff4a0b', "ZAC","Chambo Ward","2017-12-05 11:39:04","2017-12-05 11:39:04"),('c49bdea959fa41c275450f3806ff4673', "ZAC","Chhikamveka Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff45f7', "ZAC","Chilunga East Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff3f68', "ZAC","Likangala Central Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff315f', "ZAC","Masongola Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff22ce', "ZAC","Mtiya Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff1fb5', "ZAC","Zakazaka Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff1c42', "ZAC","Chikamveka North Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff134e', "ZAC","Chirunga Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff115e', "ZAC","Likangala South Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff0fa8', "ZAC","Likangala North Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806ff09e6', "ZAC","Mbedza Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806feff61', "ZAC","Sadzi Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fefea4', "ZAC","Zomba Central Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fef88b', "CZ","Chitera","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fef14c', "CZ","Kadewere","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806feef80', "CZ","Likoswe","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fedfc2', "CZ","Mchema","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fedf42', "CZ","Nkalo","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fed9e1', "CZ","Mpama","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fed6b5', "CZ","Chiradzulu Boma","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806feca31', "BT","Kuntaja","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fec887', "BT","Lunzu TPA","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fec19b', "BT","Nkula TPA","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806feb7fb', "BT","Kapeni","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806feb0bf', "BT","Lundu","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fea166', "BT","Makata","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe9179', "BT","Somba","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe90ae', "BT","Chigaru","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe856d', "BT","Kunthembwe","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe7a6e', "BT","Machinjili","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe6f5f', "BTC","Bangwe Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe6320', "BTC","Blantyre West Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe5939', "BTC","Chigumula Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe58ef', "BTC","Likhubula Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe4fa6', "BTC","Limbe Central Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe4f73', "BTC","Mapanga Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe402e', "BTC","Misesa Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe3d8d', "BTC","Mzedi Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe3986', "BTC","Nancholi Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe315e', "BTC","Ndirande South Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe253a', "BTC","Nkolokoti Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe18c7', "BTC","Soche East Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe0de1', "BTC","South Lunzu Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe0b24', "BTC","Soche West Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fe0350', "BTC","Nyambadwe Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdf74c', "BTC","Ndirande West Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdf3cf', "BTC","Ndirande North Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdef2d', "BTC","Namiyango Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fde719', "BTC","Msamba Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fde492', "BTC","Michiru Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fde1ba', "BTC","Limbe East Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fde074', "BTC","Limbe West Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fddde3', "BTC","Chilomoni Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdcf1a', "BTC","Chichiri Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdc05d', "BTC","Blantrye East Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdb848', "BTC","Blantrye Central Ward","2017-12-05 11:39:05","2017-12-05 11:39:05"),('c49bdea959fa41c275450f3806fdb6f8', "MN","Kanduku","2017-12-05 11:39:05","2017-12-05 11:39:05");