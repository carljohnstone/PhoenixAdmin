use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::AdoptAPlayer;

ok( request('/adoptaplayer')->is_success, 'Request should succeed' );
done_testing();
