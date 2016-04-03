use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Results;

ok( request('/results')->is_success, 'Request should succeed' );
done_testing();
