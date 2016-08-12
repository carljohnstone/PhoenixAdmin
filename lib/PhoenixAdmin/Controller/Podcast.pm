package PhoenixAdmin::Controller::Podcast;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Podcast - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Podcast Upload',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Podcast',
                'url' => $c->uri_for($c->controller('Podcast')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Podcast Upload',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Podcast', url => $c->uri_for($c->controller('Podcast')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'recent_podcasts'} = $c->model('DB::Podcast')->search({},
    {
        'order_by' => {'-desc' => 'id'},
        'rows'     => 20,
    });

}

=head2 upload

=cut

sub upload :Local :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Podcast Upload',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        my $file = $form->param_value('file');

        my $new_podcast = $c->model('DB::Podcast')->create({
            'title'     => $form->param_value('title'),
            'date'      => $form->param_value('date'),
            'text'      => $form->param_value('text'),
            'published' => $form->param_value('published'),
            'audio_url' => $form->param_value('audio_url'),
            'filename'  => $file->filename,
            'filesize'  => $file->size,
        });

        {
            # disable DBIC tracing for this query, as dumping the binary content
            # isn't useful
            local $new_podcast->result_source->schema->storage->{debug} = 0;
            $new_podcast->create_related('podcast_mp3', {'file' => $file->slurp });
        }

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

}

=head2 edit

=cut

sub edit :Local :Args(1) :FormConfig {
    my ( $self, $c, $id ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Podcast Upload',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    my $podcast = $c->stash->{image} = $c->model('DB::Podcast')->find_or_new({'id' => $id});

    if ( $form->submitted_and_valid ) {

        $form->model->update( $podcast );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted) {
        $form->model->default_values( $podcast )
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
