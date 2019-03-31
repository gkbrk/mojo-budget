#!/usr/bin/env perl
use Test::More;
use Test::Mojo;

$ENV{BUDGET_DB} = ':memory:';
$ENV{BUDGET_PASSWORD} = '12345';
require './budget.pl';

sub url_is {
    my $t = shift;
    is($t->tx->req->url->path, shift);
}

my $t = Test::Mojo->new;

$t->get_ok('/')
    ->status_is(302);

$t->ua->max_redirects(10);

$t->get_ok('/')
    ->status_is(200);

url_is($t, '/login');

$t->post_ok('/login' => form => {password => 'wrongPass123'})
    ->content_like(qr/Wrong password/);

$t->post_ok('/login' => form => {password => '12345'});

url_is($t, '/');

$t->get_ok('/recreateDatabase')
    ->status_is(200);

$t->get_ok('/')
    ->status_is(200)
    ->content_like(qr/Last 20 transactions/);

done_testing();
