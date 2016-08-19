package Eixo::Distribution::ImageManifest;

use strict;
use Eixo::Base::Clase;

has(

    name=>undef,

    tag=>undef,

    fsLayers=>undef,

    signatures=>undef,

    architecture=>undef,

    schemaVersion=>undef,

    history=>undef,
);

sub initialize{
    my ($self, %args) = @_;

    $self->fsLayers([]);
    $self->signatures([]);
    $self->history([]);

    $self->SUPER::initialize(%args);

}

sub fsLayersDisgest{
    
    my @d = map {

        $_->{blobSum}

    } values(@{$_[0]->fsLayers});

    wantarray ? @d : \@d;
}

1;
