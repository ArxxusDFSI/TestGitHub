/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the controller class for InsurerPortal_CommunitiesLogin
                        
Test Class:     InsurerPortal_LoginControllerTest
History
13/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class InsurerPortal_CommunitiesLoginController {

    global InsurerPortal_CommunitiesLoginController() {}
    
    // Code we will invoke on page load.
    public PageReference forwardToCustomLandingAuthPage() {
        String startURL = '';
        if(System.currentPageReference().getParameters().containsKey('startURL')) {
            startUrl = System.currentPageReference().getParameters().get('startURL');
        } 
        String listViewId =MetaUtilityOLCN.getGeneralSettingValue('InsurerLandingCaseView');          
        return new PageReference(Site.getPathPrefix() + '/s/case/Case/'+listViewId+EncodingUtil.urlEncode(startURL, 'UTF-8'));
    }
    
    global PageReference forwardToCustomAuthPage() {
        String startUrl ='';
        startUrl = System.currentPageReference().getParameters().get('startURL');
        if((String.isNotBlank(startUrl)|| startUrl!=null) && startUrl.toLowerCase().contains('insurerportalUserLogin')) {startUrl = '';}else{ startUrl ='';}
        return new PageReference(Site.getPathPrefix() + '/s/insurerportalUserLogin?startURL=' + EncodingUtil.urlEncode(startURL, 'UTF-8'));
    }
    
}