package PhoenixAdmin::Controller::Pressbox;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

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

    $c->stash->{'fixtures_rs'} = $c->model('DB::Fixture')->past->search(
    {
        'team' => 'EPL',
        '-and' => [
            \'ADDTIME(date,fotime) > NOW() - INTERVAL 7 DAY',
        ],
    },
    {
        'prefetch' => ['pressbox'],
    }
    );

}

=head2 pressbox_id

=cut

sub pressbox_id :Chained('/') :PathPart('admin/pressbox') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'pressbox'} = $c->model('DB::Pressbox')->find_or_create({'fixture' => $id});
}

=head2 edit

=cut

sub edit :Chained('pressbox_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Edit Pressbox Details',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'pressbox'} );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted) {
        $form->model->default_values( $c->stash->{'pressbox'} )
    }

}

=head2 upload_photo

=cut

sub upload_photo :Chained('pressbox_id') :PathPart('upload_photo') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Upload Pressbox Photos',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        my $magick_image = Image::Magick->new();
        $magick_image->BlobToImage($form->param_value('file')->slurp);
        $magick_image->Strip;

        my $pressbox_image = $c->stash->{'pressbox'}->create_related('pressbox_images',{
            'caption'  => scalar($form->param_value('caption')),
            'credit'   => scalar($form->param_value('credit')),
            'width'    => $magick_image->Get('width'),
            'height'   => $magick_image->Get('height'),
            'size'     => $magick_image->Get('filesize'),
            'mimetype' => $magick_image->Get('mime'),
        });

        {
            # disable DBIC tracing for this query, as dumping the binary content
            # isn't useful
            local $pressbox_image->result_source->schema->storage->{debug} = 0;
            $pressbox_image->create_related('pressbox_image_data', {'binary_data' => $magick_image->ImageToBlob });
        }

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

}

=head2 upload_audio

=cut

sub upload_audio :Chained('pressbox_id') :PathPart('upload_audio') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Upload Pressbox Audio',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        my $pressbox_audio = $c->stash->{'pressbox'}->create_related('pressbox_audios',{
            'label'    => scalar($form->param_value('label')),
            'filename' => scalar($form->param_value('file')->basename),
        });

        {
            # disable DBIC tracing for this query, as dumping the binary content
            # isn't useful
            local $pressbox_audio->result_source->schema->storage->{debug} = 0;
            $pressbox_audio->create_related('pressbox_audio_data', {'binary_data' => $form->param_value('file')->slurp });
        }

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

}

=head2 link_video

=cut

sub link_video :Chained('pressbox_id') :PathPart('link_video') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
        'Link Pressbox Video',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        my $pressbox_video = $c->stash->{'pressbox'}->create_related('pressbox_videos',{
            'label'      => scalar($form->param_value('label')),
            'size_in_mb' => scalar($form->param_value('size')),
            'url'        => scalar($form->param_value('url')),
        });

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
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
