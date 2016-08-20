package Eixo::Distribution::ImageManifest;

use strict;
use Eixo::Base::Clase 'Eixo::Distribution::Product';

use Eixo::Distribution::Layer;

has(

    schemaVersion=>undef,

    mediaType=>undef,

    config=>undef,

    name=>undef,

    layers=>undef,
);

sub initialize{
    my ($self, %args) = @_;

    $self->config({});
    $self->layers([]);

    $self->SUPER::initialize(%args);

    $self->layers([map {

        Eixo::Distribution::Layer->new(

            %{$_},

            api=>$self->api

        );         
   
    } @{$self->layers}]);

}

sub delete{
    my ($self, $manifest, %args) = @_;

    $args{name} = $args{name} || $self->name ||
        $self->error("MANIFEST:DELETE: a name is needed");
    
    unless($manifest){
        $self->error("MANIFEST:DELETE: a manifest digest is needed");
    }

    $args{reference} = $manifest;

    $self->api->deleteV2(

        args=>\%args,

        uri_mask=>"/v2/:name/manifests/:reference",

        __callback => sub {

            #print Dumper($_[0]); use Data::Dumper;
        }

    );
}

sub layersDisgest{
    
    my @layers_digest = map {
        $_->{digest}
    } @{$_[0]->layers};

    wantarray ? @layers_digest : \@layers_digest;
}

sub totalSize{

    my $s = 0;

    $s += $_ foreach(map {
        $_->{size}
    } @{$_[0]->layers});

    $s;
}


1;
