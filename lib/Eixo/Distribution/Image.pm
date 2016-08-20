package Eixo::Distribution::Image;

use strict;
use Eixo::Base::Clase 'Eixo::Distribution::Product';

use Eixo::Distribution::ImageManifest;

has(

    name=>undef,
    
    digest=>undef, 
   
    manifest=>undef,

);

sub layers{
    $_[0]->api->layers->image(
        $_[0]->name
    );
}

sub manifests{
    $_[0]->api->manifests->name(
        $_[0]->name
    );
}

sub initialize{

    my ($self, %args) = @_;

    $self->manifest(

        Eixo::Distribution::ImageManifest->new(

            %{$args{manifest_data} || {}},

            api=>$args{api}

        )

    );

    $self->SUPER::initialize(%args);

    $self;
}

sub delete{
    my ($self, %args) = @_;

    ##$self = $self->get(%args);

    # firstly we delete the layers
    foreach my $layer_digest ($self->manifest->layersDisgest){
        $self->layers->delete($layer_digest);
    }    

    # secondly we delete the manifest itself
    $self->manifests->delete($self->digest);
}

sub get{
    my ($self, %args) = @_;

    $args{name} = $args{name} || $self->name ||
        $self->error("IMAGE::GET: name is needed");

    $args{reference} = $args{reference} || 
        $self->manifest->digest || 
            $self->manifest->tag || 
                $self->error("IMAGE::GET: a reference (tag|digest) is needed");


    my $digest;
    my $image_data;

    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:name/manifests/:reference",

        onProgress=>sub {
            my ($body, $res) = @_;

            $digest = $res->headers->header("docker-content-digest");
         
            $image_data = $body;   
        },

        onSuccess=>sub {

            $self->populate({

                name=>$args{name},

                digest=>$digest,

                manifest_data=>JSON->new->utf8->decode($image_data)

            });
        }

    );

}

sub layerExists{
    my ($self, $layer, %args) = @_;

    $args{name} = $args{name} || $self->name ||
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
    my ($self, $image_name, %args) = @_;

    $args{name} = $image_name || $self->manifest->name ||
        $self->error("IMAGE::GET: name is needed");

    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:name/tags/list",

        __callback=>sub {

            $_[0]->{tags} || [];

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
