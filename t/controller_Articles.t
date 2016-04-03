use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Articles;

ok( request('/articles')->is_success, 'Request should succeed' );
done_testing();
