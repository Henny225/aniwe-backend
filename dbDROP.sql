-- Disable foreign key checks to prevent dependency errors during deletion
SET FOREIGN_KEY_CHECKS = 0;

-- Drop Triggers
DROP TRIGGER IF EXISTS tr_AfterPreferenceInsert;

--  Drop Views
DROP VIEW IF EXISTS vw_UserDirectory;

--  Drop Procedures
DROP PROCEDURE IF EXISTS sp_RegisterRetailer;

-- Drop Tables
DROP TABLE IF EXISTS CONSUMER_STYLE_PREFERENCES;
DROP TABLE IF EXISTS ADMINISTRATOR;
DROP TABLE IF EXISTS RETAIL_PARTNER;
DROP TABLE IF EXISTS CONSUMER;
DROP TABLE IF EXISTS USER;
DROP TABLE IF EXISTS PREFERENCE_LOG;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
