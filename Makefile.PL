#!/usr/bin/env perl
use strict;
use warnings;
use inc::Module::Install;

version  '5.01';

name     'post-userscripts-org';

requires 'WWW::Mechanize';
requires 'JSON::Syck';
requires 'Data::Dumper';
requires 'Path::Class';

install_script 'post-userscripts-org.pl';

WriteAll;
