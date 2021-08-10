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

my $url = "https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_state.csv";
open my $fh, '<:http', $url or die "$url: $!";
	
my $csv = Text::CSV->new
({
sep_char => ',',
binary    => 1, # Allow special character. Always set this
auto_diag => 1, # Report irregularities immediately
});

my $header = $csv->getline ($fh);  #skip header display
#print join("\t", @$header), "\n\n"; #enable this to view headers

#open DB connection
my $dsn = "DBI:$dbdriver:database=$dbinst;host=$dbhost";
my $dbh = DBI->connect($dsn, $dbuser, $dbpass ) or die "Database connection not made: $DBI::errstr";

#reset total
my $pre_sql = "UPDATE cases_state SET Total = ?";
my $pre_statement = $dbh->prepare($pre_sql);

# execute your preSQL statement
$pre_statement->execute( 0 ) or die $DBI::errstr;
$pre_statement->finish();
  
while (my $row = $csv->getline ($fh))
{
	$row->[1] =~ s/[^a-zA-Z]+//g; #state
	$row->[2] =~ s/\D+//g; #cases
	
	my $sql = "INSERT INTO cases_state ( date, $row->[1], Total ) 
				VALUES (?, ?, ?)
				ON DUPLICATE KEY UPDATE 
				$row->[1]=$row->[2], Total=Total+$row->[2]";
				
	my $statement = $dbh->prepare($sql);

	# execute your SQL statement
	$statement->execute( $row->[0], $row->[2], $row->[2] ) or die $DBI::errstr;
	$statement->finish();
}

close $fh;
$dbh->disconnect();
