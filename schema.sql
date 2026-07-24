-- C237 CA2: Local Micro-Adventure Bucket List

USE C237_015_team3;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'explorer') NOT NULL DEFAULT 'explorer',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS experiences (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  category ENUM('food', 'nature', 'culture', 'nightlife', 'shopping') NOT NULL,
  location VARCHAR(150),
  difficulty ENUM('easy', 'moderate', 'challenging') NOT NULL DEFAULT 'easy',
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS completions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_id INT NOT NULL,
  rating TINYINT,
  notes TEXT,
  image VARCHAR(255) DEFAULT NULL,
  completed_at DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (experience_id) REFERENCES experiences(id),
  UNIQUE KEY unique_completion (user_id, experience_id)
);

-- Upgrading a database that already has a completions table from before the
-- image feature was added? Run this once (it will error harmlessly if the
-- column already exists on a fresh install, since IF NOT EXISTS covers that
-- on MySQL 8.0.29+; on older servers just skip this line on fresh installs):
-- ALTER TABLE completions ADD COLUMN image VARCHAR(255) DEFAULT NULL;

-- Seed one admin account so you can log in and add experiences immediately.
-- Login: admin@adventure.com / admin123
-- INSERT IGNORE so re-running this file doesn't error on the UNIQUE constraint.
INSERT IGNORE INTO users (username, email, password, role)
VALUES ('admin', 'admin@adventure.com', SHA1('admin123'), 'admin');

-- Seed one explorer account for grading/testing (regular-user login).
-- Login: explorer@adventure.com / explorer123
INSERT IGNORE INTO users (username, email, password, role)
VALUES ('demo_explorer', 'explorer@adventure.com', SHA1('explorer123'), 'explorer');
