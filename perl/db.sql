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




