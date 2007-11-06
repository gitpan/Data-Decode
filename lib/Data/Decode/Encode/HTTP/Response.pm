# $Id: /mirror/perl/Data-Decode/trunk/lib/Data/Decode/Encode/HTTP/Response.pm 8610 2007-11-06T07:46:36.901340Z daisuke  $
#
# Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Data::Decode::Encode::HTTP::Response;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Data::Decode::Exception;
use Encode();
use HTTP::Response::Encoding;

__PACKAGE__->mk_accessors($_) for qw(_parser);

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

sub parser
{
    my $self = shift;
    my $parser = $self->_parser();
    if (! $parser) {
        require Data::Decode::Encode::HTTP::Response::Parser;
        $parser = Data::Decode::Encode::HTTP::Response::Parser->new();
        $self->_parser($parser);
    }
    return $parser;
}

sub _pick_encoding
{
    my $self = shift;
    for my $e (@_) {
        next unless defined $e;
        next unless Encode::find_encoding($e);
        return $e;
    }
    return ();
}

sub get_encoding
{
    my ($self, $res) = @_;

    my $encoding;
    { # Attempt to decode from meta information
        my $p = $self->parser();

        $encoding = $self->_pick_encoding(
            $p->extract_encodings( $res->content )
        );


        return $encoding if $encoding;
    }


    { # Attempt to decode from header information
        $encoding = $self->_pick_encoding(
            $res->encoding, 
            ( ($res->header('Content-Type') || '') =~ /charset=([\w\-]+)/g),
        );
        return $encoding if $encoding;
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

=head2 parser

=cut