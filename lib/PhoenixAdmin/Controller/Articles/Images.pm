package PhoenixAdmin::Controller::Articles::Images;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Articles::Images - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index
=cut

sub index :Chained('/articles/article_id') :PathPart('images') :Args(0) {
    my ( $self, $c ) = @_;

    if (defined $c->req->param('q') ) {
        if ( $c->req->param('q') =~ /^(\d+)$/ ) {
            $c->detach('add', [$1] );
        }

        my $search_string = '%' . $c->req->param('q') . '%';

        my @or_clause = (
            'id'   => $c->req->param('q'),
            'name' => { 'like', $search_string },
            'alt'  => { 'like', $search_string },
        );

        if ($c->check_any_user_role(
            'Admin',
        )) {
            push (@or_clause, 'caption' => { 'like', $search_string } );
        }

        $c->stash->{image_search_rs} = $c->model('DB::Image')->search({
            '-or' => \@or_clause,
        },
        {
            'order_by' => {'-desc' => 'id'}
        });
    }
}

=head2 image_id
=cut

sub image_id :Chained('/articles/article_id') :PathPart('images') :CaptureArgs(1) {
    my ( $self, $c, $image_id ) = @_;

    $c->stash->{'article_image'} = $c->model('DB::ArticleImage')->find({
        'article_id'    => $c->stash->{'article'}->id,
        'related_image' => $image_id,
    });
}

=head2 add
=cut

sub add :Chained('/articles/article_id') :PathPart('add') :Args(1) {
    my ( $self, $c, $image_id ) = @_;

    if ($c->stash->{'article'}->add_image($image_id)) {
        $c->res->redirect( $c->uri_for( $c->controller->action_for('edit'), [$c->stash->{'article'}->id, $image_id] ) );
        return;
    }
}

=head2 edit
=cut

sub edit :Chained('image_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'article_image'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index'), [$c->stash->{'article'}->id] ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'article_image'} ) {
        $form->model->default_values( $c->stash->{'article_image'} )
    }
}

=head2 delete
=cut

sub delete :Chained('image_id') :PathPart('delete') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'article_image'}->delete;
    $c->res->redirect( $c->uri_for( $c->controller->action_for('index'), [$c->stash->{'article'}->id] ) );
}

=encoding utf8

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
