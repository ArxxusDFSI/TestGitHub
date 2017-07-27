
//namespace
var rock = rock || {};
var copadoApp = copadoApp || {};

rock.stepType = copadoApp.mode;
rock.createCacheDeleteButton = function(date){
    if(!date){
         $copado('[id*=pbb_removeCacheContainer]').hide();
    }else{
        var $btn = $copado('[id$=removeCache]');
        $btn.html($btn.html().replace('__DATE__',date)).show();
    }    
};
rock.removeCached = function(){
    //hide
    $copado('[id*=pbb_removeCacheContainer]').html('');
    $copado('#jqxgrid').html(loadingHTML);
    //reload
    init(true);
    return false;
};


//config grid
rock.startGrid = function (data) {
        //normalize data
        var len = data.length,
        hasFilter = false;

        //prev selected items
        rock._apexItemTypes = ['ApexTrigger','ApexClass'];
        rock._prevSelectedApexItems = [];
        
        while(len--){
            var d = data[len];
           d.s = d.s || false;

           //save prev ApexTrigger and ApexClass selected
           if(d.s && ( $copado.inArray(d.t ,rock._apexItemTypes)>-1)){
                //add the class name
                rock._prevSelectedApexItems.push(d.n); 
           } 
          
        }
            
        try{    
            var theme = 'base',
            
            source = {
                localdata: data,
                datafields: [
                    { name: 's', type: 'bool' },
                    { name: 't', type: 'string' },
                    { name: 'n', type: 'string' },
                    { name: 'b', type: 'string' },
                    { name: 'd', type: 'string' },
                    { name: 'cb', type: 'string' },
                    { name: 'cd', type: 'string' }
                ],
                datatype: "array",
                updaterow: function (rowid, rowdata, commit) {
                    commit(true);
                    data[rowid] = rowdata;
                }
            };
    
            if(copadoApp.mode=='ApexTests'){
                source.datafields = [
                        { name: 's', type: 'bool' },
                        { name: 'n', type: 'string' },
                        { name: 'ns', type: 'string' }
                    ];
              
            };
            //adapter wrapper
            dataAdapter = new $copado.jqx.dataAdapter(source);
            
            //keep jquery pointer for performance query
            $grid = $copado('<div>');
            
            $copado("#jqxgrid").html($grid);
            
            rock.datasource = source;
            
            var height = utilsV2.getUrlParameter('height');
            height = (height)?height:300;
        
            var pageSize = utilsV2.getUrlParameter('pageSize');
            pageSize = (pageSize)?parseInt(pageSize):200;

            $grid.jqxGrid({
                width: '100%',
                height: height,
                source: dataAdapter,
                showfilterrow: true,
                filterable: true,
                theme: theme,
                editable: true, 
                selectionmode: 'none',
                enablebrowserselection: true,
                pageable: true,
                pagesizeoptions: ['10', '20', '50','100','200','500','1000','2000','5000'],
                pagesize: pageSize,
                sortable: true,
                columnsresize: true,
                localization: localizationobj,
                columns: [
                  {text: copadoLabels.selected, columntype: 'checkbox', filtertype: 'bool', datafield: 's', width: 60 },
                  {text: copadoLabels.name, filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'n', width: 400},
                  {text: copadoLabels.type, datafield:'t', filtertype:'checkedlist', editable:false, columntype:'textbox' },
                  {text: copadoLabels.LASTMODIFIEDBY, filtertype: 'checkedlist', editable:false, datafield: 'b', width: 220},
                  {text: copadoLabels.LastModifiedDate, filtertype: 'textbox', editable:false, datafield: 'd', width: 120},
                  {text: copadoLabels.CREATEDBY, filtertype: 'checkedlist', editable:false, datafield: 'cb', width: 220},
                  {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield: 'cd', width: 120}
                ]
            });
            if(copadoApp.mode=='ApexTests'){
                $grid.jqxGrid({
                    pagesizeoptions: ['10', '20', '50','100','200','500','1000','2000','5000'],
                    pagesize: 200,
                    columns: [
                      {text: copadoLabels.selected, columntype: 'checkbox', filtertype: 'bool', datafield: 's', width: 60 },
                      {text: copadoLabels.name, filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'n'},
                      {text: 'Namespace', filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'ns', width:400}
                    ]
                });
            };
            var selectAll = function(sel){
                $grid.jqxGrid('beginupdate');
                var list = $grid.jqxGrid('getrows');
                for(var i in list){
                    source.localdata[ list[i].dataindex || i ].s = sel;
                }
            
                $grid.jqxGrid('endupdate');
                setTimeout(function(){$grid.jqxGrid('updatebounddata','cells');},222);
            },
            
            $unselectAll = $copado('<button>Unselect All</button>').
                on('click',function(e){
                    e.preventDefault();
                    selectAll(false);
                }),
            
            $selectAll = $copado('<button>Select All</button>').
                on('click',function(e){
                    e.preventDefault();
                    selectAll(true);
                });
       
            $copado('.jqx-grid-pager > div')
                .prepend($unselectAll)
                .prepend($selectAll);
        }catch(e){
            console.error(e)
        }
};
 
