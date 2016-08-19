package Eixo::Distribution::Base;

use strict;
use Carp qw(croak);

sub error{
    my ($self, @messages) = @_;

    croak(@messages);
}


1;
