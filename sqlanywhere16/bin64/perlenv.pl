# ***************************************************************************
# Copyright (c) 2014 SAP AG or an SAP affiliate company. All rights reserved.
# ***************************************************************************
use strict;

use IO::Handle;
use PerlIO::via::SAExtEnvIO;
use SAPerlGlue;
use DBI;

my $sa_perl_default_connection; 
my $sa_output_handle;

$ENV{'SQLANY_API_DLL'} = 'libdbcapi_r.so' 
    unless $^O eq 'MSWin32' || $^O eq 'darwin';
$ENV{'SQLANY_API_DLL'} = 'libdbcapi_r.dylib' if $^O eq 'darwin';

sub execute {
    my $method_sig = shift;

    
    # signature format is:
    # '<args=args_list[| file=fname.pl]> perl_code' (quotes omitted)
    # perl_code is some piece of perl to be executed
    # args_list ::= $/$$$...RR...    The $ preceeding the slash is optional
    #   and denoted a return value.  Each $ following the slash denotes an
    #   argument, each R denotes a result set.
    # if the optional file=filename.pl is given, filename.pl is read from the
    #   database and evaled before <perl_code>
   
    if( $method_sig !~ /^........\s*(\<[^\>]*\>){0,1}(.*)/s ) {
	$method_sig =~ /^........(.*)/;
	my $err_str = SAPerlGlue::get_error( 
			&SAPerlGlue::IDS_EE_PERL_BAD_BODY );
	SAPerlGlue::set_error( sprintf( $err_str, $1 ) );
    	return -1;
    }
    my ($options, $perl_code) = ($1, $2);  
    my ( $has_return, $args, $num_args, $num_rs, $file_name, $code ) =
       ( 0, 0, 0, 0, '', '' );
   
    if( length( $options ) > 2 ) {
	my @option_array = split /\|/, substr( $options, 1, -1 );
	for my $opt (@option_array) {
	    if( $opt !~ /\s*([^=]*)=(.*)/ ) {
		my $err_str = SAPerlGlue::get_error( 
				&SAPerlGlue::IDS_EE_PERL_BAD_OPTION );
		SAPerlGlue::set_error( sprintf( $err_str, $opt ) );
		return -1;
	    }
	    my ( $key, $val ) = ( $1, $2 );
	    
	    if( $key eq 'args' ) {
		
		if( $val !~ /(\$\/|\/|@\/)?((?:\$|@)*)(R*)/ ) {
		    my $err_str = SAPerlGlue::get_error( 
				    &SAPerlGlue::IDS_EE_PERL_BAD_ARG_LIST );
		    SAPerlGlue::set_error( sprintf( $err_str, $val ) );
		    return -1;
		}
		$has_return = ( $1 eq '$/' or $1 eq '@/' ? 1 : 0 );
		$args = $2;
		$num_args = length( $args );
		if( $has_return ) {
		    $args .= substr( $1, 0, 1 );
		}
		$num_rs = length( $3 );
	    } elsif( $key eq 'file' ) {
		$file_name = $val;
		my $temp_code = SAPerlGlue::get_code( $file_name );
		if( !defined $temp_code ) {
		    return -1; 
		}
		$code .= $temp_code;
	    } else {
		my $err_str = SAPerlGlue::get_error( 
				&SAPerlGlue::IDS_EE_PERL_UNKNOWN_KEY );
		SAPerlGlue::set_error( sprintf( $err_str, $key ) );
		return -1;
	    } 	
	}
    }
    
    my $ret;
    my $ref_arg_vals = SAPerlGlue::get_args( $args, $num_args, $has_return );
    my @sa_perl_arguments = @$ref_arg_vals;
    
    if( $has_return ) {
    	$code .= 'my $sa_perl_return;';
    }
    $code .= $perl_code;
    $code .= ";\n";
    
    my $sa_perl_eval_code = "";
    my $cnt = 0;
    
    if( $#sa_perl_arguments >= 0 ) {
	$sa_perl_eval_code .= "my (";
	for my $arg (@sa_perl_arguments) {
	    if( $cnt > 0 ) {
	    	$sa_perl_eval_code .= ", ";
	    }
	    $sa_perl_eval_code .= "\$sa_perl_arg$cnt";
	    $cnt++;
	}
	$sa_perl_eval_code .= ") = \@sa_perl_arguments;";
    }
    $sa_perl_eval_code .= $code;
    
    $sa_perl_eval_code .= 'my @res;';
    for( my $i = 0; $i < $num_args; $i++ ) {
	$sa_perl_eval_code .= "push \@res, \$sa_perl_arg$i;\n";
    }
    if( $has_return ) {
    	$sa_perl_eval_code .= "push \@res, \$sa_perl_return;\n";
    }
    $sa_perl_eval_code .= '@res;';
    
    if( !defined $sa_perl_default_connection ) {
	my $sqlca = SAPerlGlue::get_sqlca();
	$sa_perl_default_connection = 
	    DBI->connect( "DBI:SQLAnywhere:ENG=saperl;sa_perl_sqlca=$sqlca" );
	SAPerlGlue::set_error "$DBI::errstr" if $DBI::errstr;
	if( !defined $sa_perl_default_connection ) {
	    return -1;
	}
    }
   
    {
	my @res = eval $sa_perl_eval_code;
	if( $@ ) {
	    SAPerlGlue::set_error $@;
	    return -1;
	}
	$ret = SAPerlGlue::set_output( \@res );
	return -1 unless defined $ret;
    }
    return 1;
}



my( $eng, $dbn, $uid, $tmp, $pwd ) = @ARGV;


#open( STDOUT, ">:via(PerlIO::via::SAExtEnvIO)", "foo.txt" );
#open( STDERR, ">:via( SAExtEnvIO )" );

open($sa_output_handle, ">:via(PerlIO::via::SAExtEnvIO)", "notused.txt") or die "failed to start";

eval{ SAPerlGlue::start( \&execute, $eng, $dbn, $uid, $pwd ); };
die $@ if $@;

undef $sa_perl_default_connection;
close $sa_output_handle;
