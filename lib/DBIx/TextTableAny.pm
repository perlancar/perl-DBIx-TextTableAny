package DBIx::TextTableAny;

# DATE
# VERSION

use strict;
use warnings;
use Text::Table::Any;

our %opts;

sub import {
    my $class = shift;

    %opts = @_;
}

package
    DBI::db;

sub selectrow_texttable {
    my $self = shift;
    my $statement = shift;

    my $sth = $self->prepare($statement);
    $sth->execute;

    Text::Table::Any::table(
        %DBIx::TextTableAny::opts,
        rows => [
            $sth->{NAME},
            $sth->fetchrow_arrayref,
        ],
    );
}

sub selectall_texttable {
    my $self = shift;
    my $statement = shift;

    my $sth = $self->prepare($statement);
    $sth->execute;

    Text::Table::Any::table(
        %DBIx::TextTableAny::opts,
        rows => [
            $sth->{NAME},
            @{ $sth->fetchall_arrayref },
        ],
    );
}

package
    DBI::st;

sub fetchrow_texttable {
    my $self = shift;

    Text::Table::Any::table(
        %DBIx::TextTableAny::opts,
        rows => [
            $self->{NAME},
            $self->fetchrow_arrayref,
        ],
    );
}

sub fetchall_texttable {
    my $self = shift;

    Text::Table::Any::table(
        %DBIx::TextTableAny::opts,
        rows => [
            $self->{NAME},
            @{ $self->fetchall_arrayref },
        ],
    );
}

1;
# ABSTRACT: Generate text table from SQL query result using Text::Table::Any

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use DBI;
 use DBIx::TextTableAny;
 my $dbh = DBI->connect("dbi:mysql:database=mydb", "someuser", "somepass");

Selecting a row:

 print $dbh->selectrow_texttable("SELECT * FROM member");

Sample result (default backend is L<Text::Table::Tiny>):

 +-------+----------+----------+
 | Name  | Rank     | Serial   |
 +-------+----------+----------+
 | alice | pvt      | 123456   |
 +-------+----------+----------+

Selecting all rows:

 print $dbh->selectrow_texttable("SELECT * FROM member");

Sample result:

 +-------+----------+----------+
 | Name  | Rank     | Serial   |
 +-------+----------+----------+
 | alice | pvt      | 123456   |
 | bob   | cpl      | 98765321 |
 | carol | brig gen | 8745     |
 +-------+----------+----------+

Picking another backend (and setting other options):

 use DBIx::TextTableAny backend => 'Text::Table::CSV', header_row => 0;

 my $sth = $dbh->prepare("SELECT * FROM member");
 $sth->execute;

 print $sth->fetchall_texttable;

Sample result (note that we instructed the header row to be omitted):

 "alice","pvt","123456"
 "bob","cpl","98765321"
 "carol,"brig gen","8745"

If you want to change backend/options for subsequent tables, you can do this:

 DBIx::TextTableAny->import(backend => 'Text::Table::TSV', header_row => 0);
 print $dbh->selectrow_texttable("more query ...");

or:

 $DBIx::TextTableAny::opts{header_row} = 0; # you can just change one option
 print $dbh->selectrow_texttable("more query ...");


=head1 DESCRIPTION

This package is a thin glue between L<Text::Table::Any> and L<DBI>. It adds the
following methods to database handle:

 selectrow_texttable
 selectall_texttable

as well as the following methods to statement handle:

 fetchrow_texttable
 fetchall_texttable

The methods send the result of query to Text::Table::Any and return the rendered
table.

In essence, this is an easy, straightforward way produce text tables from SQL
query. You can generate CSV, ASCII table, or whatever format the
Text::Table::Tiny backend happens to support.


=head1 SEE ALSO

L<DBI::Format>
