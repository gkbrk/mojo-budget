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

$t->ua->max_redirects(10);

$t->post_ok('/login' => form => {password => '12345'})
    ->get_ok('/recreateDatabase');

$t->get_ok('/')
    ->status_is(200)
    ->content_unlike(qr/Test transaction/);

$t->app->sqlite->db->insert('Transactions', {
    Description => 'Test transaction',
    Category => 'Food',
    Amount => '12.34',
    Date => '2019-01-01',
    Currency => 'EUR'
});

$t->get_ok('/')
    ->status_is(200)
    ->content_like(qr/Test transaction/);

$t->post_ok('/transaction/delete/1')
    ->status_is(200)
    ->content_unlike(qr/Test transaction/);

done_testing();
