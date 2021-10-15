use strict;
use Getopt::Long;
use List::Util qw( none );
use Time::HiRes qw( time );
use DE_EPAGES::AppStore::API::Shop qw( GetUnityScriptTagsApp );
use DE_EPAGES::Core::API::Error qw( GetError ExistsError );
use DE_EPAGES::Core::API::Script qw( RunScript );
use DE_EPAGES::Database::API::Connection qw( RunOnStore );
use DE_EPAGES::Object::API::Factory qw( LoadObject LoadObjectByPath );
use DE_EPAGES::Shop::API::System qw( GetUnityShopIDs );
use DE_EPAGES::Google::API::Constants qw ( GOOGLE_SCRIPT_URL_QUERY );

#========================================================================================
# §function         PatchAddGoogleScriptTag
# §state            public
#----------------------------------------------------------------------------------------
# §syntax           PatchAddGoogleScriptTag();
#----------------------------------------------------------------------------------------
# §description      Registers the Google script tag
#========================================================================================
sub PatchAddGoogleScriptTag {
    my ($ShopAlias) = @_;

    if (defined $ShopAlias) {
        # single shop run
        my $Shop = LoadObjectByPath('/Shops/'.$ShopAlias);
        if ($Shop->isUnity()) {
            # Unity shop
            _PatchAddGoogleScriptTag($Shop);
        } else {
            # non Unity shop
           print 'Shop ' . $ShopAlias . " is not a Unity shop.\n";
        }
    } else {
        # all Unity shops
        my $aShopIDs = GetUnityShopIDs();

        foreach my $ShopID (@$aShopIDs) {
            eval {
                my $Shop = LoadObject($ShopID);
                _PatchAddGoogleScriptTag($Shop);
            };
            warn('Patch of the Google ScriptTag failed for shop ID ' . $ShopID . " with error \"" . GetError() . "\".")
                if ExistsError();
        }
    }

    return;
}

sub _PatchAddGoogleScriptTag {
    my ($Shop) = @_;

    my $ScriptTagAppClient = GetUnityScriptTagsApp($Shop);
    my $aScriptTags = $ScriptTagAppClient->getAllScriptTags();

    my $GoogleScriptTagUrl = $Shop->get('WebServerScriptName') . GOOGLE_SCRIPT_URL_QUERY;

    $ScriptTagAppClient->addScriptTag($GoogleScriptTagUrl)
        if none {$_->{'scriptUrl'} eq $GoogleScriptTagUrl} @$aScriptTags;
}

sub Main {

    local $| = 1;

    my $Password;
    my $StoreName;
    my $ShopAlias;
    my $Help;

    GetOptions(
        'help'        => \$Help,
        'passwd=s'    => \$Password,
        'storename=s' => \$StoreName,
        'shopid=s'    => \$ShopAlias,
    );

    usage() if $Help;

    unless ( defined $StoreName ) {
        print STDERR "Missing parameter -storename.\n\n";
        usage();
    }
    my $time1 = time;

    RunOnStore(
        Store      => $StoreName,
        DBPassword => $Password,
        Sub        => sub { PatchAddGoogleScriptTag($ShopAlias); },
    );
    my $time2 = time;
    printf "need %.1f seconds\n", $time2 - $time1;
}

sub usage {
    print <<END_USAGE;
Description:
    Registers the Google script tag.
Usage:
    perl $0 [options] [flags] datafiles

options:
    -passwd     database user password                          ()
    -storename  name of store                                   ()
    -shopalias  alias of a single shop                      (optional)
                (if not given, the script is preformed for all Unity shops)
flags:
    -help       show the command line options

Example:
    perl $0 -storename Store
END_USAGE
    exit 2;
}

RunScript( 'Sub' => \&Main );