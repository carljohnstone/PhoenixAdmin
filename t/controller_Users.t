use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Users;

ok( request('/users')->is_success, 'Request should succeed' );
done_testing();
