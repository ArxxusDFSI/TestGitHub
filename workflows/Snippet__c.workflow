<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Snippet_Unique_Name</fullName>
        <description>Updates the Unique Name Validation field on Snippet object to check the uniqueness of the name.</description>
        <field>UniqueNameValidation__c</field>
        <formula>UniqueName__c</formula>
        <name>Update Snippet Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Snippet Create Update</fullName>
        <actions>
            <name>Update_Snippet_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The workflow rule to fire on create and update operations for the snippets.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
