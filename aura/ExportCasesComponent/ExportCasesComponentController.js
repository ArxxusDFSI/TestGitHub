({
    exportOlcnAllOpenCases : function (component,event, helper){
        var action = component.get("c.getCaseList");
        action.setParams({"lastndays":""});
        action.setCallback(this, function(a) {
            component.set("v.casesToExport", a.getReturnValue());            
            helper.download(component);
            
        });
        $A.enqueueAction(action);
       
      },
    
    exportOlcnLast30daysCases : function (component,event, helper){
        
        var action = component.get("c.getCaseList");
        action.setParams({"lastndays":"30"});
        action.setCallback(this, function(a) {
            component.set("v.casesToExport", a.getReturnValue());            
            helper.download(component);
        });
        $A.enqueueAction(action);
      }
})