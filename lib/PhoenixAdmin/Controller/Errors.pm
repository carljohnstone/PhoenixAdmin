package PhoenixAdmin::Controller::Errors;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

=head1 NAME

PhoenixAdmin::Controller::Errors - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 e401

401 error handler

=cut

sub e401 :Private {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'errors/e403.tt';
    $c->response->status( 401 );
}

=head2 e403

403 error handler

=cut

sub e403 :Private {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'errors/e403.tt';
    $c->response->status( 403 );
}

=head2 e404

404 error handler

=cut

sub e404 : Private {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'errors/e404.tt';
    $c->response->status( 404 );
}

=head2 e410

410 error handler

=cut

sub e410 : Private {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'errors/e404.tt';
    $c->response->status( 410 );
}

=head2 e503

503 error handler

=cut

sub e503 : Private {
    my ( $self, $c ) = @_;
    $c->stash->{'template'} = 'errors/e404.tt';
    $c->response->status( 503 );
}

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;