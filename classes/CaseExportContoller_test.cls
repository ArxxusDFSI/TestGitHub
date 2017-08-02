/*******************************************************************************************
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the Lightening Component for CaseExportContoller Page                      
Test Class:     CaseExportContoller_test
History
13/July/2017    Shyamala Sridevi     Created
********************************************************************************************/
@isTest
public class CaseExportContoller_test
{
    Public static testmethod void testGetCaseList()
    {
           CaseExportContoller.getCaseList('');
           CaseExportContoller.getCaseList('30');
           
    }

}