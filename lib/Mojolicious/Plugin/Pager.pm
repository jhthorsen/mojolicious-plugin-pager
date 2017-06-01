package Mojolicious::Plugin::Pager;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

sub pages_for {
  my ($c, $total_pages) = @_;
}

sub pager_link {
  my ($c, $page, @args) = @_;
}

sub register {
  my ($self, $app, $config) = @_;

  $app->helper(pages_for  => \&pages_for);
  $app->helper(pager_link => \&pager_link);
}

1;
