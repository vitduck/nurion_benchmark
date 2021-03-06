#!/usr/bin/env perl 

use strict; 
use warnings; 

use File::Find; 
use File::Slurp 'read_file';  
use String::Util 'trim';  
use Data::Printer; 

my %wtime; 

@ARGV == 0 ? find(\&walltime, '.') : find(\&walltime, @ARGV); 

my $max_length = ( 
    sort { $a <=> $b } 
    map { length $_ } keys %wtime 
)[-1];  

for my $dir ( sort { $a cmp $b } keys %wtime ) {  
    printf( 
        "%${max_length}s %7.2f %7.2f %7.2f %7.2f %7.2f \n", 
        $dir, 
        $wtime{$dir}->@{qw/ blas scalapack fftw others walltime/ }
    ); 
}

sub walltime { 
    if ( /\.out$/ && $_ ne 'std.out' ) { 
        my $sum; 

        #printf "%s\n", $File::Find::dir; 
        my $output   = read_file($_);

        if ( $output =~ /JOB DONE/ ) { 
            # total walltime
            my $walltime = trim($1) if $output =~ /PWSCF.*CPU(.*)WALL/; 
            $walltime = to_second( $walltime ); 
            $wtime{$File::Find::dir}{walltime} = $walltime; 

            # h_psi(blas) + s_psi(blas)
            my $s_psi  = trim($1) if $output =~ /s_psi.+?(\d+\.\d+)s WALL/; 
            my $calbec = trim($1) if $output =~ /h_psi:calbec.+?(\d+\.\d+)s WALL/; 
            my $vuspsi = trim($1) if $output =~ /add_vuspsi.+?(\d+\.\d+)s WALL/; 

            $sum += $s_psi + $calbec + $vuspsi; 
            $wtime{$File::Find::dir}{blas} = $s_psi + $calbec + $vuspsi; 

            # h_psi(fftw) 
            my $vlog_psi = trim($1) if $output =~ /vloc_psi.+?(\d+\.\d+)s WALL/; 

            $sum += $vlog_psi; 
            $wtime{$File::Find::dir}{fftw} = $vlog_psi; 

            # h_psi(scalapack) 
            my $cdiaghg = trim($1) if $output =~ /cdiaghg(?!:).+?(\d+\.\d+)s WALL/; 

            $sum += $cdiaghg; 
            $wtime{$File::Find::dir}{scalapack} = $cdiaghg; 

            # remaining 
            $wtime{$File::Find::dir}{others} = $walltime - $sum; 
        }
    }
}

sub to_second { 
    my $time = shift;
   
    if ( $time =~ /(.+)m\s?(.+)s/ ) { 
        return 60*$1 +$2
    } elsif ( $time =~ /(.+)s/ ) { 
        return $1 
    } else { 
        return undef
    }
} 
