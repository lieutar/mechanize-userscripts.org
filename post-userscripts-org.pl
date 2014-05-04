#! /usr/bin/perl

use strict;
use warnings;
use 5.01;

use utf8;
use open ':std', ':encoding(UTF-8)';

use WWW::Mechanize;
use JSON::Syck;
use Data::Dumper;
use Path::Class;

use Getopt::Long;

my $BASE        = 'http://userscripts.org';
my $LOGIN       = "$BASE/login";
my $LIST        = "$BASE/home/scripts";
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
  my ($mec) = @_;
  $mec->get($LIST);

  my @links = $mec->find_all_links(
                                    url_regex => qr/\/scripts\/show\//
                                  );

  while (my ($i, $el) = each @links) {
    my $id = do { (my $tmp = $el->url) =~ s/\/scripts\/show\///; $tmp };
    my $name = $el->text;
    printf("%8s",$id);
    say ' ‒ ',$name;
  }
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

  continue_or_die($mec);  # alpha test (goal: warn user)

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
  continue_or_die($mec);  # alpha test (goal: warn user)
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

continue_or_die($mec);

sub continue_or_die{

  my ($mec) = @_;

  use HTML::DOM;

  my $dom = HTML::DOM->new;
  $dom->write( $mec->content() );
  $dom->close;

  # login error
  my $error = $dom->getElementsByClassName('notice error')->[0];
  if ( $error ) {
    use HTML::StripTags qw(strip_tags);
    my $allowed_tags = '';  # ex.: '<u><b>'
    say strip_tags( $error->innerHTML , $allowed_tags );
    exit;
  }

  # file send error
  $error = $dom->getElementById('errorExplanation');
  if ( $error ) {
    use HTML::FormatText;
    my $formatter = HTML::FormatText->new(
                                          leftmargin => 2,
                                          rightmargin => 80
                                         );
    say "\n".$formatter->format_string($error->innerHTML);
    exit;
  }
}

if ( @ARGV < 1 )
{
  list($mec);
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

