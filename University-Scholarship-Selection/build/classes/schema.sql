CREATE DATABASE IF NOT EXISTS university_scholarship
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE university_scholarship;

CREATE TABLE IF NOT EXISTS staff_users (
  staff_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS batches (
  batch_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  batch_name VARCHAR(80) NOT NULL UNIQUE,
  program_name VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS students (
  student_id VARCHAR(32) PRIMARY KEY,
  batch_id BIGINT NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_students_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

CREATE TABLE IF NOT EXISTS result_periods (
  period_code VARCHAR(32) PRIMARY KEY,
  status ENUM('IMPORTED', 'RELEASED') NOT NULL DEFAULT 'IMPORTED',
  imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  released_at TIMESTAMP NULL,
  released_by BIGINT NULL,
  CONSTRAINT fk_period_released_by FOREIGN KEY (released_by) REFERENCES staff_users(staff_id)
);

CREATE TABLE IF NOT EXISTS student_results (
  result_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  student_id VARCHAR(32) NOT NULL,
  period_code VARCHAR(32) NOT NULL,
  gpa DECIMAL(4, 2) NOT NULL,
  CONSTRAINT uq_result_student_period UNIQUE (student_id, period_code),
  CONSTRAINT ck_result_gpa CHECK (gpa >= 0 AND gpa <= 4),
  CONSTRAINT fk_results_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_results_period FOREIGN KEY (period_code) REFERENCES result_periods(period_code)
);

CREATE TABLE IF NOT EXISTS scholarship_rules (
  rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  batch_id BIGINT NOT NULL,
  period_code VARCHAR(32) NOT NULL,
  slots_per_batch INT NOT NULL,
  minimum_gpa DECIMAL(4, 2) NOT NULL DEFAULT 0,
  CONSTRAINT uq_rule_batch_period UNIQUE (batch_id, period_code),
  CONSTRAINT ck_rule_slots CHECK (slots_per_batch > 0),
  CONSTRAINT ck_rule_min_gpa CHECK (minimum_gpa >= 0 AND minimum_gpa <= 4),
  CONSTRAINT fk_rules_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id),
  CONSTRAINT fk_rules_period FOREIGN KEY (period_code) REFERENCES result_periods(period_code)
);

CREATE TABLE IF NOT EXISTS selection_runs (
  run_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  period_code VARCHAR(32) NOT NULL,
  created_by BIGINT NOT NULL,
  status ENUM('REVIEW_PENDING', 'CONFIRMED') NOT NULL DEFAULT 'REVIEW_PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  confirmed_by BIGINT NULL,
  confirmed_at TIMESTAMP NULL,
  CONSTRAINT fk_run_period FOREIGN KEY (period_code) REFERENCES result_periods(period_code),
  CONSTRAINT fk_run_created_by FOREIGN KEY (created_by) REFERENCES staff_users(staff_id),
  CONSTRAINT fk_run_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES staff_users(staff_id)
);

CREATE TABLE IF NOT EXISTS candidates (
  candidate_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  run_id BIGINT NOT NULL,
  student_id VARCHAR(32) NOT NULL,
  batch_id BIGINT NOT NULL,
  batch_rank INT NOT NULL,
  tie_at_cutoff BOOLEAN NOT NULL DEFAULT FALSE,
  proposed BOOLEAN NOT NULL DEFAULT FALSE,
  decision ENUM('PENDING', 'SELECTED', 'NOT_SELECTED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT uq_candidate_run_student UNIQUE (run_id, student_id),
  CONSTRAINT fk_candidate_run FOREIGN KEY (run_id) REFERENCES selection_runs(run_id),
  CONSTRAINT fk_candidate_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_candidate_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

CREATE TABLE IF NOT EXISTS selection_exceptions (
  exception_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  run_id BIGINT NOT NULL,
  batch_id BIGINT NULL,
  student_id VARCHAR(32) NULL,
  reason VARCHAR(300) NOT NULL,
  CONSTRAINT fk_exception_run FOREIGN KEY (run_id) REFERENCES selection_runs(run_id),
  CONSTRAINT fk_exception_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

CREATE TABLE IF NOT EXISTS payment_checks (
  check_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  candidate_id BIGINT NOT NULL UNIQUE,
  status ENUM('PENDING', 'PREPARED') NOT NULL DEFAULT 'PENDING',
  prepared_at TIMESTAMP NULL,
  prepared_by BIGINT NULL,
  CONSTRAINT fk_check_candidate FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
  CONSTRAINT fk_check_prepared_by FOREIGN KEY (prepared_by) REFERENCES staff_users(staff_id)
);

CREATE TABLE IF NOT EXISTS email_logs (
  email_log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  candidate_id BIGINT NOT NULL,
  email_type ENUM('AWARD', 'CHECK_COLLECTION') NOT NULL,
  recipient_email VARCHAR(254) NOT NULL,
  status ENUM('SENT', 'FAILED') NOT NULL,
  error_message VARCHAR(500) NULL,
  sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_candidate_email_type UNIQUE (candidate_id, email_type),
  CONSTRAINT fk_email_candidate FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
);

CREATE TABLE IF NOT EXISTS contact_messages (
  message_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  sender_name VARCHAR(120) NOT NULL,
  sender_email VARCHAR(254) NOT NULL,
  subject VARCHAR(160) NOT NULL,
  message_body TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_student_results_period ON student_results(period_code);
CREATE INDEX IF NOT EXISTS idx_candidates_run_batch ON candidates(run_id, batch_id, batch_rank);
CREATE INDEX IF NOT EXISTS idx_email_logs_candidate ON email_logs(candidate_id, sent_at);