rock.getSelectedObj = function(){
    var data = rock.datasource.localdata, 
    len = data.length;

    rock.selectedNames = [];

    while(len--){
        var o = {n:data[len].n,s:true,d:data[len].d,b:data[len].b,cd:data[len].cd,cb:data[len].cb};
        if(typeof data[len].ns != 'undefined'){
            o.ns = data[len].ns;
        }else{
            o.t = data[len].t ;
        }
        
        data[len].s && rock.selectedNames.push(o);
    }
    return rock.selectedNames;
};
     
//selected "Names"
rock.selectedNames = rock.selectedNames || [];
rock.selectedTypes = rock.selectedTypes || [];

rock.getIndexByNT = function(arr, n,t){
    //console.log('index',n,t);

    var initialIndex =  0 ;// todo improve index chache >> this.initialIndex || 0,
    len = arr.length;
     
    for(initialIndex; initialIndex < len ;initialIndex++ ){
        var el = arr[initialIndex];
        try{ 
            if( el.n === n && (el.t === t || el.ns === t)){
                this.initialIndex = initialIndex;
                return initialIndex;
            }
        }catch(e){
            console.error(e);
            return -1;
        }

    }
    return -1;
};
 

// Polyfill https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign#Browser_compatibility
if (typeof Object.assign != 'function') {
  Object.assign = function(target, varArgs) { // .length of function is 2
    'use strict';
    if (target == null) { // TypeError if undefined or null
      throw new TypeError('Cannot convert undefined or null to object');
    }

    var to = Object(target);

    for (var index = 1; index < arguments.length; index++) {
      var nextSource = arguments[index];

      if (nextSource != null) { // Skip over if undefined or null
        for (var nextKey in nextSource) {
          // Avoid bugs when hasOwnProperty is shadowed
          if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
            to[nextKey] = nextSource[nextKey];
          }
        }
      }
    }
    return to;
  };
}


rock.mergeSavedMeta = function(metaOrgData,dataStep){

    var len = dataStep.length;
                         
    while(len--){
        if(typeof dataStep[len] !== 'object'){
            delete dataStep[len];
        }else{
            dataStep[len].s =true;
        }
    }

    //console.log('merge',metaOrgData,dataStep)
     
    var len2 = dataStep.length;
    for(var i = 0; i < len2 ; i++){
        var el = dataStep[i];
        //console.log(el, el.n,el.t||el.ns);

        var index = rock.getIndexByNT(metaOrgData,el.n,(el.t||el.ns));
        //console.log(index)
        if(index > -1){
            // nr: merge "el" into metaOrgData[index]. This guarantees that any property in el, will be added.
            Object.assign(metaOrgData[index], el);
            metaOrgData[index].s = true;
            //rock.selectedNames.push(data[index]);
        }else{
            //console.log('Not found:', el );
            if(typeof(window._errNotFoundShown) == 'undefined' ){
                window._errNotFoundShown = true;
                alert(copadoLabels.missing_element_msg+(el.t||el.ns)+' - '+el.n);
            }
        }
    }

    //console.log('merged',metaOrgData );
    return metaOrgData;
};

