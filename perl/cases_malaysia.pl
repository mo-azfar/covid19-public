#!/usr/bin/perl

use strict;
use warnings;
use Config::IniFiles;
use DBI;
use PerlIO::http;
use Text::CSV;

# MySQL database configurations and connection
my $cfg = Config::IniFiles -> new( -file => '/opt/covid19_public/database_config.ini' );
my $dbdriver = $cfg -> val( 'DATABASE', 'DBDRIVER' );
my $dbinst = $cfg -> val( 'DATABASE', 'DBINST' );
my $dbhost = $cfg -> val( 'DATABASE', 'DBHOST' );
my $dbuser = $cfg -> val( 'DATABASE', 'DBUSER' );
my $dbpass = $cfg -> val( 'DATABASE', 'DBPASS' );
 
my $url = "https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_malaysia.csv";
open my $fh, '<:http', $url or die "$url: $!";
    	
my $csv = Text::CSV->new
({
sep_char => ',',
binary    => 1, # Allow special character. Always set this
auto_diag => 1, # Report irregularities immediately
});

my $header = $csv->getline($fh);  #skip header display
#print join("\t", @$header), "\n\n"; #enable this to view headers

#open db connection
my $dsn = "DBI:$dbdriver:database=$dbinst;host=$dbhost";
my $dbh = DBI->connect($dsn, $dbuser, $dbpass ) or die "Database connection not made: $DBI::errstr";

while (my $row = $csv->getline($fh))
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
	
	$row->[1] =~ s/\D+//g;
	$row->[2] =~ s/\D+//g;
	$row->[3] =~ s/\D+//g;
	$row->[4] =~ s/\D+//g;
	$row->[5] =~ s/\D+//g;
	$row->[6] =~ s/\D+//g;
	$row->[7] =~ s/\D+//g;
	$row->[8] =~ s/\D+//g;
	
	# execute your SQL statement
	$statement->execute($row->[0], $row->[1] || 0, $row->[2] || 0, $row->[3] || 0, $row->[4] || 0, $row->[5] || 0, $row->[6] || 0, $row->[7] || 0, $row->[8] || 0) or die $DBI::errstr;
	$statement->finish();
	
}
close $fh;
$dbh->disconnect();

