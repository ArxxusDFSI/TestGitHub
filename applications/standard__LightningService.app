<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <actionOverrides>
        <actionName>View</actionName>
        <comment>Action override created by Lightning App Builder during activation.</comment>
        <content>Case_Record_Page</content>
        <formFactor>Large</formFactor>
        <skipRecordTypeSelect>false</skipRecordTypeSelect>
        <type>Flexipage</type>
        <pageOrSobjectType>Case</pageOrSobjectType>
    </actionOverrides>
    <actionOverrides>
        <actionName>View</actionName>
        <comment>Action override created by Lightning App Builder during activation.</comment>
        <content>Contact_Record_Page</content>
        <formFactor>Large</formFactor>
        <skipRecordTypeSelect>false</skipRecordTypeSelect>
        <type>Flexipage</type>
        <pageOrSobjectType>Contact</pageOrSobjectType>
    </actionOverrides>
    <actionOverrides>
        <actionName>View</actionName>
        <comment>Action override created by Lightning App Builder during activation.</comment>
        <content>OLCNAccountLayout</content>
        <formFactor>Large</formFactor>
        <skipRecordTypeSelect>false</skipRecordTypeSelect>
        <type>Flexipage</type>
        <pageOrSobjectType>Account</pageOrSobjectType>
    </actionOverrides>
    <actionOverrides>
        <actionName>View</actionName>
        <comment>Action override created by Lightning App Builder during activation.</comment>
        <content>NotificationFollow_upLayout</content>
        <formFactor>Large</formFactor>
        <skipRecordTypeSelect>false</skipRecordTypeSelect>
        <type>Flexipage</type>
        <pageOrSobjectType>OLCN_OutboundCalls__c</pageOrSobjectType>
    </actionOverrides>
    <brand>
        <headerColor>#00417B</headerColor>
        <logo>SIRA_NSW_Logo2</logo>
        <logoVersion>1</logoVersion>
    </brand>
    <description>This application supports day operations, including Claims Assistance, Dispute Resolution, and Compliance.</description>
    <formFactors>Large</formFactors>
    <label>SIRA Online Claims Console</label>
    <navType>Console</navType>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>NotificationFollow_upLayout</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>OLCN_OutboundCalls__c</pageOrSobjectType>
        <type>Flexipage</type>
        <profile>~CAS User</profile>
    </profileActionOverrides>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>NotificationFollow_upLayout</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>OLCN_OutboundCalls__c</pageOrSobjectType>
        <type>Flexipage</type>
        <profile>Admin</profile>
    </profileActionOverrides>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>Case_Record_Page</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Case</pageOrSobjectType>
        <recordType>Case.Online_Claims_Notification</recordType>
        <type>Flexipage</type>
        <profile>~CAS User</profile>
    </profileActionOverrides>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>Case_Record_Page</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Case</pageOrSobjectType>
        <recordType>Case.Online_Claims_Notification</recordType>
        <type>Flexipage</type>
        <profile>Admin</profile>
    </profileActionOverrides>
    <setupExperience>ServiceSetup</setupExperience>
    <tab>standard-home</tab>
    <tab>standard-Feed</tab>
    <tab>standard-Case</tab>
    <tab>Activities</tab>
    <tab>OLCN_OutboundCalls__c</tab>
    <tab>standard-Account</tab>
    <tab>standard-Contact</tab>
    <tab>standard-report</tab>
    <tab>standard-Dashboard</tab>
    <uiType>Lightning</uiType>
    <utilityBar>LightningService_UtilityBar</utilityBar>
</CustomApplication>
