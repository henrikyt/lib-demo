#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib/";
use JSON;


print qq(Content-type: application/json\n\n);

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
