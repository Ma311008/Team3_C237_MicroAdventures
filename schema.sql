-- C237 CA2: Local Micro-Adventure Bucket List
-- Run this file to create the database and seed a starting admin account.

CREATE DATABASE IF NOT EXISTS c237_adventuredb;
USE c237_adventuredb;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'explorer') NOT NULL DEFAULT 'explorer',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE experiences (
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

CREATE TABLE completions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_id INT NOT NULL,
  rating TINYINT,
  notes TEXT,
  completed_at DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (experience_id) REFERENCES experiences(id),
  UNIQUE KEY unique_completion (user_id, experience_id)
);

-- Seed one admin account so you can log in and add experiences immediately.
-- Login: admin@adventure.com / admin123
INSERT INTO users (username, email, password, role)
VALUES ('admin', 'admin@adventure.com', SHA1('admin123'), 'admin');
