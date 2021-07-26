#!/usr/bin/perl

use strict;
use warnings;
use Config::IniFiles;
use DBI;
use LWP::UserAgent;
use Text::CSV;

# MySQL database configurations and connection
my $cfg = Config::IniFiles -> new( -file => '/opt/covid19_public/database_config.ini' );
my $dbdriver = $cfg -> val( 'DATABASE', 'DBDRIVER' );
my $dbinst = $cfg -> val( 'DATABASE', 'DBINST' );
my $dbhost = $cfg -> val( 'DATABASE', 'DBHOST' );
my $dbuser = $cfg -> val( 'DATABASE', 'DBUSER' );
my $dbpass = $cfg -> val( 'DATABASE', 'DBPASS' );

my $url = "https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_state.csv";
my $ua = LWP::UserAgent->new();
my $response = $ua->get($url);

if ($response->is_error) 
{
	die $response->status_line;
}
else 
{
	#print $response->decoded_content;
	open my $fh, "<:encoding(utf8)", \$response->decoded_content or die "$response->decoded_content: $!";
	
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

	my $id=0;
	while (my $row = $csv->getline ($fh))
	{
		#print "@$row\n";
		$id++;
		my $sql = "INSERT INTO cases_state (id, date, state, cases_new ) 
					VALUES (?, ?, ?, ?)
					ON DUPLICATE KEY UPDATE 
					date = VALUES(date), state = VALUES(state), cases_new = VALUES(cases_new)";
					
		my $statement = $dbh->prepare($sql);
		
		$row->[2] =~ s/\D+//g;
		
		# execute your SQL statement
		$statement->execute($id, $row->[0], $row->[1], $row->[2] || 0) or die $DBI::errstr;
		$statement->finish();
	}
	
	close $fh;
	$dbh->disconnect();
}
