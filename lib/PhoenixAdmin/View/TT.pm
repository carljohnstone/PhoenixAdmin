package PhoenixAdmin::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    WRAPPER            => 'include/wrapper.tt',
    render_die         => 1,
);

=head1 NAME

PhoenixAdmin::View::TT - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

Carl Johnstone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
