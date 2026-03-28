-- ============================================
-- WA ENGINE CRM — Complete Database Schema
-- Version 2.0 | TPots IT Solutions
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- --------------------------------------------
-- 1. users
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name`          VARCHAR(100) NOT NULL,
  `email`         VARCHAR(150) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role`          ENUM('admin','sales','support','developer') NOT NULL DEFAULT 'sales',
  `phone`         VARCHAR(20),
  `avatar`        VARCHAR(255),
  `is_active`     TINYINT(1) NOT NULL DEFAULT 1,
  `last_login`    DATETIME,
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Default admin user (password: Admin@123)
INSERT INTO `users` (`name`, `email`, `password_hash`, `role`) VALUES
('Admin', 'admin@waengine.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- --------------------------------------------
-- 2. clients
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `clients` (
  `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `company_name`     VARCHAR(200) NOT NULL,
  `contact_person`   VARCHAR(150),
  `email`            VARCHAR(150),
  `phone`            VARCHAR(20),
  `whatsapp_number`  VARCHAR(20),
  `industry`         VARCHAR(100),
  `city`             VARCHAR(100),
  `state`            VARCHAR(100),
  `country`          VARCHAR(100) DEFAULT 'India',
  `assigned_to`      INT UNSIGNED,
  `status`           ENUM('active','inactive','churned','trial') DEFAULT 'active',
  `source`           ENUM('referral','inbound','outbound','event','other') DEFAULT 'inbound',
  `notes`            TEXT,
  `health_score`     TINYINT UNSIGNED DEFAULT 100,
  `is_deleted`       TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 3. leads
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `leads` (
  `id`                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `company_name`        VARCHAR(200) NOT NULL,
  `contact_person`      VARCHAR(150),
  `email`               VARCHAR(150),
  `phone`               VARCHAR(20),
  `whatsapp_number`     VARCHAR(20),
  `industry`            VARCHAR(100),
  `source`              ENUM('referral','inbound','outbound','website','event','other') DEFAULT 'inbound',
  `stage`               ENUM('new','contacted','demo_given','proposal_sent','negotiation','won','lost') DEFAULT 'new',
  `assigned_to`         INT UNSIGNED,
  `expected_value`      DECIMAL(10,2),
  `expected_close_date` DATE,
  `lost_reason`         VARCHAR(255),
  `converted_client_id` INT UNSIGNED,
  `notes`               TEXT,
  `is_deleted`          TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 4. followups
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `followups` (
  `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `entity_type`      ENUM('lead','client') NOT NULL,
  `entity_id`        INT UNSIGNED NOT NULL,
  `assigned_to`      INT UNSIGNED NOT NULL,
  `created_by`       INT UNSIGNED NOT NULL,
  `type`             ENUM('call','whatsapp','email','meeting','demo','other') NOT NULL,
  `scheduled_at`     DATETIME NOT NULL,
  `done_at`          DATETIME,
  `status`           ENUM('pending','done','missed','rescheduled') DEFAULT 'pending',
  `outcome`          TEXT,
  `next_followup_at` DATETIME,
  `notes`            TEXT,
  `created_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 5. tasks
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `tasks` (
  `id`                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `title`                VARCHAR(255) NOT NULL,
  `description`          TEXT,
  `entity_type`          ENUM('client','lead','ticket','general') DEFAULT 'general',
  `entity_id`            INT UNSIGNED,
  `assigned_to`          INT UNSIGNED NOT NULL,
  `assigned_by`          INT UNSIGNED NOT NULL,
  `task_type`            ENUM('single','recurring') DEFAULT 'single',
  `frequency_type`       ENUM('daily','weekly','monthly','every_n_days','specific_dates','custom_datetime') NULL,
  `frequency_config`     JSON NULL,
  `due_at`               DATETIME NOT NULL,
  `next_due_at`          DATETIME NULL,
  `task_time`            TIME NULL,
  `reminder_before_mins` INT UNSIGNED DEFAULT 60,
  `overdue_alert_mins`   INT UNSIGNED DEFAULT 120,
  `priority`             ENUM('low','medium','high','urgent') DEFAULT 'medium',
  `status`               ENUM('todo','in_progress','done','overdue','rescheduled','cancelled') DEFAULT 'todo',
  `done_at`              DATETIME NULL,
  `rescheduled_to`       DATETIME NULL,
  `reschedule_reason`    VARCHAR(255) NULL,
  `reschedule_count`     TINYINT UNSIGNED DEFAULT 0,
  `wa_assigned_sent`     TINYINT(1) DEFAULT 0,
  `wa_reminder_sent`     TINYINT(1) DEFAULT 0,
  `wa_overdue_sent`      TINYINT(1) DEFAULT 0,
  `parent_task_id`       INT UNSIGNED NULL,
  `notes`                TEXT,
  `created_at`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 6. task_performance
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `task_performance` (
  `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`          INT UNSIGNED NOT NULL,
  `period_type`      ENUM('daily','weekly','monthly') NOT NULL,
  `period_start`     DATE NOT NULL,
  `period_end`       DATE NOT NULL,
  `total_tasks`      INT UNSIGNED DEFAULT 0,
  `done_on_time`     INT UNSIGNED DEFAULT 0,
  `done_late`        INT UNSIGNED DEFAULT 0,
  `not_done`         INT UNSIGNED DEFAULT 0,
  `rescheduled`      INT UNSIGNED DEFAULT 0,
  `cancelled`        INT UNSIGNED DEFAULT 0,
  `score_percentage` DECIMAL(5,2) DEFAULT 0.00,
  `rating_color`     ENUM('green','orange','red') DEFAULT 'red',
  `calculated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_user_period` (`user_id`, `period_type`, `period_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 7. meetings
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `meetings` (
  `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `entity_type`     ENUM('client','lead') NOT NULL,
  `entity_id`       INT UNSIGNED NOT NULL,
  `title`           VARCHAR(255) NOT NULL,
  `scheduled_at`    DATETIME NOT NULL,
  `duration_mins`   SMALLINT UNSIGNED DEFAULT 30,
  `platform`        ENUM('zoom','google_meet','phone','in_person','other') DEFAULT 'zoom',
  `zoom_meeting_id` VARCHAR(50),
  `zoom_join_url`   VARCHAR(500),
  `zoom_password`   VARCHAR(50),
  `attendees`       TEXT,
  `hosted_by`       INT UNSIGNED NOT NULL,
  `status`          ENUM('scheduled','done','cancelled','no_show') DEFAULT 'scheduled',
  `notes`           TEXT,
  `recording_url`   VARCHAR(500),
  `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 8. tickets
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `tickets` (
  `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `client_id`        INT UNSIGNED NOT NULL,
  `ticket_number`    VARCHAR(20) NOT NULL UNIQUE,
  `title`            VARCHAR(255) NOT NULL,
  `description`      TEXT NOT NULL,
  `type`             ENUM('technical','billing','feature_request','onboarding','general') DEFAULT 'general',
  `priority`         ENUM('low','medium','high','critical') DEFAULT 'medium',
  `status`           ENUM('open','in_progress','waiting_client','resolved','closed') DEFAULT 'open',
  `assigned_to`      INT UNSIGNED,
  `created_by`       INT UNSIGNED,
  `raised_by_name`   VARCHAR(150),
  `raised_by_email`  VARCHAR(150),
  `resolved_at`      DATETIME,
  `sla_deadline`     DATETIME,
  `is_deleted`       TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 9. ticket_comments
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `ticket_comments` (
  `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `ticket_id`   INT UNSIGNED NOT NULL,
  `user_id`     INT UNSIGNED,
  `comment`     TEXT NOT NULL,
  `is_internal` TINYINT(1) DEFAULT 0,
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 10. payments
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
  `id`             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `client_id`      INT UNSIGNED NOT NULL,
  `invoice_number` VARCHAR(30) NOT NULL UNIQUE,
  `description`    VARCHAR(255),
  `amount`         DECIMAL(10,2) NOT NULL,
  `currency`       VARCHAR(5) DEFAULT 'INR',
  `tax_amount`     DECIMAL(10,2) DEFAULT 0,
  `total_amount`   DECIMAL(10,2) NOT NULL,
  `amount_paid`    DECIMAL(10,2) DEFAULT 0,
  `status`         ENUM('pending','partial','paid','overdue','cancelled') DEFAULT 'pending',
  `due_date`       DATE NOT NULL,
  `paid_date`      DATE,
  `payment_mode`   ENUM('bank_transfer','upi','cash','cheque','razorpay','other'),
  `razorpay_id`    VARCHAR(100),
  `receipt_url`    VARCHAR(500),
  `notes`          TEXT,
  `created_by`     INT UNSIGNED,
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 11. subscriptions
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `subscriptions` (
  `id`               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `client_id`        INT UNSIGNED NOT NULL,
  `plan_name`        VARCHAR(100) NOT NULL,
  `plan_type`        ENUM('monthly','annual') DEFAULT 'monthly',
  `start_date`       DATE NOT NULL,
  `end_date`         DATE NOT NULL,
  `amount`           DECIMAL(10,2) NOT NULL,
  `status`           ENUM('active','expired','cancelled','trial') DEFAULT 'active',
  `auto_renew`       TINYINT(1) DEFAULT 1,
  `reminder_sent_30` TINYINT(1) DEFAULT 0,
  `reminder_sent_7`  TINYINT(1) DEFAULT 0,
  `reminder_sent_1`  TINYINT(1) DEFAULT 0,
  `notes`            TEXT,
  `created_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 12. waba_numbers
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `waba_numbers` (
  `id`                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `client_id`           INT UNSIGNED NOT NULL,
  `phone_number`        VARCHAR(25) NOT NULL,
  `display_name`        VARCHAR(100),
  `waba_id`             VARCHAR(50),
  `phone_number_id`     VARCHAR(50),
  `business_account_id` VARCHAR(50),
  `verification_status` ENUM('not_started','pending','verified','rejected') DEFAULT 'not_started',
  `quality_rating`      ENUM('green','yellow','red','unknown') DEFAULT 'unknown',
  `messaging_limit`     VARCHAR(50),
  `is_primary`          TINYINT(1) DEFAULT 1,
  `is_active`           TINYINT(1) DEFAULT 1,
  `notes`               TEXT,
  `created_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 13. campaigns
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `campaigns` (
  `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `client_id`       INT UNSIGNED NOT NULL,
  `name`            VARCHAR(200) NOT NULL,
  `template_name`   VARCHAR(150),
  `waba_number_id`  INT UNSIGNED,
  `sent_count`      INT UNSIGNED DEFAULT 0,
  `delivered_count` INT UNSIGNED DEFAULT 0,
  `read_count`      INT UNSIGNED DEFAULT 0,
  `failed_count`    INT UNSIGNED DEFAULT 0,
  `status`          ENUM('draft','scheduled','running','completed','failed') DEFAULT 'draft',
  `scheduled_at`    DATETIME,
  `started_at`      DATETIME,
  `completed_at`    DATETIME,
  `run_by`          INT UNSIGNED,
  `notes`           TEXT,
  `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 14. activity_log
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `activity_log` (
  `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`     INT UNSIGNED,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id`   INT UNSIGNED NOT NULL,
  `action`      VARCHAR(100) NOT NULL,
  `old_value`   TEXT,
  `new_value`   TEXT,
  `ip_address`  VARCHAR(45),
  `notes`       TEXT,
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 15. notifications
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id`     INT UNSIGNED,
  `entity_type` VARCHAR(50),
  `entity_id`   INT UNSIGNED,
  `channel`     ENUM('in_app','whatsapp','email') NOT NULL DEFAULT 'in_app',
  `title`       VARCHAR(255) NOT NULL,
  `message`     TEXT NOT NULL,
  `is_read`     TINYINT(1) DEFAULT 0,
  `sent_at`     DATETIME,
  `status`      ENUM('pending','sent','failed') DEFAULT 'pending',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 16. fms_sops
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_sops` (
  `id`         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `title`      VARCHAR(255) NOT NULL,
  `role`       ENUM('admin','sales','support','developer','all') DEFAULT 'all',
  `category`   VARCHAR(100),
  `content`    LONGTEXT,
  `pdf_url`    VARCHAR(500),
  `version`    VARCHAR(20) DEFAULT '1.0',
  `is_active`  TINYINT(1) DEFAULT 1,
  `created_by` INT UNSIGNED,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 17. fms_training
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_training` (
  `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `title`         VARCHAR(255) NOT NULL,
  `role`          ENUM('admin','sales','support','developer','all') DEFAULT 'all',
  `category`      VARCHAR(100),
  `description`   TEXT,
  `platform`      ENUM('youtube','google_drive','vimeo','other') DEFAULT 'youtube',
  `video_url`     VARCHAR(500) NOT NULL,
  `duration_mins` SMALLINT UNSIGNED,
  `is_mandatory`  TINYINT(1) DEFAULT 0,
  `order_index`   SMALLINT UNSIGNED DEFAULT 0,
  `is_active`     TINYINT(1) DEFAULT 1,
  `created_by`    INT UNSIGNED,
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 18. fms_checklists
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_checklists` (
  `id`          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `title`       VARCHAR(255) NOT NULL,
  `role`        ENUM('admin','sales','support','developer','all') DEFAULT 'all',
  `frequency`   ENUM('daily','weekly','monthly','onboarding','one_time') DEFAULT 'daily',
  `description` TEXT,
  `is_active`   TINYINT(1) DEFAULT 1,
  `created_by`  INT UNSIGNED,
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 19. fms_checklist_items
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_checklist_items` (
  `id`           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `checklist_id` INT UNSIGNED NOT NULL,
  `item_text`    VARCHAR(500) NOT NULL,
  `order_index`  SMALLINT UNSIGNED DEFAULT 0,
  `is_required`  TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 20. fms_checklist_logs
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_checklist_logs` (
  `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `checklist_id`    INT UNSIGNED NOT NULL,
  `user_id`         INT UNSIGNED NOT NULL,
  `completed_items` JSON,
  `is_complete`     TINYINT(1) DEFAULT 0,
  `completed_at`    DATETIME,
  `date`            DATE NOT NULL,
  UNIQUE KEY `unique_user_checklist_date` (`user_id`, `checklist_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------
-- 21. fms_role_templates
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS `fms_role_templates` (
  `id`                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `role`                 ENUM('admin','sales','support','developer') NOT NULL,
  `task_title`           VARCHAR(255) NOT NULL,
  `task_description`     TEXT,
  `task_type`            ENUM('single','recurring') DEFAULT 'recurring',
  `frequency_type`       ENUM('daily','weekly','monthly','every_n_days') NULL,
  `frequency_config`     JSON NULL,
  `task_time`            TIME NULL,
  `priority`             ENUM('low','medium','high','urgent') DEFAULT 'medium',
  `reminder_before_mins` INT UNSIGNED DEFAULT 60,
  `is_active`            TINYINT(1) DEFAULT 1,
  `created_at`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;