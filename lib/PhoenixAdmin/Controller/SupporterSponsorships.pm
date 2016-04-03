package PhoenixAdmin::Controller::SupporterSponsorships;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

PhoenixAdmin::Controller::SupporterSponsorships - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Supporter Sponsorships',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Supporter Sponsorships',
                'url' => $c->uri_for($c->controller('SupporterSponsorships')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Supporter Sponsorships',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Supporter Sponsorships', url => $c->uri_for($c->controller('SupporterSponsorships')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched PhoenixAdmin::Controller::SupporterSponsorships in SupporterSponsorships.');
}


=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
