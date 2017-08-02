/**
* An apex page controller that exposes the site login functionality
*/
global with sharing class CommunitiesLoginController {
    
    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
    
    global PageReference forwardToCustomAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if(String.isNotBlank(startUrl) && startUrl.toLowerCase().contains('userlogin')) {startUrl = '';}
        return new PageReference(Site.getPathPrefix() + '/s/userlogin?startURL=' + EncodingUtil.urlEncode(startURL, 'UTF-8'));
    }
}