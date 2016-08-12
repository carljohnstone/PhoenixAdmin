package PhoenixAdmin::Controller::Users;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

PhoenixAdmin::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
            'Admin',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Users',
                'url' => $c->uri_for($c->controller('Users')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Users', url => $c->uri_for($c->controller('Users')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'users_rs'} = $c->model('DB::User');
}


=head2 user_id

=cut

sub user_id :Chained('/') :PathPart('admin/users') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{'user'} = $c->model('DB::User')->find_or_create({'id' => $id});
}

=head2 reset_password

=cut

sub reset_password :Chained('user_id') :PathPart('reset_password') :Args(0) {
    my ( $self, $c ) = @_;

    unless ($c->check_any_user_role(
        'Admin',
    )) {
        $c->detach('/errors/e403');
    }

    my $new_password = join('', map { (0..9,'a'..'z','A'..'Z')[rand(62)] } 1..20);
    $c->stash->{'new_password'} = $new_password;

    my $csh = Crypt::SaltedHash->new(
        'algorithm' => 'SHA-1',
        'salt_len' => $c->config->{'Plugin::Authentication'}->{'default'}->{'credential'}->{'password_salt_len'},
    );
    $csh->add($new_password);

    $c->stash->{'user'}->password($csh->generate);
    $c->stash->{'user'}->update;

    $c->email(
        'header' => [
            'To' => $c->stash->{'user'}->email,
            'From' => 'webmaster@manchesterphoenix.co.uk',
            'Subject' => 'Manchester Phoenix - Password Reset',
            ],
        'body' => $c->view('TT')->render($c,'admin/users/password_reset_email.tt'),
    );

    $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );

}

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
