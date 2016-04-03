use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::Announcements;

ok( request('/announcements')->is_success, 'Request should succeed' );
done_testing();
