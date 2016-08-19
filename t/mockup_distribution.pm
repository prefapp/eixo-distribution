package t::mockup_distribution;

sub start{
    my ($port) = @_;

    my $pid;

    eval{

    	$pid = Eixo::Rest::ApiFakeServer->new(
    
    		listeners=>{
    
    			'/v2/' => {
    
    				body=>sub {
    
    					print "TEST1";
    
    				}
    
    			},

            }

        )->start($port);

    };
    if($@){
        die($@);
    }
    
    sleep(1);

    return $pid;
}

sub stop{
    my ($pid) = @_;

    kill(9, $pid) if($pid);	
}



1;
