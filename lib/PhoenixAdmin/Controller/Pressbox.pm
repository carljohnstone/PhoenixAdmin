package PhoenixAdmin::Controller::Pressbox;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

PhoenixAdmin::Controller::Pressbox - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Edit Pressbox Details',
                'Upload Pressbox Photos',
                'Upload Pressbox Audio',
                'Link Pressbox Video',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Pressbox',
                'url' => $c->uri_for($c->controller('Pressbox')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Edit Pressbox Details',
        'Upload Pressbox Photos',
        'Upload Pressbox Audio',
        'Link Pressbox Video',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Pressbox', url => $c->uri_for($c->controller('Pressbox')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}


=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
