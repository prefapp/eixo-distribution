package Eixo::Distribution::Layer;

use strict;
use Eixo::Base::Clase 'Eixo::Distribution::Product';

use Eixo::Distribution::ImageManifest;

has(

    image=>undef,

    mediaType=>undef,

    size=>undef,

    digest=>undef,

);

sub get{
    my ($self, %args) = @_;

}

sub delete{
    my ($self, $layer, %args) = @_;

    $args{image} = $args{image} || $self->image ||
        $self->error("LAYER:DELETE: an image is needed");
    
    unless($layer){
        $self->error("LAYER:DELETE: a layer digest is needed");
    }

    $args{reference} = $layer; 

    my %xargs = (%args);    

    $self->api->deleteV2(

        args=>\%args,
    
        uri_mask=>"/v2/:image/blobs/:reference",

        __callback=>sub {

            print "Todo borrado\n";
        }
    );
}

sub exists{
    my ($self, $layer, %args) = @_;

    $args{image} = $args{image} || $self->image ||
        $self->error("LAYER:EXISTS: a name is needed");
    
    unless($layer){
        $self->error("LAYER:EXISTS: a layer digest is needed");
    }

    $args{reference} = $layer; 
    $args{__format} = "RAW";

    $self->api->getV2(

        args=>\%args,

        uri_mask=>"/v2/:image/blobs/:reference",
 
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

            $self->populate($_[0]);
        }
    );
}

sub populate{
    my ($self, $data) = @_;

    ref($self)->new(%$data, api=>$self->api);   
}


1;
