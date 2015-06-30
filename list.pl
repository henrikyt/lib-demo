#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib/";
use JSON;
use Encode;

print qq(Content-type: application/json\n\n);

##DB##
my $filename = 'db.json';
my $json_text = do {
   open(my $json_fh, "<", $filename)
      or die("Can't open \$filename\": $!\n");
   local $/;
   <$json_fh>
};
print $json_text;
