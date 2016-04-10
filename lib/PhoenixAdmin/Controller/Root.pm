package PhoenixAdmin::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu' }

__PACKAGE__->config(namespace => '');

=head1 NAME

PhoenixAdmin::Controller::Root - Root Controller for PhoenixAdmin

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;

    if ($c->user_exists) {
        $c->forward('audit_log');
    } else {
        $c->forward('login');
    }

    foreach my $controller ($c->controllers) {
        if (my $action = $c->controller($controller)->action_for('nav')) {
            $c->forward($action);
        }
    }
    $c->stash->{'nav'} = [ sort { $a->{'label'} cmp $b->{'label'} } @{$c->stash->{'nav'}} ];

    $c->stash->{'breadcrumb'} = [{ label => 'Home', url => $c->uri_for('/')}];
    return 1;
}

=head2 login
=cut

sub login :Private {
    my ( $self, $c ) = @_;

    my $login_form = $self->form;
    $login_form->load_config_file('login.yml');
    $login_form->process;
    $c->stash->{'login_form'} = $login_form;

    if ($c->req->method eq 'POST' && $login_form->submitted_and_valid ) {
        if ( $c->authenticate({
                'email' => $login_form->param_value('email'),
                'password' => $login_form->param_value('password')
            }) ) {
            $c->res->redirect($c->request->uri);
            $c->detach;
        } else {
            $login_form->get_field('submit')->get_constraint({ type => 'Callback' })->force_errors(1);
        }
    }
    $c->detach('/errors/e401');
}

=head2 audit_log
=cut

sub audit_log :Private {
    my ( $self, $c ) = @_;

    if ($c->req->method eq 'POST' ) {

        my $bodytext = "User:\n" . $c->user->fullname
                        . "\n\nURL:\n" . $c->req->uri
                        . "\n\nParams:\n" . Dumper($c->req->parameters)
                        . "\n\nClient IP:\n" . $c->req->address;

        my $body_part = Email::MIME->create(
            'attributes' => {
                'content_type' => 'text/plain',
                'disposition' => 'inline',
                'charset' => 'UTF-8',
            },
            'body' => $bodytext,
        );

        my @parts = ($body_part);

        foreach my $upload (values %{ $c->req->uploads } ) {
            my $part = Email::MIME->create(
                'attributes' => {
                    'filename' => $upload->filename,
                    'content_type' => $upload->type,
                    'disposition' => 'attachment',
                    'encoding' => 'base64',
                },
                'body' => $upload->slurp,
            );
            push(@parts, $part);
        }

        $c->email(
            header => [
                'To' => 'phoenix@fadetoblack.me.uk',
                'From' => 'webmaster@manchesterphoenix.co.uk',
                'Subject' => 'Phoenix Admin: ' . $c->req->uri,
            ],
            parts => \@parts,
        );
    }

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

}

=head2 logout

=cut

sub logout :Path('logout') :Args(0) {
    my ( $self, $c ) = @_;
    $c->logout;
    $c->res->redirect($c->uri_for('/'));
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    my $cache_time = $c->stash->{'cache_time'};
    if (defined( $cache_time )  && ! (scalar @{ $c->error })) {
        $c->response->headers->last_modified(time);
        $c->response->headers->expires(time + $cache_time);
        $c->response->headers->header(cache_control => "public, max-age=$cache_time");
    }
    else {
        $c->response->headers->last_modified(time);
        $c->response->headers->expires(time - 1);
        $c->response->headers->header(cache_control => "no-cache, must-revalidate");
        $c->response->headers->header(pragma => "no-cache");
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
