({
    setFormData: function(component){
        var form = {
            'agreeCondition': '',
            'behalfOfWorker': '',
            'interpreter': '',
            'disabilities': '',
            'disabilitiesDetails': '',
            'language': '',
            'title': 'Mr.',
            'givenName': '',
            'surname': '',
            'dob': '',
            'dateOfInjury': '',
            'claimNo': '',
            'contact': '',
            'emailAddress': '',
            'postal': '',
            'suburb': '',
            'state': '',
            'postcode': '',
            'representativeName': '',
            'organisation': '',
            'emailAddressRepresentative': '',
            'representativeContact': '',
            'representativeDXAddress': '',
            'representativeAddress': '',
            'representativeSuburb': '',
            'representativeState': '',
            'representativePostcode': '',
            'insurer': '',
            'supportingDocumentAttached': '',
            'supportingDocumentAttachedDate': '',
            'notReviewDecisionDate': '',
            'workCapacityDecisionDate': '',
            'internalReviewDecisionDate': '',
            'decisionCurrentWorkCapacity': false,
            'decisionSuitableEmployment': false,
            'decisionAmountEarnInSuitableEmployment': false,
            'decisionAmountPreInjury': false,
            'decisionResultUnableEngageInEmployment': false,
            'otherInsurerAfferctsEntitlement': false,
            'imNotSure': false,
            'caseId': '',
            'caseNumber': '',
            'caseItemId': '',
            'reason': '',
            'caseOrigin': 'Post',
            'contactPreference': '',
            'representationDetails': '',
            'representativeState': ''
        }
        component.set('v.form', form);
    },
    todayDate: function(){
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        if(dd<10){
            dd='0'+dd;
        } 
        if(mm<10){
            mm='0'+mm;
        } 
        var today = dd+'/'+mm+'/'+yyyy;
        return today;
    },
    loadNewFormData: function(component, helper){
        var action = component.get('c.initiateNewCaseItem');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = JSON.parse(response.getReturnValue());
                var dob = returnValue.dob;
                if (dob)
                    returnValue.dob = dob.substring(8,10) + "/" + dob.substring(5,7) + "/" + dob.substring(0,4);
                var form = component.get('v.form');
                var final = jQuery.extend(form, returnValue);
                if (window.location.pathname.indexOf('insurerlegal') != -1) {
                    final.behalfOfWorker = 'no';
                    if (final.givenName)
                        final.representativeName = final.givenName + ' ' + final.surname;
                    final.representativeContact = final.contact;
                    final.emailAddressRepresentative = final.emailAddress;
                    final.representativeAddress = final.postal;
                    final.representativeSuburb = final.suburb;
                    final.representativeState = final.state;
                    final.representativePostcode = final.postcode;
                    final.title = '';
                    final.givenName = '';
                    final.surname = '';
                    final.dob = '';
                    final.contact = '';
                    final.emailAddress = '';
                    final.postal = '';
                    final.suburb = '';
                    final.state = '';
                    final.postcode = '';
                }
                component.set('v.form', final);
                component.set('v.formCopy', jQuery.extend({}, final));
                helper.saveForm(component, helper, true);
                window.setTimeout(
                    $A.getCallback(function() {
                        helper.saveForm(component, helper, true);
                    }), 60000
                );
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    loadExistFormData: function(component, applicationId){
        var action = component.get('c.getExistingCaseItem');
        action.setParams({caseItemId: applicationId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var applicationData = JSON.parse(response.returnValue);
                var statusValue = applicationData.status;
                if (!(statusValue == 'Pending' || statusValue == 'Draft') || component.get('v.isLoadedInSalesforce')) {
                    component.set('v.formLocked', true);
                    component.set('v.buttonDisable', true);
                }
                component.set('v.formStatus', statusValue);
                component.set('v.uploadDocuments', applicationData.attachments);
                if (applicationData.submittedBy) {
                    component.set('v.submittedBy', applicationData.submittedBy);
                    component.set('v.submittedDate', applicationData.submittedDate);
                }
                var caseId = applicationData.caseId;
                var caseItemId = applicationData.caseItemId;
                //console.log(applicationData);
                applicationData = JSON.parse(applicationData.caseItemData);
                applicationData.caseId = caseId;
                applicationData.caseItemId = caseItemId;
                component.set('v.form', applicationData);
                component.set('v.formCopy', jQuery.extend({}, applicationData));
                console.log(applicationData);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    saveForm: function(component, helper, autoSaveForm){
        component.set('v.autoSaving', true);
        var action = component.get('c.savePauseWorkerCaseItem');
        var params = JSON.stringify(component.get('v.form'));
        action.setParams({caseItemJson : params});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (autoSaveForm){
                window.setTimeout(function(){
                    helper.saveForm(component, helper, true);
                }, 60000);
            }
            else if (state === 'SUCCESS') {
                component.set('v.successMessage', 'Form saved!');
                window.scrollTo(0,0);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
                window.scrollTo(0,0);
            }
            component.set('v.autoSaving', false);
            component.set('v.buttonDisable', false);
        });
        
        $A.enqueueAction(action);
        console.log('form saved');
    },
    validateFields: function(component) {
        var valid = true;
        var validationMessages = [];
        var mandatoryFields = {
            'behalfOfWorker': 'Please indicate whether you are the worker filling in the application',
            'title': 'Please enter a Title',
            'givenName': 'Please enter a Given name(s)',
            'surname': 'Please enter a Surname',
            'dob': 'Please enter a Date of Birth',
            'contact': 'Please enter a Contact Number',
            'postal': 'Please enter a Postal Address',
            'suburb': 'Please enter a Suburb',
            'state': 'Please enter a State',
            'postcode': 'Please enter a Postcode',
            'claimNo': 'Please enter a Claim Number',
            'emailAddress': 'Please enter an Email Address',
            'supportingDocumentAttached': 'Please select one option that best describes your situation',
            'reason': 'Please enter a Reason'
        }

        Object.keys(mandatoryFields).forEach(function(field) {
            var cmp = component.find(field);
            var value = cmp.get('v.value');
            if (field == 'emailAddress' && window.location.pathname == "/apex/DRS_Case_WorkerCaseItemCreate" && component.get('v.form.caseOrigin') == 'Post'){
                //do nothing
            }
            else if (value){
                cmp.set('v.errorMessage', '');
            }
            else {
                cmp.set('v.errorMessage', mandatoryFields[field]);
                validationMessages.push({value: mandatoryFields[field]});
                valid = false;
            }
        });

        if (!component.find('insurer').get('v.selectedInsurer.Name')) {
            valid = false;
            $A.util.addClass(component.find('insurer').find('has-feedback'), 'has-error');
            component.find('insurer').set('v.validation', true);
            validationMessages.push({value: component.find('insurer').get('v.validationMessage')});
        }

        if (component.find('interpreter').get('v.value') == 'yes'){
            if (!component.find('language').get('v.value')){
                valid = false;
                component.find('language').set('v.errorMessage', 'Please enter a language');
                validationMessages.push({value: 'Please enter a language'});
            }
        }

        if (component.find('disabilities').get('v.value') == 'yes'){
            if (!component.find('disabilitiesDetails').get('v.value')){
                valid = false;
                component.find('disabilitiesDetails').set('v.errorMessage', 'Please enter the disabilities details');
                validationMessages.push({value: 'Please enter the disabilities details'});
            }
        }

        if (component.find('behalfOfWorker').get('v.value') == 'no') {
            var representativeFields = {
                'representationDetails': 'Please specify the type of representation',
                'representativeName': 'Please enter a Name of representative',
                'organisation': 'Please enter a Firm or organisation',
                'emailAddressRepresentative': 'Please enter an Email address',
                'representativeContact': 'Please enter a Contact number',
                'representativeDXAddress': 'Please enter a Post or DX address',
                'representativeAddress': 'Please enter a Street address',
                'representativeSuburb': 'Please enter a Suburb',
                'representativeState': 'Please enter a State',
                'representativePostcode': 'Please enter a Postcode'
            }
            Object.keys(representativeFields).forEach(function(field) {
                var cmp = component.find(field);
                var value = cmp.get('v.value');
                if (value){
                    cmp.set('v.errorMessage', '');
                }
                else {
                    cmp.set('v.errorMessage', representativeFields[field]);
                    validationMessages.push({value: representativeFields[field]});
                    valid = false;
                }
            });
        }

        var decisionCurrentWorkCapacity = component.find('decisionCurrentWorkCapacity');
        var decisionSuitableEmployment = component.find('decisionSuitableEmployment');
        var decisionAmountEarnInSuitableEmployment = component.find('decisionAmountEarnInSuitableEmployment');
        var decisionAmountPreInjury = component.find('decisionAmountPreInjury');
        var decisionResultUnableEngageInEmployment = component.find('decisionResultUnableEngageInEmployment');
        var otherInsurerAfferctsEntitlement = component.find('otherInsurerAfferctsEntitlement');
        var imNotSure = component.find('imNotSure');
        if (!decisionCurrentWorkCapacity.get('v.checked') && !decisionSuitableEmployment.get('v.checked') && 
            !decisionAmountEarnInSuitableEmployment.get('v.checked') && !decisionAmountPreInjury.get('v.checked') && 
            !decisionResultUnableEngageInEmployment.get('v.checked') && !otherInsurerAfferctsEntitlement.get('v.checked') && !imNotSure.get('v.checked')) {
            component.set('v.checkBoxRequired', true);
            valid = false;
            validationMessages.push({value: 'Please select one or more relevant work capacity decision(s) from the list'});
        }
        component.set('v.validationErrorMessages', validationMessages);
        return valid;
    },
    submitForm: function(component) {
        var action = component.get('c.saveWorkerCaseItem');
        var params = JSON.stringify(component.get('v.form'));        
        component.set('v.buttonDisable', true);
        action.setParams({caseItemJson : params});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (window.location.pathname == "/apex/DRS_Case_WorkerCaseItemCreate"){
                    component.set('v.successMessage', 'Form submitted!');
                    component.set('v.errorMessage', '');
                    window.scrollTo(0,0);
                    sforce.console.getEnclosingTabId(function(result3) {
                        sforce.console.closeTab(result3.id);
                    });
                    sforce.console.openPrimaryTab(null, '/' + component.get('v.form.caseId'), true, component.get('v.form.caseNumber'));
                }
                else window.location.href = "/" + component.get('v.communitylink') + "/s/casedetail?recordId=" + component.get('v.form.caseId');
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
                window.scrollTo(0,0);
            }
            component.set('v.buttonDisable', false);
        });
        if (component.get('v.autoSaving')){
            window.setTimeout(
                $A.getCallback(function() {
                    helper.saveForm(component, helper, true);
                }), 5000
            );
        }
        else 
            $A.enqueueAction(action);
    }
})