use strict;
use File::Spec;
use Test::More (tests => 13);

BEGIN
{
    use_ok("Data::Decode");
    use_ok("Data::Decode::Encode::HTTP::Response");
}
use Encode;
use HTTP::Response;

my $decoder = Data::Decode->new(
    strategy => Data::Decode::Encode::HTTP::Response->new
);
ok($decoder);
isa_ok($decoder, "Data::Decode");
isa_ok($decoder->decoder, "Data::Decode::Encode::HTTP::Response");

# Make sure that we can decode everything that has charset specs in 
# the meta tags, and from content-type
my $response;
foreach my $encoding qw(euc-jp shiftjis 7bit-jis utf8) {
    my $file = File::Spec->catfile("t", "encode", "data", "$encoding.txt");
    open(DATAFILE, $file) or die "Could not open file $file: $!";

    my $string = do { local $/ = undef; <DATAFILE> };

    $response = HTTP::Response->new(
        200,
        "OK", 
        undef,
        qq{<html><head><meta http-equiv="Content-Type" content="text/html; charset=$encoding"></head><body>$string</body></html>}
    );
    
    is($decoder->decode($string, { response => $response }), Encode::decode($encoding, $string), "META charset=$encoding");

    $response = HTTP::Response->new(
        200,
        "OK",
        HTTP::Headers->new( Content_Type => "text/html; charset=$encoding" ),
        qq{<html><head><meta http-equiv="Content-Type" content="text/html; charset=$encoding"></head><body>$string</body></html>}
    );
        
    is($decoder->decode($string, { response => $response }), Encode::decode($encoding, $string), "Header charset=$encoding");
}