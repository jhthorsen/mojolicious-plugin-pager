package Mojolicious::Plugin::Pager;
use Mojo::Base 'Mojolicious::Plugin';

use constant PAGE_PARAM  => 'pager.page_param_name';
use constant WINDOW_SIZE => 'pager.window_size';

our $VERSION = '0.01';

sub pager_link {
  my ($c, $page, @args) = @_;
  my $url = $c->url_with->query($c->stash(PAGE_PARAM) => $page->{n} || 1);
  my @text = ref @args eq 'CODE' ? () : ($page->{n});
  my @classes;

  push @classes, 'active' if $page->{current};
  push @classes, 'first'  if $page->{first};
  push @classes, 'last'   if $page->{last};
  push @classes, 'next'   if $page->{next};
  push @classes, 'prev'   if $page->{prev};
  push @classes, 'page' unless @classes;

  return $c->link_to(@text, $url, class => join(' ', @classes), @args);
}

sub pages_for {
  my $c            = shift;
  my $args         = ref $_[0] ? shift : {total_pages => shift || 1};
  my $current_page = $args->{current} || $c->param($c->stash(PAGE_PARAM)) || 1;
  my $pager_size   = $args->{size} || 8;
  my $window_size  = ($pager_size / 2) - 1;
  my $total_pages  = int $args->{total_pages};
  my ($start_page, @pages);

  if ($current_page < $window_size) {
    $start_page = 1;
  }
  elsif ($current_page + $pager_size - $window_size > $total_pages) {
    $start_page = 1 + $total_pages - $pager_size;
  }
  else {
    $start_page = 1 + $current_page - $window_size;
  }

  for my $n ($start_page .. $total_pages) {
    last if @pages >= $pager_size;
    push @pages, {n => $n};
    $pages[-1]{first}   = 1 if $n == 1;
    $pages[-1]{last}    = 1 if $n == $total_pages;
    $pages[-1]{current} = 1 if $n == $current_page;
  }

  return @pages unless @pages;

  if ($current_page > 1) {
    unshift @pages, {prev => 1, n => $current_page - 1};
  }
  if ($current_page < $total_pages) {
    push @pages, {next => 1, n => $current_page + 1};
  }

  return @pages;
}

sub register {
  my ($self, $app, $config) = @_;

  $app->defaults(PAGE_PARAM,  $config->{param_name}  || 'page');
  $app->defaults(WINDOW_SIZE, $config->{window_size} || 3);

  $app->helper(pager_link => \&pager_link);
  $app->helper(pages_for  => \&pages_for);
}

1;
