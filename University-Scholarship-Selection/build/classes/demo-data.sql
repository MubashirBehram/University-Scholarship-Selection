USE university_scholarship;

START TRANSACTION;

UPDATE batches
SET batch_name = 'BSSE-2024', program_name = 'BS Software Engineering'
WHERE batch_name = 'BSSE-2023';

UPDATE batches
SET batch_name = 'BSCS-2024', program_name = 'BS Computer Science'
WHERE batch_name = 'BSCS-2023';

INSERT INTO batches (batch_name, program_name) VALUES
  ('BSSE-2024', 'BS Software Engineering'),
  ('BSCS-2024', 'BS Computer Science'),
  ('BSSE-2025', 'BS Software Engineering'),
  ('BSCS-2025', 'BS Computer Science')
ON DUPLICATE KEY UPDATE program_name = VALUES(program_name);

INSERT INTO result_periods (period_code) VALUES ('2026-SPRING')
ON DUPLICATE KEY UPDATE period_code = VALUES(period_code);

INSERT INTO students (student_id, batch_id, full_name, email) VALUES
  ('DEMO-001', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2024'), 'Ayesha Demo', 'ayesha@example.edu'),
  ('DEMO-002', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2024'), 'Hamza Demo', 'hamza@example.edu'),
  ('DEMO-003', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2024'), 'Noor Demo', 'noor@example.edu'),
  ('DEMO-004', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2024'), 'Bilal Demo', 'bilal@example.edu'),
  ('DEMO-005', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2024'), 'Sara Demo', 'sara@example.edu'),
  ('DEMO-006', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2024'), 'Ali Demo', 'ali@example.edu'),
  ('DEMO-007', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2024'), 'Hina Demo', 'hina@example.edu'),
  ('DEMO-008', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2024'), 'Usman Demo', 'usman@example.edu'),
  ('DEMO-009', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2025'), 'Iqra Demo', 'iqra@example.edu'),
  ('DEMO-010', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2025'), 'Zain Demo', 'zain@example.edu'),
  ('DEMO-011', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2025'), 'Maham Demo', 'maham@example.edu'),
  ('DEMO-012', (SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2025'), 'Daniyal Demo', 'daniyal@example.edu'),
  ('DEMO-013', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2025'), 'Laiba Demo', 'laiba@example.edu'),
  ('DEMO-014', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2025'), 'Rayan Demo', 'rayan@example.edu'),
  ('DEMO-015', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2025'), 'Fatima Demo', 'fatima@example.edu'),
  ('DEMO-016', (SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2025'), 'Omar Demo', 'omar@example.edu')
ON DUPLICATE KEY UPDATE
  batch_id = VALUES(batch_id),
  full_name = VALUES(full_name),
  email = VALUES(email);

INSERT INTO student_results (student_id, period_code, gpa) VALUES
  ('DEMO-001', '2026-SPRING', 3.95),
  ('DEMO-002', '2026-SPRING', 3.72),
  ('DEMO-003', '2026-SPRING', 2.84),
  ('DEMO-004', '2026-SPRING', 2.41),
  ('DEMO-005', '2026-SPRING', 3.88),
  ('DEMO-006', '2026-SPRING', 3.61),
  ('DEMO-007', '2026-SPRING', 3.14),
  ('DEMO-008', '2026-SPRING', 2.76),
  ('DEMO-009', '2026-SPRING', 3.99),
  ('DEMO-010', '2026-SPRING', 3.83),
  ('DEMO-011', '2026-SPRING', 2.95),
  ('DEMO-012', '2026-SPRING', 2.22),
  ('DEMO-013', '2026-SPRING', 3.78),
  ('DEMO-014', '2026-SPRING', 3.50),
  ('DEMO-015', '2026-SPRING', 3.05),
  ('DEMO-016', '2026-SPRING', 2.65)
ON DUPLICATE KEY UPDATE gpa = VALUES(gpa);

INSERT INTO scholarship_rules (batch_id, period_code, slots_per_batch, minimum_gpa) VALUES
  ((SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2024'), '2026-SPRING', 1, 3.00),
  ((SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2024'), '2026-SPRING', 1, 3.00),
  ((SELECT batch_id FROM batches WHERE batch_name = 'BSSE-2025'), '2026-SPRING', 1, 3.00),
  ((SELECT batch_id FROM batches WHERE batch_name = 'BSCS-2025'), '2026-SPRING', 1, 3.00)
ON DUPLICATE KEY UPDATE
  slots_per_batch = VALUES(slots_per_batch),
  minimum_gpa = VALUES(minimum_gpa);

COMMIT;
