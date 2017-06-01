use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

use Mojolicious::Lite;

plugin 'pager';
get
  '/' => {total_entries => 1431, entries_per_page => 20},
  'pager';

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200);
$t->get_ok('/?page=1')->status_is(200);

done_testing;

__DATA__
@@ pager.html.ep
<ul class="pager">
  % for my $page (pages_for $total_entries / $entries_per_page) {
    <li><%= pager_link $page %></li>
  % }
</ul>
