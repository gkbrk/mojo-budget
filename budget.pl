#!/usr/bin/env perl

# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/

use Mojolicious::Lite;
use Mojo::SQLite;

app->sessions->cookie_name('budget-app');

helper sqlite => sub {
    my $c = shift;
    my $db_path = $c->db_path;
    state $sql = Mojo::SQLite->new("sqlite:$db_path");
};

helper db_path => sub {
    return $ENV{BUDGET_DB};
};

helper password => sub {
    return $ENV{BUDGET_PASSWORD};
};

get '/login' => 'login';

post '/login' => sub {
    my $c = shift;
    if ($c->param('password') eq $c->password) {
        $c->session->{loggedIn} = 1;
        $c->redirect_to('/');
    } else {
        $c->session->{loggedIn} = 0;
        $c->render(text => 'Wrong password');
    }
};

under sub {
    my $c = shift;
    return 1 if $c->session->{loggedIn};
    $c->redirect_to('/login');
    return undef;
};

get '/' => sub {
    my $c = shift;
    my $query = 'select * from Transactions t order by t.Date desc limit 20';
    my @transactions = $c->sqlite->db->query($query);
    $c->render(template => 'index', transactions => @transactions);
};

get '/transaction/new' => 'addform';

post '/transaction/new' => sub {
    my $c = shift;
    my $amount = $c->param('amount');
    my $description = $c->param('description');
    my $category = $c->param('category');
    my $date = $c->param('date');
    my $db = $c->sqlite->db;
    $db->insert('Transactions', {
        Date        => $date,
        Description => $description,
        Category    => $category,
        Amount      => $amount,
        Currency    => 'EUR'
    });
    return $c->redirect_to('/');
};

post '/transaction/delete/:id' => sub {
    my $c = shift;
    my $db = $c->sqlite->db;
    $db->delete('Transactions', {ID => $c->param('id')});
    return $c->redirect_to('/');
};

get '/stats' => sub {
    my $c = shift;
    $c->render(text => 'lel');
};

get '/recreateDatabase' => sub {
    my $c = shift;
    $c->sqlite->migrations->name('install')->from_string(<<EOF)->migrate;
-- 1 up
create table Transactions (ID integer primary key,
                           Date text not null,
                          Description text not null,
                          Category text not null,
                          Amount text not null,
                          Currency text not null);
-- 1 down
drop table Transactions;
EOF
    $c->sqlite->migrations->migrate(0)->migrate;
    $c->render(text => 'Database created successfully');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'layout', title => 'Home Page';
    <h1>Last 20 transactions</h1>
    <div class="row" style="margin-bottom: 2em;">
        <div class="col">
            %= link_to Add => '/transaction/new' => (class => 'btn btn-primary btn-block')
        </div>
        <div class="col"><a href="#" class="btn btn-primary btn-block">Stats</a></div>
    </div>
    % while (my $transaction = $transactions->hash) {
    <div class="row" style="margin-bottom: 1em;">
        <div class="card w-100">
            <div class="card-header">
                %= $transaction->{Category}
            </div>
            <div class="card-body">
                <p><b>Description:</b> <%= $transaction->{Description} %></p>
                <p><b>Date:</b> <%= $transaction->{Date} %></p>
            </div>
            <div class="card-footer">
                <div>
                    %= button_to Delete => 'transactiondeleteid' => {id => $transaction->{ID}}
                    <div class="float-right">
                        %= $transaction->{Amount}
                        %= $transaction->{Currency}
                    </div>
                </div>
            </div>
        </div>
    </div>
    % }

@@ login.html.ep
% layout 'layout', title => 'Log in';
<h1>Login</h1>
<form method="post">
    <label for="password">Password:</label>
    <input type="password" id="password" name="password">
    <input type="submit" value="Log in">
</form>

@@ addform.html.ep
% layout 'layout', title => 'Add new transaction';
% use Time::Piece;
<h1>Add new transaction</h1>
<form method="post">
    <div class="form-group">
        <label for="amount">Amount</label>
        <input type="number" class="form-control" id="amount" name="amount">
    </div>
    <div class="form-group">
        <label for="description">Description</label>
        <input type="text" class="form-control" id="description" name="description">
    </div>
    <div class="form-group">
        <label for="category">Category</label>
        <select name="category" id="category">
            <option value="Food">Food</option>
            <option value="Transport">Transport</option>
        </select>
        <input type="text" class="form-control" id="category" name="category">
    </div>
    <div class="form-group">
        <label for="amount">Date</label>
        <input type="text" class="form-control" id="date" name="date" value="<%= localtime->ymd %>">
    </div>
    <button type="submit" class="btn btn-primary">Add</button>
</form>

@@ layouts/layout.html.ep
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title><%= $title %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet"
    href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
    integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T"
    crossorigin="anonymous">
  </head>
  <body>
    <div class="container">
      <%= content %>
    </div>
  </body>
</html>
