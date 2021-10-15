#==============================================================================
# §package      DE_EPAGES::Google::API::Constants
# §state        public
# §description  Constants of cartridge Google
#==============================================================================
package DE_EPAGES::Google::API::Constants;
use base Exporter;

use strict;
our @EXPORT_OK = qw (
   GOOGLE_SCRIPT_URL_QUERY
);

#========================================================================================
# §global       GOOGLE_SCRIPT_URL_QUERY | URL query for the Google script | string
#========================================================================================
use constant GOOGLE_SCRIPT_URL_QUERY    => '?ViewAction=UnityViewGoogleScript';

1;
