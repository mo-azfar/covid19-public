-- create database
CREATE DATABASE IF NOT EXISTS covid19_public DEFAULT CHARACTER SET utf8;

--create table
CREATE TABLE IF NOT EXISTS cases_malaysia (
date DATE PRIMARY KEY,
cases_new int NOT NULL,
cluster_import int DEFAULT 0,
cluster_religious int DEFAULT 0,
cluster_community int DEFAULT 0,
cluster_highRisk int DEFAULT 0,
cluster_education int DEFAULT 0,
cluster_detentionCentre int DEFAULT 0,
cluster_workplace int DEFAULT 0
);

--create table
CREATE TABLE IF NOT EXISTS cases_state (
id bigint PRIMARY KEY,
date DATE NOT NULL,
state VARCHAR(255) NOT NULL,
cases_new int NOT NULL
);

--create table
CREATE TABLE IF NOT EXISTS clusters (
cluster VARCHAR(255) UNIQUE NOT NULL,
state LONGTEXT NOT NULL,
district LONGTEXT,
date_announced DATE NOT NULL,
date_last_onset DATE NOT NULL,
category LONGTEXT,
status LONGTEXT,
cases_new int NOT NULL,
cases_total int NOT NULL,
cases_active int NOT NULL,
tests int NOT NULL,
icu int NOT NULL,
deaths int NOT NULL,
recovered int NOT NULL
);

--create table
CREATE TABLE IF NOT EXISTS deaths_malaysia (
date DATE PRIMARY KEY,
deaths_new int NOT NULL
);

--create table
CREATE TABLE IF NOT EXISTS deaths_state (
id bigint PRIMARY KEY,
date DATE NOT NULL,
state VARCHAR(255) NOT NULL,
deaths_new int NOT NULL
);


