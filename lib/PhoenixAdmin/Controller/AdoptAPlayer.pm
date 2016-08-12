package PhoenixAdmin::Controller::AdoptAPlayer;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::AdoptAPlayer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Adopt a Player',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Adopt A Player',
                'url' => $c->uri_for($c->controller('AdoptAPlayer')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Adopt a Player',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Adopt A Player', url => $c->uri_for($c->controller('AdoptAPlayer')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'rosters'} = $c->model('DB::Roster')->search(
    {
        'me.id' => $c->config->{'adopt_a_player_rosters'},
    },
    {
        'prefetch' => { 'roster_players' => 'player' },
    }
    );
}

=head2 player_id

=cut

sub player_id :Chained('/') :PathPart('admin/adoptaplayer') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'player'} = $c->model('DB::Player')->find({'id' => $id});
    $c->stash->{'player_adoption'} = $c->model('DB::PlayerAdoption')->find_or_new({'id' => $id});
}

=head2 edit

=cut

sub edit :Chained('player_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'player_adoption'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'player_adoption'} ) {
        $form->model->default_values( $c->stash->{'player_adoption'} )
    }

}

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
