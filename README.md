# What is mojo-budget?
Mojo-Budget is a web application to keep track of your daily budget and
expenses. It is designed to be easy to host, and it uses SQLite as a data store.

# How to deploy / run?
You can run the application locally, or chuck it on a server and run it with
CGI. It can run on pretty much every environment that can run Perl.

# How to test?
Go to the project directory and run `prove`. Each test file should run the
application with an in-memory database, and run through the tests.

All the tests should pass. If any of the tests fail, this means there's
something wrong with either the code or the test. If you run into such tests,
please send a bug report.

# Contributing
Code and documentation contributions are both welcome. If you would like to
upstream some code, you can create a pull request on GitHub or send a patch to
`mojobudget-dev at gkbrk.com`.

Every PR should run the test suite to see if any functionality was
broken. Additionally; if you have added new functionality, they should be
accompanied by new tests.
