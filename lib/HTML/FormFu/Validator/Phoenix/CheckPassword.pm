package HTML::FormFu::Validator::Phoenix::CheckPassword;
use strict;
use warnings;
use base 'HTML::FormFu::Validator';

sub validate_value {
    my ( $self, $value, $params ) = @_;

    my $c = $self->form->stash->{context};

    return 1 if $c->get_auth_realm('default')->credential->check_password($c->user, {password=>$value});

    # assuming you want to return a custom error message
    # which perhaps includes something retrieved from the model
    # otherwise, just return 0
    die HTML::FormFu::Exception::Validator->new({
        message => 'Current Password Invalid',
    });
}

1;