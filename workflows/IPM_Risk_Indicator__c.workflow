<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IPM_Risk_Indicator_Outcome_Email_Alert</fullName>
        <description>Risk Indicator Outcome Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>IPM_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IPM_Insurer_Portfolio_Management/IPM_Risk_Indicator_Review_Outcome</template>
    </alerts>
    <fieldUpdates>
        <fullName>IPM_Remove_Request_for_New_Rating_Reason</fullName>
        <field>IPM_Request_for_New_Rating_Reason__c</field>
        <name>Remove Request for New Rating Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPM_Remove_Requested_New_Rating</fullName>
        <field>IPM_Requested_New_Rating__c</field>
        <name>Remove Requested New Rating</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPM_Remove_S_Drive_Folder</fullName>
        <field>IPM_S_Drive_Folder__c</field>
        <name>Remove S Drive Folder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPM_Remove_Submitted</fullName>
        <field>IPM_Submitter__c</field>
        <name>Remove Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IPM_Update_Approval_Flag</fullName>
        <field>IPM_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Approval Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
