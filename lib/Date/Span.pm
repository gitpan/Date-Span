
package Date::Span;
our $VERSION = '1.10';

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(range_expand range_durations);

=head1 NAME

Date::Span -- deal with date/time ranges than span multiple dates

=head1 VERSION

version 1.10

 $Id: Span.pm,v 1.5 2004/08/23 12:59:22 rjbs Exp $

=head1 SYNOPSIS

 use Date::Span;

 @spanned = range_expand($start, $end);

 print "from $_->[0] to $_->[1]\n" for (@spanned);

=cut

=head1 DESCRIPTION

This module provides code for dealing with datetime ranges that span multiple
calendar days.  This is useful for computing, for example, the amount of
seconds spent performing a task on each day.  Given the following table:

  event   | begun            | ended
 ---------+------------------+------------------
  loading | 2004-01-01 00:00 | 2004-01-01 12:45
  venting | 2004-01-01 12:45 | 2004-01-02 21:15
  running | 2004-01-02 21:15 | 2004-01-03 00:00

We may want to gather the following data:

  date       | event   | time spent
 ------------+---------+----------------
  2004-01-01 | loading | 12.75 hours
  2004-01-01 | venting | 11.25 hours
  2004-01-02 | venting | 21.25 hours
  2004-01-02 | running |  2.75 hours

Date::Span takes a data like the first and produces data more like the second.
(Details on exact interface are below.)

=cut

use strict;
use warnings;

=head1 FUNCTIONS

=over

=item C<< range_durations($start, $end) >>

Given C<$start> and C<$end> as timestamps (in epoch seconds),
C<range_durations> returns a list of arrayrefs.  Each arrayref is a date
(expressed as epoch seconds at midnight) and the number of seconds for which
the given range intersects with the date.

=cut

sub range_durations {
	my ($start, $end) = @_;
	return if $end < $start;
	my @results;

	my $start_date = $start - (my $start_time = $start % 86400);
	my $end_date   =   $end - (my   $end_time =   $end % 86400);

	push @results,
		[ $start_date, ( ( $end_date != $start_date ) ? ( 86400 - $start_time ) : ($end - $start) ) ];

	if ($start_date+86400 < $end_date) {
		push @results, 
			map { [ $start_date + 86400 * $_, 86400 ] }
			(1 .. ($end_date - $start_date - 86400) / 86400);
	}

	push @results, [ $end_date, $end_time ] if $start_date != $end_date;

	return @results;
}

=item C<< range_expand($start, $end) >>

Given C<$start> and C<$end> as timestamps (in epoch seconds),
C<range_durations> returns a list of arrayrefs.  Each arrayref is a start and
end timestamp.  No pair of start and end times will cross a date boundary, and
the set of ranges as a whole will be identical to the passed start and end.

=cut

sub range_expand {
	my ($start, $end) = @_;
	return if $end < $start;
	my @results;

	my $start_date = $start - (my $start_time = $start % 86400);
	my $end_date   =   $end - (my   $end_time =   $end % 86400);

	push @results,
		[ $start, ( ( $end_date != $start_date ) ? ( $start_date + 86399 ) : $end ) ];

	if ($start_date+86400 < $end_date) {
		push @results, 
			map { [ $start_date + 86400 * $_, $start_date + 86400 * $_ + 86399 ] }
			(1 .. ($end_date - $start_date - 86400) / 86400);
	}

	push @results, [ $end_date, $end ] if $start_date != $end_date;

	return @results;
}

=back

=head1 TODO

This code was just yanked out of a general purpose set of utility functions
I've compiled over the years.  It should be refactored (internally) and
further tested.  The interface should stay pretty stable, though.

=head1 AUTHORS

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004, Ricardo SIGNES.
Date::Span is available under the same terms as Perl itself. 

=cut

1;
