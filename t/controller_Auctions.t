use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Auctions;

ok( request('/auctions')->is_success, 'Request should succeed' );
done_testing();
