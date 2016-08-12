package PhoenixAdmin::Controller::Results;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Results - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Results',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Results',
                'url' => $c->uri_for($c->controller('Results')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Results',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Results', url => $c->uri_for($c->controller('Results')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'fixtures'} = $c->model('DB::Fixture')->needs_result;

}

=head2 article_id

=cut

sub fixture_id :Chained('/') :PathPart('admin/results') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'fixture'} = $c->model('DB::Fixture')->find_or_new({'id' => $id});
}

=head2 edit

=cut

sub edit :Chained('fixture_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Results',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'fixture'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'fixture'}->id ) {
        $form->model->default_values( $c->stash->{'fixture'} )
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
