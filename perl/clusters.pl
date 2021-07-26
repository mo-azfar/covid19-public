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
 
my $url = "https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/clusters.csv";

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
	my $sql = "INSERT INTO clusters  (cluster, state, district, date_announced, date_last_onset, category, status, cases_new, cases_total, cases_active,
				tests, icu, deaths, recovered) 
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) 
				ON DUPLICATE KEY UPDATE
				state = VALUES(state), district = VALUES(district), date_announced = VALUES(date_announced), date_last_onset = VALUES(date_last_onset), 
				category = VALUES(category),
				status = VALUES(status),
				cases_new = VALUES(cases_new),
				cases_total = VALUES(cases_total),
				cases_active = VALUES(cases_active),
				tests = VALUES(tests),
				icu = VALUES(icu),
				deaths = VALUES(deaths),
				recovered = VALUES(recovered)";
	
	my $statement = $dbh->prepare($sql);
	
	$row->[7] =~ s/\D+//g;
	$row->[8] =~ s/\D+//g;
	$row->[9] =~ s/\D+//g;
	$row->[10] =~ s/\D+//g;
	$row->[11] =~ s/\D+//g;
	$row->[12] =~ s/\D+//g;
	$row->[13] =~ s/\D+//g;
	
	# execute your SQL statement
	$statement->execute($row->[0], $row->[1], $row->[2], $row->[3], $row->[4], $row->[5], $row->[6], $row->[7] || 0, $row->[8] || 0, $row->[9] || 0, 
	$row->[10] || 0, $row->[11] || 0, $row->[12] || 0, $row->[13] || 0) or die $DBI::errstr;
	$statement->finish();
	
}
close $fh;
$dbh->disconnect();

