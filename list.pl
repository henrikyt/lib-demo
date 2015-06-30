#!/usr/bin/perl

use strict;
use warnings;

print qq(Content-type: application/json\n\n);

use JSON qw( );
use lib qw(..);

##DB##
my $filename = 'db.json';
my $json_text = do {
   open(my $json_fh, "<:encoding(UTF-8)", $filename)
      or die("Can't open \$filename\": $!\n");
   local $/;
   <$json_fh>
};
my $json = JSON->new;
my $data = $json->decode($json_text);
####

my $out = $json->encode($data);


print $out;
