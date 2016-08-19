package Eixo::Distribution::Api;

use strict;
use Eixo::Base::Clase qw(Eixo::Rest::Api);


has(

    version=>undef,

    proto=>undef,

    host=>undef
);


sub initialize{

    my ($self, @args) = @_;

    if(@args % 2){

        # if pass an odd number of args in new
        # firt one must be the docker host
        $self->host(shift(@args));


    }
    
    # rest of initialization has to be manual
    my %args = @args;
    
    while(my ($key, $val) = each(%args)){
        $self->$key($val);
    }

    my ($proto, $host) = split ('://', $self->host);
    
    ($host = $proto and $proto = undef) unless($host);    

    $host =~ s/\/+$//;;    

    if(!$proto || $proto eq 'tcp'){

        $proto = 'https';
    
    }
    
    $self->proto($proto);
    $self->host($host);

    $self->SUPER::initialize(
        
        "$proto://$host/" 

    )

}

sub images{
    $_[0]->produce('Eixo::Distribution::Image');
}


sub __formatError{

}

sub __changeMountPoint{
    my ($self, $mount) = @_;

    $self->mount($mount);

    my ($proto, $host) = ($self->proto, $self->host);

    $self->client->endpoint(

        "$proto://$host/" . $self->mount,

    );
}


#
# Internals
#
sub __analyzeRequest{
    my ($self, $method, %args) = @_;

    $self->__addHeaderData(\%args);

    my (@return) = $self->SUPER::__analyzeRequest($method, %args);
}
    sub __addHeaderData{
        my ($self, $args) = @_;

        $args->{HEADER_DATA} ||= {};

        $args->{HEADER_DATA}->{"Docker-Distribution-API-Version"} = "registry/2.0";
    }
1;
