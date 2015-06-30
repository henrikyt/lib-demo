#!/usr/bin/perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/lib/";

use JSON;
use CGI;
use Graph::Undirected;
use Graph::D3;

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
our $db = $json->decode($json_text);
####

##GET VARS##
my $cqi = CGI->new();
my $selected = $cqi->param('start');
#$selected="Outokumpu";
our %weights=('green',$cqi->param('green'),'red',$cqi->param('red'),'blue',$cqi->param('blue'));
#%weights=('green',1,'red',1,'blue',1);
our $total=0;
our @path=$selected;
####

our $g0 = Graph::Undirected->new;
our @visited;
our @unvisited;

foreach (@{$db->{nodes}}) {
    $g0->add_vertex($_);
    push(@unvisited,$_);
}

@unvisited = grep { !/$selected/ } @unvisited;

foreach (@{$db->{edges}}) {
    $g0->add_weighted_edge($_->{start},$_->{end},$weights{$_->{'color'}});
    $g0->set_edge_attribute($_->{start},$_->{end},'value',$weights{$_->{'color'}});

}

while(scalar @unvisited > 0){#scalar $g0->vertices){
    $selected=move($selected);
}

my $d3 = new Graph::D3(graph => $g0, type => 'json');
my $out = $json->decode($d3->force_directed_graph());
push(@{$out->{'path'}},@path);
$out->{'total'} = $total;
print $json->encode($out);

sub move{
    my @n = $g0->neighbours($_[0]);
    foreach my $e (@n){
        if(grep( /^$e$/, @unvisited)){
            @unvisited = grep { !/$e/ } @unvisited;
            push(@path,$e);
            $total+=$g0->get_edge_weight($_[0],$e);
            return $e;
        }
    }
    # NO PATH
    my $sptg = $g0->SPT_Dijkstra($_[0]);
    my $near;
    my $val=-1;
    foreach(@unvisited){
        my $w = $sptg->get_vertex_attribute($_, 'weight');
        if(($val>$w) || ($val==-1)){
            $val=$w;
            $near=$_;
        }
    }
    my @newpath=$g0->SP_Dijkstra($_[0], $near);
    splice(@newpath,0,1);
    push(@path,@newpath);
    @unvisited = grep { !/$near/ } @unvisited;
    $total += $val;
    $val=-1;
    return $near;
}