package PhoenixAdmin::Controller::Images;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Images - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
                'Admin',
                'Images Upload',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Images',
                'url' => $c->uri_for($c->controller('Images')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Images Upload',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Images', url => $c->uri_for($c->controller('Images')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'recent_images_rs'} = $c->model('DB::Image')->search({},
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
        'Images Upload',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {

        my $magick_image = Image::Magick->new();
        $magick_image->BlobToImage($form->param_value('file')->slurp);
        $magick_image->Strip;

        my $wratio = 1000  / $magick_image->Get('width');
        my $hratio = 700 / $magick_image->Get('height');

        if ($wratio < 1 || $hratio < 1 ) { # do we need to resize
            my $scale = 1;
            if ( $wratio < $hratio ) {
                $scale = $wratio;
            }
            else {
                $scale = $hratio;
            }
            my $required_width  =  int($magick_image->Get('width') * $scale);
            my $required_height =  int($magick_image->Get('height') * $scale);

            $magick_image->Resize( 'width' => $required_width, 'height' => $required_height );
        }

        my $image_blob = $magick_image->ImageToBlob;

        my $new_image = $c->model('DB::Image')->create({
            'category' => $form->param_value('category'),
            'date'     => $form->param_value('date'),
            'name'     => $form->param_value('name'),
            'alt'      => $form->param_value('alt'),
            'caption'  => $form->param_value('caption'),
            'credit'   => $form->param_value('credit'),
            'width'    => $magick_image->Get('width'),
            'height'   => $magick_image->Get('height'),
            'size'     => length($image_blob),
            'mimetype' => $magick_image->Get('mime'),
        });

        {
            # disable DBIC tracing for this query, as dumping the binary content
            # isn't useful
            local $new_image->result_source->schema->storage->{debug} = 0;
            $new_image->create_related('image_data', {'binary_data' => $image_blob });
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
        'Images Upload',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    my $image = $c->stash->{image} = $c->model('DB::Image')->find_or_new({'id' => $id});

    if ( $form->submitted_and_valid ) {

        $form->model->update( $image );

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted) {
        $form->model->default_values( $image )
    }

}

=head2 reupload

=cut

sub reupload :Local :Args(1) :FormConfig {
    my ( $self, $c, $id ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
    )) {
        $c->detach('/errors/e403');
    }

    my $form = $c->stash->{form};

    my $image = $c->stash->{image} = $c->model('DB::Image')->find({'id' => $id});

    if ( $form->submitted_and_valid ) {

        my $magick_image = Image::Magick->new();
        $magick_image->BlobToImage($form->param_value('file')->slurp);
        $magick_image->Strip;

        my $wratio = 1000  / $magick_image->Get('width');
        my $hratio = 700 / $magick_image->Get('height');

        if ($wratio < 1 || $hratio < 1 ) { # do we need to resize
            my $scale = 1;
            if ( $wratio < $hratio ) {
                $scale = $wratio;
            }
            else {
                $scale = $hratio;
            }
            my $required_width  =  int($magick_image->Get('width') * $scale);
            my $required_height =  int($magick_image->Get('height') * $scale);

            $magick_image->Resize( 'width' => $required_width, 'height' => $required_height );
        }

        my $image_blob = $magick_image->ImageToBlob;

        $image->image_data->binary_data($image_blob);
        {
            # disable DBIC tracing for this query, as dumping the binary content
            # isn't useful
            local $image->result_source->schema->storage->{debug} = 0;
            $image->image_data->update;
        }
        $image->width( $magick_image->Get('width') );
        $image->height( $magick_image->Get('height') );
        $image->size( length($image_blob) );
        $image->mimetype( $magick_image->Get('mime') );
        $image->modified_date( $c->stash->{'dt_now'} );
        $image->update;
        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

}

=head2 search
=cut

sub search :Local :Args(0) {
    my ( $self, $c ) = @_;

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

    $c->stash->{image_rs} = $c->model('DB::Image')->search({
        '-or' => \@or_clause,
    },
    {
        'order_by' => {'-desc' => 'id'}
    });

}

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
