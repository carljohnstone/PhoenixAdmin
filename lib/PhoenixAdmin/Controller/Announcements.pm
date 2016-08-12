package PhoenixAdmin::Controller::Announcements;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Announcements - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Announcements Upload',
                'Edit Announcements',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Announcements',
                'url' => $c->uri_for($c->controller('Announcements')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Announcements Upload',
        'Edit Announcements',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Announcements', url => $c->uri_for($c->controller('Announcements')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'recent_announcements_rs'} = $c->model('DB::Announcement')->search({},
    {
        'order_by' => {'-desc' => 'id'},
        'rows'     => 20,
    });
}

=head2 announcement_id

=cut

sub announcement_id :Chained('/') :PathPart('admin/announcements') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'announcement'} = $c->model('DB::Announcement')->find_or_new({'id' => $id});
}

=head2 edit

=cut

sub edit :Chained('announcement_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Announcements Upload',
        'Edit Announcements',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'announcement'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'announcement'}->id ) {
        $form->model->default_values( $c->stash->{'announcement'} )
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
