use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Articles::Images;

ok( request('/articles/images')->is_success, 'Request should succeed' );
done_testing();
