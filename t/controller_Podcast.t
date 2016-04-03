use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Podcast;

ok( request('/podcast')->is_success, 'Request should succeed' );
done_testing();
