package Eixo::Distribution::Image;

use strict;
use Eixo::Base::Clase 'Eixo::Distribution::Product';

use Eixo::Distribution::ImageManifest;

has(

    manifest=>undef,

    layers=>undef,

);

sub initialize{
    my ($self, %args) = @_;

    $self->manifest(

        Eixo::Distribution::ImageManifest->new(

            %{$args{manifest_data} || {}}

        )

    );

    $self->layers([]);

    $self->SUPER::initialize(%args);

    $self;
}

sub get{
    my ($self, %args) = @_;

    $args{name} = $args{name} || $self->manifest->name ||
        $self->error("IMAGE::GET: name is needed");

    $args{reference} = $args{reference} || 
        $self->manifest->digest || 
            $self->manifest->tag || 
                $self->error("IMAGE::GET: a reference (tag|digest) is needed");


    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:name/manifests/:reference",

        __callback=>sub {

            $self->populate({

                manifest_data=>$_[0]

            });
        }

    );

}

sub layerDelete{
    my ($self, $layer, %args) = @_;

    $args{name} = $args{name} || $self->manifest->name ||
        $self->error("IMAGE:LAYER_DELETE: a name is needed");
    
    unless($layer){
        $self->error("IMAGE:LAYER_DELETE: a layer digest is needed");
    }

    $args{reference} = $layer; 
    
    $self->api->deleteV2(

        args=>\%args,
    
        uri_mask=>"/v2/:name/blobs/:reference",

        __callback=>sub {

           # print Dumper($_[0]); use Data::Dumper;

        }
    );
}

sub manifestDelete{
    my ($self, $manifest, %args) = @_;

    $args{name} = $args{name} || $self->manifest->name ||
        $self->error("IMAGE:MANIFEST_DELETE: a name is needed");
    
    unless($manifest){
        $self->error("IMAGE:MANIFEST_DELETE: a manifest digest is needed");
    }

    $self->api->deleteV2(

        args=>\%args,

        uri_mask=>"/v2/:name/manifests/:reference",

        __callback => sub {

            #print Dumper($_[0]); use Data::Dumper;
        }

    );
}

sub layerExists{
    my ($self, $layer, %args) = @_;

    $args{name} = $args{name} || $self->manifest->name ||
        $self->error("IMAGE:LAYER_EXISTS: a name is needed");
    
    unless($layer){
        $self->error("IMAGE:LAYER_EXISTS: a layer digest is needed");
    }

    $args{reference} = $layer; 
    $args{__format} = "RAW";

    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:name/blobs/:reference",
 
        onError=>sub {
            my ($error) = @_;

            if($error->status_line=~ /404/){
                return undef;
            }
            else{
                # format error
                die $error;
            }
        },   

        __callback => sub {

            return 1;
        }
    );
}

sub tags{
    my ($self, %args) = @_;

    $args{name} = $args{name} || $self->manifest->name ||
        $self->error("IMAGE::GET: name is needed");

    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:name/tags/list",

        __callback=>sub {

            $_[0]->{tags};

        }

    );
}


sub list{
    my ($self, %args) = @_;

    $self->api->getV2(

        uri_mask=>"/v2/_catalog",

        args=>\%args,

        __callback=> sub {

            $_[0]->{repositories}
        }
    );
}

sub populate{
    my ($self, $data) = @_;

    ref($self)->new(%$data, api=>$self->api);   
}


1;
