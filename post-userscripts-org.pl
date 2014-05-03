#! /usr/bin/perl

use strict;
use warnings;
use 5.01;

use WWW::Mechanize;
use JSON::Syck;
use Data::Dumper;
use Path::Class;

use Getopt::Long;

my $BASE        = 'http://userscripts.org';
my $LOGIN       = "$BASE/login";
my $UPLOAD_NEW  = "$BASE/scripts/new";
my $UPDATE_BASE = "$BASE/scripts/upload";

my $ACCOUNTS_DB = file("$ENV{HOME}/.accounts.json");
my ($USERID,$PASSWORD) = do{
  my $acc = do{
    JSON::Syck::Load(join "",$ACCOUNTS_DB->slurp);
  };
  my $users = $acc->{'userscripts.org'};
  my $user = [keys %$users]->[0];
  my $info = $users->{$user};
  ($user, $info->{password});
};

sub usage
{
  print "Unknown option: @_\n" if ( @_ );
  print "usage: program [[ID] FILE] | [--help]\n";
}

sub list{
  say "not implemeted";
}

sub upload{
  my ($mec, %info) = @_;
  $mec->get($UPLOAD_NEW);

  $mec->submit_form(
                    form_number => 1,
                    fields => {
                               'script[src]' => $info{script}
                              }
                   );

  # TODO response validation?

  # TODO send metadata:

  $mec->submit_form(
                   );
}

sub update{
  my ($mec, %info) = @_;
  my $id  = $info{id};
  my $url =  "$UPDATE_BASE/$id";
  $mec->get($url);
  $mec->submit_form(
                    form_number => 1,
                    fields => {
                               src => $info{script}
                              }
                   );
}

my ($help);

if ( @ARGV > 2 or
      ! GetOptions('help' => \$help)
      or defined $help )
{
  usage();
  exit;
}

my $mec = WWW::Mechanize->new;

$mec->get( $LOGIN );
$mec->submit_form(
                  form_number => 1,
                  fields => {
                             login => $USERID,
                             password => $PASSWORD
                            }
                 );

# TODO treat login error

if ( @ARGV < 1 )
{
  list();
  exit;
}

if ( @ARGV == 1 )  # and !help
{
  my ($script) = @ARGV;
  upload($mec,
         script => "$ENV{PWD}/$script");
  exit;
}

if ( @ARGV == 2 )
{
  my ($id, $script) = @ARGV;
  update($mec,
         id     => $id,
         script => "$ENV{PWD}/$script");
  exit;
}

