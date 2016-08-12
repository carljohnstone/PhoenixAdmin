package PhoenixAdmin;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    StackTrace
    Authentication
    Authorization::Roles
    Session
    Session::Store::DBI
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in phoenixadmin.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    'name' => 'PhoenixAdmin',
    'default_view' => 'TT',
    # Disable deprecated behavior needed by old applications
#    'disable_component_resolution_regex_fallback' => 1,
    'Controller::HTML::FormFu' => {'constructor' => { 'config_file_path' => __PACKAGE__->path_to('forms')}},
    'session' => {
        'expires' => '1209600',
        'verify_address' => 0,
        'dbi_dbh' => 'DB',
        'dbi_table' => 'sessions',
    },
    'Plugin::Authentication' => {
        'default' => {
            'credential' => {
                'class' => 'Password',
                'password_field' => 'password',
                'password_type' => 'salted_hash',
                'password_salt_len' => 4,
            },
            'store' => {
                'class' => 'DBIx::Class',
                'user_model' => 'DB::User',
                'role_relation' => 'roles',
                'role_field' => 'role',
            },
        },
    },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

PhoenixAdmin - Catalyst based application

=head1 SYNOPSIS

    script/phoenixadmin_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<PhoenixAdmin::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
