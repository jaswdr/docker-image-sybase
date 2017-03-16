<?php

$old_err = error_reporting( 0 );

$sa_version = '16';

# Attempt to load the SQLAnywhere PHP driver
# It is okay if this fails, we just will not be able to do
# server-side queries
    
$phpver = phpversion();
$phpverdash = strpos( $phpver, '-' );
if( $phpverdash != FALSE ) {
    $phpver = substr( $phpver, 0, $phpverdash );
}

if ( !extension_loaded( 'sqlanywhere' ) ) {
    if ( strtoupper( substr( PHP_OS, 0, 3 ) ) === 'WIN' ) {
        $load_result = dl( 'php-' . $phpver . '_sqlanywhere.dll' );
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere.dll' );
        }
    } else {
        $load_result = dl( 'php-' . $phpver . '_sqlanywhere_r.so' );
        if( !$load_result ) {
            $load_result = dl( 'php-' . $phpver . '_sqlanywhere.so' );
        }
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere.so' );
        }
    }
}

# Attempt to load the SQLAnywhere PHP External Environment driver
# Failure to do so is fatal
if ( !extension_loaded( 'sqlanywhere_extenv' ) ) {
    $load_result = 0;
    if ( strtoupper( substr( PHP_OS, 0, 3 ) ) === 'WIN' ) {
        $load_result = dl( 'php-' . $phpver . 
                           '_sqlanywhere_extenv' . $sa_version . '.dll' );
        if( !$load_result ) {
            $load_result = dl( 'php-' . $phpver .
                               '_sqlanywhere_extenv.dll' );
        }
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere_extenv' . $sa_version . '.dll' );
        }
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere_extenv.dll' );
        }
    } else {
        $load_result = dl( 'php-' . $phpver . 
                           '_sqlanywhere_extenv' . $sa_version . '_r.so' );
        if( !$load_result ) {
        $load_result = dl( 'php-' . $phpver . 
                           '_sqlanywhere_extenv' . $sa_version . '.so' );
        }
        if( !$load_result ) {
            $load_result = dl( 'php-' . $phpver .
                               '_sqlanywhere_extenv_r.so' );
        }
        if( !$load_result ) {
            $load_result = dl( 'php-' . $phpver .
                               '_sqlanywhere_extenv.so' );
        }
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere_extenv' . $sa_version . '.so' );
        }
        if( !$load_result ) {
            $load_result = dl( 'sqlanywhere_extenv.so' );
        }
    }

    if( !$load_result ) {
        print "ERROR: Could not load sqlanywhere_extenv PHP module\n";
        exit;
    }
}

error_reporting( $old_err );

function flush_buffers()
{
    global $argv;
    while( $buffer = @ob_get_clean() ) {
        $argv[0] = $buffer . $argv[0];
    }
    sqlanywhere_extenv_set_output( $argv );
}

function flush_buffers_and_exit()
{
    flush_buffers();
    sqlanywhere_extenv_force_exit();
}

function sqlanywhere_extenv_execute_now( $signature )
{
    # Reset the execution time clock so that we don't run out of time
    # due to previous requests (but still allow *this* request to run out
    # of time)
    set_time_limit( ini_get('max_execution_time') );

    # Attempt to register the default PHP connection
    # We can only do this f the SQLAnywhere PHP driver has been loaded
    # Check each time in case somebody has managed to load the driver in
    # a previous call
    if( extension_loaded( 'sqlanywhere' ) ) {
        $sqlca = sqlanywhere_extenv_get_conn();
        sasql_pconnect_from_sqlca( $sqlca );
    }

    $matches = array();
    if( preg_match( '/^........\s*(<[^>]*>){0,1}((.|\n)*)/', $signature, $matches ) == 0 ) {
        preg_match( '/^........((.|\n)*)/', $opt, $matches );
        $err_str = sqlanywhere_extenv_get_error( 
            SQLANYWHERE_EE_BAD_BODY );
        $err_str = sprintf( $err_str, $matches[1] );
        sqlanywhere_extenv_set_error( $err_str );
        return -1;
    }

    $sa_options = $matches[1];
    $sa_php_code = $matches[2];

    $argc = 0;
    $args = '';
    $sa_code = '';

    if( strlen( $sa_options ) > 2 ) {
        $option_array = preg_split( '/\s*\|\s*/', 
                                    substr( $sa_options, 1, -1 ) );
        foreach( $option_array as $opt ) {
            if( preg_match( '/\s*([^=]*)=(.*)/', $opt, $matches ) == 0 ) {
                $err_str = sqlanywhere_extenv_get_error( 
                    SQLANYWHERE_EE_BAD_OPTION );
                $err_str = sprintf( $err_str, $opt );
                sqlanywhere_extenv_set_error( $err_str );
                return -1;
            }

            $key = $matches[1];
            $value = $matches[2];

            if( $key == 'args' ) {
                if( preg_match( '/^((?:[IDBS])*)$/', 
                                $value, $matches ) == 0 ) {
                    $err_str = sqlanywhere_extenv_get_error( 
                        SQLANYWHERE_EE_BAD_ARG_LIST );
                    $err_str = sprintf( $err_str, $value );
                    sqlanywhere_extenv_set_error( $err_str );
                    return -1;
                }

                $args = $matches[1];
                $argc = strlen( $args );
            }
            elseif( $key == 'file' ) {
                $file_name = $value;
                $temp_code = sqlanywhere_extenv_get_code( $file_name );
                if( is_null( $temp_code ) ) {
                    # the SDK returns the error for this one
                    return -1;
                }

                $sa_code .= "?>\n" . $temp_code . "\n<?php\n";
            }
            else {
                $err_str = sqlanywhere_extenv_get_error( 
                    SQLANYWHERE_EE_UNKNOWN_KEY );
                $err_str = sprintf( $err_str, $key );
                sqlanywhere_extenv_set_error( $err_str );
                return -1;
            }
        }
    }

    $args .= 'S';

    global $argv;
    $argv = sqlanywhere_extenv_get_args( $args, $argc, true );
    if( is_null( $argv ) ) {
        return -1;
    }

    $sa_code .= "\n" . $sa_php_code . ";\n";

    try {
        register_shutdown_function('flush_buffers_and_exit');
        ob_start();
        $sa_php_eval_retval = eval( $sa_code );
        if( !defined( $sa_php_eval_retval ) && 
            !is_null( $sa_php_eval_retval ) ) {
            throw new Exception( 
                sqlanywhere_extenv_get_error( SQLANYWHERE_EE_PARSE_ERROR ) );
        }

        flush_buffers();

        # ensure any sessions are saved off to persistent storage
        if( extension_loaded( 'session' ) ) {
            session_write_close();
            if( isset( $_SESSION ) ) {
                unset( $_SESSION );
            }
        }
    } catch( Exception $e ) {
        sqlanywhere_extenv_set_error( $e->getMessage() );
        return -1;
    }

    return 0;
}

if( $argc != 5 ) {
    print "usage: " . $argv[0] . " <engine> <database> <user> <password>\n";
    exit;
}

sqlanywhere_extenv_start( 'sqlanywhere_extenv_execute_now',
                          $argv[1], $argv[2], $argv[3], $argv[4] );
?>
