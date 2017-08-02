/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the controller class for InsurerPortal_CommunitiesLogin.
                        
Test Class:     InsurerPortal_LightningLoginCtrTest
History
14/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
global class InsurerPortal_LightningLoginController 
{

    public InsurerPortal_LightningLoginController() {
        
    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl) 
    {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return Null; 
           // return lgn.getUrl();
        }
        catch (exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean isAuthenticated() {
        System.debug('---LightningLoginFormController:isAuthenticated:UserInfo.getUserType():' + UserInfo.getUserType());
        if(UserInfo.getUserType() == 'Guest' || UserInfo.getUserType() == 'Standard') return false;
        return true;
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
}