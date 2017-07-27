//namespace
var rock = rock || {};

rock.stepType = 'MetaData';

rock.createCacheDeleteButton = function(date){
    if(!date){
        $copado('[id*=removeCacheContainer]').hide();
    }
    else{
        var $btn = $copado('[id$=removeCache]');
        $btn.html($btn.html().replace('__DATE__',date)).show();
    }    
};

//config grid
rock.startGrid = function (data) {         
        try{    
            //console.log('start typeof',typeof data)
            var theme = 'base',
            source = {
                localdata: data,
                datafields: [
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
            },

            //adapter wrapper
            dataAdapter = new $copado.jqx.dataAdapter(source),
            
            //keep jquery pointer for performance query
            $grid = $copado('<div>');
            
            $copado("#jqxgrid").html($grid);
            
            rock.datasource = source;
            
            $grid.jqxGrid({
                width: '100%',
                source: dataAdapter,
                showfilterrow: true,
                filterable: true,
                theme: theme,
                editable: true, 
                selectionmode: 'none',
                enablebrowserselection: true,
                pageable: true,
                pagesizeoptions: ['10', '20', '50','100','200','500','1000','2000','5000'],
                pagesize: 200,
                sortable: true,
                columnsresize: true,
                localization: localizationobj,
                columns: [
                  {text: copadoLabels.name, filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'n', width: 200},
                  {text: copadoLabels.type, datafield: 't', filtertype: 'checkedlist',editable:false ,  columntype: 'textbox' },
                  {text: copadoLabels.LastModifiedById, filtertype: 'textbox', editable:false, datafield: 'b', width: 120},
                  {text: copadoLabels.LastModifiedDate, filtertype: 'textbox', editable:false, datafield: 'd', width: 120},
                  {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield: 'cb', width: 220},
                  {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield: 'cd', width: 120}
                ]
            });
        }
        catch(e){
            console.error(e);
            throw e;
        }
};
function refreshCache(){
    statusManager.startProcess(function() {
    	//$copado('[id*=removeCacheContainer]').html('');
    	$copado('[id$=removeCache]').hide();
        $copado('[id*=removeCacheContainer]').hide();
        $copado('#jqxgrid').html(loadingHTML);
    	utilsV2.onSuccessCB = function(res){
    		var obj = $copado.parseJSON(res);
    		if(obj.copadoJobId){
                statusManager.copadoJobId = obj.copadoJobId;
                statusManager.startStatusChecker();
            }
    	}
    	utilsV2.getRemote(metadataselector.metadata_url);
    });
};
function init(force){   
    //start component
    if(force){
    	refreshCache();
    }
    else{
    	lockScreen();
    	dw.u.getCachedRemote({
           url:metadataselector.metadata_url,
           name:'MetaData',
           parentId: metadataselector.orgId,
           force: false,
           success:function(metaOrgData, cachedDate){
                rock.createCacheDeleteButton(cachedDate);
                rock.startGrid(metaOrgData);
                unlockScreen();
           },
           error: function(r){
               console.error('Error: ', r);
               unlockScreen();
           }
       }); 
    }
		
}  