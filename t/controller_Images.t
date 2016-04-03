use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Images;

ok( request('/images')->is_success, 'Request should succeed' );
done_testing();
