/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the test class for InsurerPortal_LightningLoginController.
                        
Test Class:     InsurerPortal_LightningLoginCtrTest
History
14/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
@IsTest(seeAllData = true)
public with sharing class InsurerPortal_LightningLoginCtrTest
{

     @IsTest
     static void testLoginWithInvalidCredentials() {
          System.assertEquals('Argument 1 cannot be null', InsurerPortal_LightningLoginController.login('testUser', 'fakepwd', null));
     }
    
     @IsTest
     static void insurerPortal_LightningLoginControllerInstantiation() {
          insurerPortal_LightningLoginController controller = new insurerPortal_LightningLoginController();
          System.assertNotEquals(controller, null);
     }
    
     @IsTest
     static void testIsUsernamePasswordEnabled() {
          System.assertEquals(true, insurerPortal_LightningLoginController.getIsUsernamePasswordEnabled());
     }
    
     @IsTest
     static void testIsSelfRegistrationEnabled() {
          System.assertEquals(false, insurerPortal_LightningLoginController.getIsSelfRegistrationEnabled());
     }
    
     @IsTest
     static void testGetSelfRegistrationURL() {
          System.assertEquals(null, insurerPortal_LightningLoginController.getSelfRegistrationUrl());
     } 
        
     @IsTest
     static void testAuthConfig() {
          Auth.AuthConfiguration authConfig = insurerPortal_LightningLoginController.getAuthConfig();
          System.assertNotEquals(null, authConfig);
     }
}