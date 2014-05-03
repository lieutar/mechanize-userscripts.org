#! /usr/bin/perl

use strict;
use warnings;
use 5.01;
use WWW::Mechanize;
use JSON::Syck;
use Data::Dumper;
use Path::Class;

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
                    form_number => 2,
                    fields => {
                               src => $info{script}
                              }
                   );
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

=comment
my ($id, $script) = @ARGV;
update($mec,
       id     => $id,
       script => $script);
=cut

my ($script) = @ARGV;
upload($mec,
       script => "$ENV{PWD}/$script");

