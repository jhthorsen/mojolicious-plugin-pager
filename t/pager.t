use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

use Mojolicious::Lite;

plugin 'pager';
get
  '/' => {total_entries => 1431, entries_per_page => 20},
  'pager';

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->element_exists_not('a.last')->element_exists_not('a.prev')
  ->element_exists_not('a[href="/page=8"]')->element_count_is('a', 9)
  ->element_exists('a[href="/?page=1"].first.active')->element_exists('a[href="/?page=2"].page')
  ->element_exists('a[href="/?page=8"].page')->element_exists('a[href="/?page=2"].next');

$t->get_ok('/?page=3')->status_is(200)->element_exists_not('a.last')
  ->element_exists_not('a[href="/page=9"]')->element_count_is('a', 10)
  ->element_exists('a[href="/?page=2"].prev')->element_exists('a[href="/?page=1"].first')
  ->element_exists('a[href="/?page=3"].active')->element_exists('a[href="/?page=8"].page')
  ->element_exists('a[href="/?page=4"].next');

$t->get_ok('/?page=4')->status_is(200)->element_exists_not('a.last')->element_exists_not('a.first')
  ->element_exists_not('a[href="/page=10"]')->element_count_is('a', 10)
  ->element_exists('a[href="/?page=3"].prev')->element_exists('a[href="/?page=4"].active')
  ->element_exists('a[href="/?page=9"].page')->element_exists('a[href="/?page=5"].next');

$t->get_ok('/?page=23')->status_is(200)->element_exists_not('a.last')
  ->element_exists_not('a.first')->element_exists_not('a[href="/page=29"]')
  ->element_count_is('a', 10)->element_exists('a[href="/?page=22"].prev')
  ->element_exists('a[href="/?page=23"].active')->element_exists('a[href="/?page=28"].page')
  ->element_exists('a[href="/?page=24"].next');

$t->get_ok('/?page=23')->status_is(200)->element_exists_not('a.last')
  ->element_exists_not('a.first')->element_exists_not('a[href="/page=29"]')
  ->element_count_is('a', 10)->element_exists('a[href="/?page=22"].prev')
  ->element_exists('a[href="/?page=23"].active')->element_exists('a[href="/?page=28"].page')
  ->element_exists('a[href="/?page=24"].next');

$t->get_ok('/?page=71')->status_is(200)->element_exists_not('a.first')
  ->element_exists_not('a.next')->element_exists_not('a[href="/page=72"]')
  ->element_count_is('a', 9)->element_exists('a[href="/?page=69"].page')
  ->element_exists('a[href="/?page=70"].prev')->element_exists('a[href="/?page=71"].active.last');

for my $p (63 .. 70) {
  $t->get_ok("/?page=$p")->status_is(200)->element_exists('a.next')->element_count_is('a', 10)
    ->element_exists(qq(a[href="/?page=$p"].active));
}

done_testing;

__DATA__
@@ pager.html.ep
<ul class="pager">
  % for my $page (pages_for $total_entries / $entries_per_page) {
    <li><%= pager_link $page %></li>
  % }
</ul>
