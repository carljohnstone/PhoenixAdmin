use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PhoenixAdmin';
use PhoenixAdmin::Controller::SupporterSponsorships;

ok( request('/supportersponsorships')->is_success, 'Request should succeed' );
done_testing();
