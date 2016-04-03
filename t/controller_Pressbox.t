use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Pressbox;

ok( request('/pressbox')->is_success, 'Request should succeed' );
done_testing();
