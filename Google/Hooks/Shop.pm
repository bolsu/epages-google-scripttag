#========================================================================================
# §package      DE_EPAGES::Google::Hooks::Shop
# §state        public
# §description  interface for Shop
#========================================================================================
package DE_EPAGES::Google::Hooks::Shop;
use base qw( Exporter );

use strict;
use DE_EPAGES::Google::API::Constants qw ( GOOGLE_SCRIPT_URL_QUERY );

#========================================================================================
# §function     OnRegisterInitialScriptTags
#----------------------------------------------------------------------------------------
# §syntax       OnRegisterInitialScriptTags($hParams);
#----------------------------------------------------------------------------------------
# §description  Adds the Google script tag to the list of script tags that should
#                   be registered upon creation of a Unity shop
#----------------------------------------------------------------------------------------
# §input        $hParams | hook parameter
#               <ul>
#                   <li>Shop - the current Shop - object
#                   <li>ScriptTagUrls - list of scrip tag URLs - ref.array
#               </ul> | ref.hash.*
#========================================================================================
sub OnRegisterInitialScriptTags {
    my ($hParams) = @_;
    my $Shop = $hParams->{'Shop'};

    my $GoogleScriptTagUrl = $Shop->get('WebServerScriptName') . GOOGLE_SCRIPT_URL_QUERY;

    push @{$hParams->{'ScriptTagUrls'}}, $GoogleScriptTagUrl;
}

1;
