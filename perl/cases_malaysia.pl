#!/usr/bin/perl

use strict;
use warnings;
use PerlIO::http;
use Text::CSV;
use Config::IniFiles;
use DBI;

# MySQL database configurations and connection
my $cfg = Config::IniFiles -> new( -file => '/opt/covid19_public/database_config.ini' );
my $dbdriver = $cfg -> val( 'DATABASE', 'DBDRIVER' );
my $dbinst = $cfg -> val( 'DATABASE', 'DBINST' );
my $dbuser = $cfg -> val( 'DATABASE', 'DBUSER' );
my $dbpass = $cfg -> val( 'DATABASE', 'DBPASS' );
 
my $dsn = "DBI:$dbdriver:database=$dbinst";
my $dbh = DBI->connect($dsn, $dbuser, $dbpass ) or die "Database connection not made: $DBI::errstr";

my $file = "https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_malaysia.csv";
open my $fh, "<:http", $file or die "$file: $!";

my $csv = Text::CSV->new
({
sep_char => ',',
binary    => 1, # Allow special character. Always set this
auto_diag => 1, # Report irregularities immediately
});

my $header = $csv->getline ($fh);  #skip header display
#print join("\t", @$header), "\n\n"; #enable this to view headers

while (my $row = $csv->getline ($fh))
{
#print "@$row\n";
my $sql = "INSERT INTO cases_malaysia  (date, cases_new, cluster_import, cluster_religious, cluster_community, cluster_highRisk, cluster_education, 
			cluster_detentionCentre, cluster_workplace ) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) 
			ON DUPLICATE KEY UPDATE
			cases_new = VALUES(cases_new), cluster_import= VALUES(cluster_import), cluster_religious = VALUES(cluster_religious), cluster_community = VALUES(cluster_community), 
			cluster_highRisk = VALUES(cluster_highRisk),
			cluster_education = VALUES(cluster_education),
			cluster_detentionCentre = VALUES(cluster_detentionCentre),
			cluster_workplace = VALUES(cluster_workplace)";

my $statement = $dbh->prepare($sql);

# execute your SQL statement
$statement->execute($row->[0], $row->[1], $row->[2] || 0, $row->[3] || 0, $row->[4] || 0, $row->[5] || 0, $row->[6] || 0, $row->[7] || 0, $row->[8] || 0) or die $DBI::errstr;
$statement->finish();

}

close $fh;
$dbh->disconnect();
