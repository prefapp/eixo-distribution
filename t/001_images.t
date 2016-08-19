use strict;
use Test::More;

use_ok("Eixo::Distribution::Api");
use_ok("Eixo::Distribution::Image");

use t::mockup_distribution;

my $d = Eixo::Distribution::Api->new(

    "http://172.17.0.1:5000/"

);
ok(ref($d->images->list) eq 'ARRAY', "A list of images/repositories has been delivered");

my $list = $d->images->list;

ok(ref ($d->images->tags(name=>$list->[0])) eq 'ARRAY', "a list of tags is retrievable");

my $i = $d->images->get(name=>'foo/imagen', reference=>"latest");

ok(

    $i->layerExists($i->manifest->fsLayersDisgest->[0]),

    "Layer exists"

);

ok(

    !$i->layerExists("sha256:foo"),

    "Layer doesn't exist"

);

$i->layerDelete($i->manifest->fsLayersDisgest->[0]);

ok(

    !$i->layerExists($i->manifest->fsLayersDisgest->[0]),

    "Layer has been deleted"

);

<STDIN>;
#
##print Dumper($i);

use Data::Dumper;

#print Dumper($i);

done_testing;