function deleteAttachment(){
    name = copadoApp.mdoe=='ApexTests' ? 'ApexTestClasses': 'MetaData';
    parentId = copadoApp.userStoryId;
    var result = dw.u.getAttach(parentId, name);
    if(result.length == 1)sforce.connection.deleteIds([result[0].Id]);
    copadoApp.showMessage('CONFIRM',copadoLabels.DELETE_SUCCESS_CLOSE_WINDOW, -1);
    init(false);
    return false;
} 
function init(force){   
    lockScreen();
    
    var atts = JsRemoting.attachments.getAttachmentByFileName_NoBody(copadoApp.orgCredential, copadoApp.mode);
    console.log('Org cache: ', atts);
    if(atts && atts.length && atts[0].BodyLength && atts[0].BodyLength>600000){
        var uri = _config.server.mergeUrl;
        
        rock.createCacheDeleteButton(Date.fromISOString(atts[0].LastModifiedDate).toLocaleString());
    
        statusManager.successFunction = function(){
            var mdsAtt = JsRemoting.attachments.getDecodedAttachment(copadoApp.userStoryId, 'MetaDataSelection');
            if(mdsAtt!=null){
                var decoded = Base64.decode(mdsAtt[0].Body);
                var mergeObj = JSON.parse(decoded);
                statusManager.stopStatusChecker();
                rock.startGrid(mergeObj);
            }
        };
        statusManager.parentId = copadoApp.userStoryId;
        statusManager.startProcess(function() {
            utilsV2.onSuccessCB = function(res){
                var obj = $copado.parseJSON(res);
                if(obj.copadoJobId){
                    statusManager.copadoJobId = obj.copadoJobId;
                    statusManager.startStatusChecker();
                }
            }
            utilsV2.onFailureCB = function(res){
                console.error('Error calling metadata merge process: '+res);
                alert(res);
                statusManager.stopStatusChecker();
                unlockScreen();
            };
            utilsV2.getRemote(uri);
        });
        return false;
    }
    else{
        dw.u.getCachedRemote({
            url: rock.config.metadata_url,
            name: copadoApp.mode == 'ApexTests' ? 'ApexTestClasses': 'MetaData',
            parentId: copadoApp.orgCredential,
            force: force,
            success:function(metaOrgData, cachedDate){
                rock.stepId = copadoApp.userStoryId;
                var savedItems = dw.u.getSavedStepData(copadoApp.mode=='ApexTests' ? 'ApexTestClasses':'MetaData', false);
                  
                if(savedItems)metaOrgData = rock.mergeSavedMeta(metaOrgData,savedItems);       
                !force && rock.createCacheDeleteButton(cachedDate);
                rock.startGrid(metaOrgData);
                unlockScreen();
            },
            error: function(r){
               console.log('Error: ',r)
            }
        });
    }
}

/**
 * This finction check if prev and new ApexItems contains the same
 * in case of change it will remove the ApexTestResult related to the userStory
 * @return {[type]} [description]
 */
