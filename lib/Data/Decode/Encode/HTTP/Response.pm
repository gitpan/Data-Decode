# $Id: /mirror/perl/Data-Decode/trunk/lib/Data/Decode/Encode/HTTP/Response.pm 4839 2007-11-03T11:11:34.419356Z daisuke  $
#
# Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Data::Decode::Encode::HTTP::Response;
use strict;
use warnings;
use Data::Decode::Exception;
use Encode();
use HTTP::Response::Encoding;

sub new { bless {}, shift }

sub decode
{
    my ($self, $decoder, $string, $hints) = @_;

    if (! $hints->{response} || ! eval { $hints->{response}->isa('HTTP::Response') }) {
        Data::Decode::Exception::Deferred->throw;
    }

    my $encoding = $self->get_encoding($hints->{response});
    if (! $encoding) {
        Data::Decode::Exception::Deferred->throw;
    }
    return Encode::decode( $encoding, $string );
}

sub get_encoding
{
    my ($self, $res) = @_;
    my @encoding = (
        $res->encoding, 
        ( $res->header('Content-Type') =~ /charset=([\w\-]+)/g),
        "latin-1"
    );
    my $encoding;
    for $encoding (@encoding) {
        next unless defined $encoding;
        next unless Encode::find_encoding($encoding);
        last;
    }
    return $encoding;
}

1;

__END__

=head1 NAME

Data::Decode::Encode::HTTP::Response - Get Encoding Hints From HTTP::Response

=head1 METHODS

=head2 new

=head2 decode

=head2 get_encoding

=cut