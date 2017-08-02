({
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
    }/*,
    
    addCaseTeamMember: function(component) {
        $A.createComponent('c:UI_AddTeamMemberRole', {
                caseTeamMember : component.find('caseTeamMember').get('v.selectedMember'),
                caseTeamRoles : $('#caseTeamRoles').val()
            }, 
            function(newUser, status, errorMessage){
                var body = component.get("v.caseTableBody");
                var users = component.get('v.users');
                body.push(newUser);
                component.set("v.caseTableBody", body);
                users.push({
                    caseId: component.get('v.caseId'),
                    caseTeamMemberId: '',
                    isAdded: true,
                    isRemoved: false,
                    memberId: newUser.get('v.caseTeamMember').userId,
                    memberName: newUser.get('v.caseTeamMember').userName,
                    roleId: $('#caseTeamRoles').find(':selected')[0].data,
                    roleName: $('#caseTeamRoles').val()
                }) 
                component.set("v.users", users);
            }
        );
    }*/
})