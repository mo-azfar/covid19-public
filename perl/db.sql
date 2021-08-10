-- create database
CREATE DATABASE IF NOT EXISTS covid19_public DEFAULT CHARACTER SET utf8;

--create table cases_malaysia
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

--create table cases_state
CREATE TABLE IF NOT EXISTS cases_state (
date DATE NOT NULL PRIMARY KEY, 
Johor INT, 
Kedah INT, 
Kelantan INT, 
Melaka INT, 
NegeriSembilan INT, 
Pahang INT, 
Perak INT, 
Perlis INT, 
PulauPinang INT, 
Sabah INT, 
Sarawak INT, 
Selangor INT, 
Terengganu INT,
WPKualaLumpur INT, 
WPLabuan INT, 
WPPutrajaya INT,
Total INT
);

--create table clusters
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

--create table deaths_malaysia
CREATE TABLE IF NOT EXISTS deaths_malaysia (
date DATE PRIMARY KEY,
deaths_new int NOT NULL
);

--create table deaths_state
CREATE TABLE IF NOT EXISTS deaths_state (
date DATE NOT NULL PRIMARY KEY, 
Johor INT, 
Kedah INT, 
Kelantan INT, 
Melaka INT, 
NegeriSembilan INT, 
Pahang INT, 
Perak INT, 
Perlis INT, 
PulauPinang INT, 
Sabah INT, 
Sarawak INT, 
Selangor INT, 
Terengganu INT,
WPKualaLumpur INT, 
WPLabuan INT, 
WPPutrajaya INT,
Total INT
);
