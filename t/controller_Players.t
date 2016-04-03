use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Players;

ok( request('/players')->is_success, 'Request should succeed' );
done_testing();
