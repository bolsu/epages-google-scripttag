#==============================================================================
# §package      DE_EPAGES::Google::UI::Shop
# §base         DE_EPAGES::Order::UI::Shop
# §state        private
#==============================================================================
package DE_EPAGES::Google::UI::Shop;
use base DE_EPAGES::Presentation::UI::Object;

use strict;

use DE_EPAGES::Trigger::API::Trigger qw ( TriggerHook );

sub UnitySave {
    my $self = shift;
    my ($Servlet) = @_;

    my $hValues = $Servlet->form->form($Servlet->object, 'SaveGoogleSearch');
    my $GoogleSiteVerificationToken = $hValues->{'GoogleSiteVerificationToken'};

    if($GoogleSiteVerificationToken =~ /^google[a-f0-9]+\.html$/  || $GoogleSiteVerificationToken eq ""){
        $self->SUPER::Save($Servlet);  
    }
    else{
        $Servlet->form->executeFormError({
            'Name'       => 'GoogleSearchHTMLFile',
            'Reason'     => 'WrongFormat',
        });
    }
}

sub UnityMBOViewGoogleSearch {
    my $self = shift;
    my ($Servlet) = @_;

    # trigger hook to allow the adding of context sensitive apps
    TriggerHook('UI_Shop_UnityViewGoogleSearch', { 'Servlet' => $Servlet });

    return $self->SUPER::View($Servlet);
}

sub UnitySFViewGoogleHTML {
    my $self = shift;
    my ($Servlet) = @_;
    my $Shop = $Servlet->object->get('Site');
    my $Response = $Servlet->response;
    $Response->header( 'Content-Type' => 'text/html' );

    my $GoogleSiteVerificationToken = $Shop->get('GoogleSiteVerificationToken');
    my $GSSSiteVerificationToken;

    my $RequestURI;
    if ($Servlet->serverVariables('QUERY_STRING') =~ /^URI=([^&]+)/) {
        $RequestURI = $1;
    }

    if ($Shop->existsChild('GoogleSmartShoppingConfig')) {
        my $GoogleSmartShoppingConfig = $Shop->get('GoogleSmartShoppingConfig');
        $GSSSiteVerificationToken = $GoogleSmartShoppingConfig->get('SiteVerificationToken');
    }

    if($GoogleSiteVerificationToken && $GoogleSiteVerificationToken eq $RequestURI) {
        # display html file for Google search
        my $Content= 'google-site-verification: ' . $GoogleSiteVerificationToken;
        $Response->content( $Content);
    } elsif ($GSSSiteVerificationToken && $GSSSiteVerificationToken eq $RequestURI) {
        # will be processed in GoogleSmartShopping cartridge, return and don't show error 404 here
        return;
    } else {
        # display 404 error
        $Response->content('No google*.html available.');
        $Response->code('404');
    }

    $Servlet->vars('ExitAfterEvent', 1);

    return;
}

1;
