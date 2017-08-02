({
	download : function(component, event, helper) {
        var CaseList = component.get("v.casesToExport");              
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();        
        
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        //Provide the title         
        //Fill out the Header of CSV		
        headerArray.push("SIRA REF NUMBER");
        headerArray.push("INSURER PROCESS STATUS");
        headerArray.push("INSURER NAME");
        headerArray.push("DATE MATCHED TO INSURER DD");
        headerArray.push("DATE MATCHED TO INSURER MM");
        headerArray.push("DATE MATCHED TO INSURER YYYY");
        headerArray.push("ACCIDENT DATE DD");
        headerArray.push("ACCIDENT DATE MM");
        headerArray.push("ACCIDENT DATE YYYY");
        headerArray.push("AT FAULT REG");
        headerArray.push("ACCIDENT LOCATION");
        headerArray.push("INJ FIRST NAME");
        headerArray.push("INJ LAST NAME");
        headerArray.push("INJ EMAIL");
        headerArray.push("INJ PHONE");
        headerArray.push("ACCIDENT ROLE");
        headerArray.push("OTHER ACCIDENT ROLE");       
        headerArray.push("FORM SUBMITTER");
        headerArray.push("REP TYPE");
        headerArray.push("REP TYPE OTHER");
        headerArray.push("REP FIRST NAME");
        headerArray.push("REP LAST NAME");
        headerArray.push("REP EMAIL");
        headerArray.push("REP PHONE");
        headerArray.push("SEND TO");     
                
        data.push(headerArray);
        
        for(var i=0; i< CaseList.length ; i++){
            //Initialize the temperory array
            var tempArray = [];
            var cs = CaseList[i];
			tempArray.push('"'+removeUndifind(cs.CaseNumber)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_InsurerStatus__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_Insurer__r.Name)+'"');	
            tempArray.push('"'+removeUndifind(cs.OLCN_MatchedDay__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_MatchedMonth__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_MatchedYear__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentDay__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentMonth__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentYear__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AtFaultRegistrationNumber__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentLocation__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormFirstName__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormLastName__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormEmail__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormPhone__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentRole__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_AccidentRoleOther__c)+'"');            
            tempArray.push('"'+removeUndifind(cs.OLCN_FormSubmitter__c)+'"');            
            tempArray.push('"'+removeUndifind(cs.OLCN_RepType__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_RepTypeOther__c)+'"');            
            tempArray.push('"'+removeUndifind(cs.OLCN_FormRepFirstName__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormRepLastName__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormRepEmail__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_FormRepPhone__c)+'"');
            tempArray.push('"'+removeUndifind(cs.OLCN_SendTo__c)+'"');
                              
            data.push(tempArray);           
        }
       
        for(var j=0;j<data.length;j++){
            var dataString = data[j].join("\t");
            csvContentArray.push(dataString);
        }
     //   var csvContent = CSV + csvContentArray.join("\r\n");
     var csvContent = csvContentArray.join("\r\n");
        
        //Generate a file name
        
        var fileName = "CTP_Notification-"+dd+'/'+mm+'/'+yyyy+'.xls';
		
        //Initialize file format you want csv or xls
         var uri = "data:text/csv;charset=utf-8," + encodeURIComponent(csvContent);
        
	      if (navigator.msSaveBlob) { // IE 10+
            console.log("----------------if-----------");
            var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
            console.log("----------------if-----------"+blob);
        	navigator.msSaveBlob(blob, fileName);
        }
        else{
            // Download file
            // you can use either>> window.open(uri);
            // but this will not work in some browsers
            // or you will not get the correct file extension    
            var link = document.createElement("a");

            //link.download to give filename with extension
            //link.download = fileName;
            link.setAttribute("download",fileName);
            //To set the content of the file
            link.href = uri;
            
            //set the visibility hidden so it will not effect on your web-layout
            link.style = "visibility:hidden";
            
            //this part will append the anchor tag and remove it after automatic click
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
          
    	}
        function removeUndifind(FieldValue)
         {
             if(FieldValue !== undefined)
                return FieldValue;
             else 
                return 'Null';
        }
    }
    })