rock.apexChangedChecker = function(userStoryId){

    //only for userstory active 
    if(userStoryId && rock._prevSelectedApexItems.length){

        //fancy way to compare two arrays
        if(!($copado(rock._prevSelectedApexItems).not(rock._newSelectedApexItems).length === 0 
            && $copado(rock._newSelectedApexItems).not(rock._prevSelectedApexItems).length === 0)){

            //remove the attachment if exists
            var att = dw.u.getAttach(userStoryId ,'ApexTestResult');

            att && att.length && sforce.connection.deleteIds([att[0].Id]);
            var userStory = new sforce.SObject(copadoApp.ns+"User_Story__c");
            userStory[copadoApp.ns+'Apex_Code_Coverage__c'] = 0;
            userStory.Id = userStoryId;
            var result = sforce.connection.update([userStory]);
            if (result[0].getBoolean("success")) {
                console.log('User Story successfully updated.');
            }
            else{
                console.error('User Story could not be updated.');
            }
            alert('Your Apex selections have changed and the previous Apex Test Results are nolonger valid.  Please run the Apex Tests again.');
        }
    }
};

rock.arrayUnique = function(array) {
    var a = array.concat();
    for(var i=0; i<a.length; ++i) {
        for(var j=i+1; j<a.length; ++j) {
            if(a[i] === a[j]){
                a.splice(j--, 1);
            }
        }
    }
    return a;
};


//init(false);   
rock.saveStep = function(){
    var type = copadoApp.mode; 
    //validations
    //check global selected items
    rock.getSelectedObj();
    if(  !rock.selectedNames.length){
        //alert('You must select at least 1 apex class');
        copadoApp.showMessage('ERROR',(type === 'ApexTests') ? 
            'You must select at least 1 apex class': 'You must select at least 1 metadata component', 0);
        return false;
    }
    if(type === 'MetaData'){
        //list of new apex selected items 
        rock._newSelectedApexItems = [];
        
        var hasApexCode = false;
        for(var i=0; i<rock.selectedNames.length; i++){
            var d = rock.selectedNames[i];
            rock.selectedTypes.push(d.t);
            //if selected Name contains an Apex Item
            // NR: if the apexClass/Trigger name contains __ (a package)
            // it must be ignored US-0000213
            console.log('- ', d.t, d.n)
            if($copado.inArray(d.t ,rock._apexItemTypes)>-1 && d.n.indexOf('__')===-1){
                hasApexCode = true;
                //add the class name
                rock._newSelectedApexItems.push(d.n);
            }
        }
        rock.apexChangedChecker(copadoApp.userStoryId);
        var uniqueTypes = rock.arrayUnique(rock.selectedTypes).toString().replace(new RegExp(',', 'g'), ';');

        var userStory = new sforce.SObject(copadoApp.ns+"User_Story__c");
        userStory.Id = copadoApp.userStoryId;
        userStory[copadoApp.ns+'Has_Apex_Code__c'] = hasApexCode;
        userStory[copadoApp.ns+'Metadata_Types_in_Selection__c'] = uniqueTypes;
        result = sforce.connection.update([userStory]);
        if (result[0].getBoolean("success")) {
            console.log('User Story successfully updated.');
        }
        else{
            console.error('User Story could not be updated.');
        }


    }
    rock.remoteSaveMeta(rock.selectedNames, type);
    return false;
};    
rock.remoteSaveMeta = function(items, type){
     dw.u.upsertAttach(copadoApp.userStoryId, type == 'ApexTests'?
                        'ApexTestClasses': 'MetaData', JSON.stringify(items));
     copadoApp.showMessage('CONFIRM','Data added. Close window', 0);
     window.opener.location.reload();
};    

function refreshCache(){
    console.debug('medatadaselector.js refreshCache');
    statusManager.parentId = copadoApp.orgCredential;
    statusManager.successFunction = function(){ init(false); };
    statusManager.startProcess(function() {
        $copado('[id*=pbb_removeCacheContainer]').hide();
        $copado('[id$=removeCache]').hide();
        $copado('#jqxgrid').html(loadingHTML);
        utilsV2.onSuccessCB = function(res){
            var obj = $copado.parseJSON(res);
            if(obj.copadoJobId){
                statusManager.copadoJobId = obj.copadoJobId;
                statusManager.startStatusChecker();
            }
        }
        utilsV2.getRemote(rock.config.metadata_url);
    });
};