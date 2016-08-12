package PhoenixAdmin::Controller::Players;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Players - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Edit Players',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Players',
                'url' => $c->uri_for($c->controller('Players')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Edit Players',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Players', url => $c->uri_for($c->controller('Players')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'players_rs'} = $c->model('DB::Player')->search({},
    {
        'order_by' => {'-asc' => 'id'},
    });}

=head2 player_id

=cut

sub player_id :Chained('/') :PathPart('admin/players') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'player'} = $c->model('DB::Player')->find_or_new({'id' => $id});
}

=head2 edit

=cut

sub edit :Chained('player_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Edit Players',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'player'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'player'}->id ) {
        $form->model->default_values( $c->stash->{'player'} )
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
