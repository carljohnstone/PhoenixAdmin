package PhoenixAdmin::Controller::Auctions;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

PhoenixAdmin::Controller::Auctions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub nav :Private {
    my ( $self, $c ) = @_;

    if ( $c->check_any_user_role(
            'Admin',
            'Auctions',
            )
     ) {

        push(@{$c->stash->{'nav'}}, {
                'label' => 'Auctions',
                'url' => $c->uri_for($c->controller('Auctions')->action_for('index'))
            },
        );
    }
}

sub auto :Private {
    my ( $self, $c ) = @_;
    unless ($c->check_any_user_role(
        'Admin',
        'Auctions',
    )) {
        $c->detach('/errors/e403');
    }
    push( @{ $c->stash->{'breadcrumb'} }, { label => 'Auctions', url => $c->uri_for($c->controller('Auctions')->action_for('index')) } );
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'recent_auctions_rs'} = $c->model('DB::AuctionItem')->search({},
    {
        'order_by' => {'-desc' => 'id'},
        'rows'     => 20,
    });
}

=head2 auction_item_id

=cut

sub auction_item_id :Chained('/') :PathPart('admin/auctions') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $model = $c->model('DB::AuctionItem');
    $c->stash->{'auction_item'} = $model->find({'id' => $id}) || $model->new({});
}

=head2 edit

=cut

sub edit :Chained('auction_item_id') :PathPart('edit') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};
    my $bid = $c->stash->{'auction_item'}->find_or_new_related('auction_bids', {
        'firstname' => 'Manchester',
        'lastname'  => 'Phoenix',
        'email'     => 'info@manchesterphoenix.co.uk',
        'telephone' => '01613016848',
        'nick'      => 'Reserve',
    });

    if ( $form->submitted_and_valid ) {

        $form->model->update( $c->stash->{'auction_item'} );

        $bid->bid($form->param_value('reserve_amount'));
        $bid->bidtime($form->param_value('starts'));
        $bid->insert_or_update;

        $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
        return;
    }

    if (! $form->submitted && $c->stash->{'auction_item'}->id ) {
        $form->model->default_values( $c->stash->{'auction_item'} );
        $form->default_values({'reserve_amount' => $bid->bid });
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
