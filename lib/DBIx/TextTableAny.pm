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
 | bob   | cpl      | 98765321 |
 | carol | brig gen | 8745     |
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

 use DBIx::TextTableAny backend => 'Text::Table::CSV', header_row => 1;

 my $sth = $dbh->prepare("SELECT * FROM member");
 $sth->execute;

 print $sth->fetchall_texttable;

Sample result:

 Name,Rank,Serial
 alice,pvt,123456
 bob,cpl,98765321
 carol,"brig gen",8745


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
