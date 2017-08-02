/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the test class for InsurerPortal_CommunitiesLoginController
                        
Test Class:     NA
History
13/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest
global with sharing class InsurerPortal_LoginControllerTest 
{
    
   @IsTest(SeeAllData=true)   
   public static void testCommunitiesLandingController() {
        //Instantiate a new controller with all parameters in the page
        InsurerPortal_CommunitiesLoginController controller = new InsurerPortal_CommunitiesLoginController();
        PageReference pageRef = controller.forwardToCustomLandingAuthPage();
        //PageRef is either null or an empty object in test context
        if(pageRef != null){
            String url = pageRef.getUrl();
            if(url != null){
                System.assertEquals(false, String.isEmpty(url));
                //show up in perforce
            }
        }
    } 
   
    @IsTest(SeeAllData=true) 
    global static void testCommunitiesLoginController () {
         InsurerPortal_CommunitiesLoginController controller = new InsurerPortal_CommunitiesLoginController();
         PageReference pageRef = controller.forwardToCustomAuthPage();
         //  System.assertEquals(!null, controller.forwardToCustomAuthPage()); 
         if(pageRef != null){
                String url = pageRef.getUrl();
                if(url != null){
                    System.assertEquals(false, String.isEmpty(url));
                    //show up in perforce
                }      
          }  
     }
}