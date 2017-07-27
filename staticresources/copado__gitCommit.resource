var gitCommit = gitCommit || {};
//closure
(function(app){

//basic types to filter
app.filteredTypes = ['ApexClass'];


/**
 * Call heroku to request the commit action
 * @param  {[type]} commitId [description]
 * @return {[type]}          [description]
 */
app.callBackEnd = function(commitId){
    console.log('remote call for ', commitId, app.conf.data.userStoryId, app.conf.data.snapshotId, app.conf.data.repositoryId);
    
    // add both snapshot AND repo. snapshot for regular commits, repo for user story (unconfirmed?)
    statusManager.parentId = app.conf.data.snapshotId;
    statusManager.parentId2 = app.conf.data.repositoryId;
    document.addEventListener('copadoJobFinished1', function (e) {
        if(!e.detail) 
            return;
        console.debug('copadoJobFinished1', e.detail.jobType, e.detail.jobType);
        if( e.detail.jobType.indexOf('apex')>-1 )
            return;
        if( e.detail.jobType.indexOf('retriever')>-1 )
            return;
        location.href='/'+ (app.conf.data.userStoryId || app.conf.data.snapshotId );
    }, false);

    statusManager.startProcess(function() {
        var msg = encodeURIComponent($copado('.js-message').val());
        dw.u.getRemote(app.conf.server.commitUrl.replace('__COMMITID__',commitId).replace('__MSG__',msg),function(res){
            console.info('commit callback >',res);
            statusManager.setStatusComplete();
        }, null, true);
    });
};

/**
 * create a Git_Org_Commit__c record in salesforce
 * @return {[type]} [description]
 */
app.createCommitSObject = function(){

    var commit = new sforce.SObject(app.conf.ns + 'Git_Org_Commit__c');
    commit[app.conf.ns + 'Commit_Message__c'] = $copado('.js-message').val();
    commit[app.conf.ns + 'Org__c'] = app.conf.data.orgId;
    commit[app.conf.ns + 'Git_Backup__c'] = app.conf.data.snapshotId; 
    commit[app.conf.ns + 'Status__c'] = 'Pending';   
           
    var res = sforce.connection.create([commit]);

    if(res && res.length && res[0].success == 'true'){
        return res[0].id;
    }else{
        console.error(res);
        alert('Unexpected error whilst creating the commit record: '+res);
        unlockScreen();
        return false
    }
   
};

/**
 * this method retrieve the selected items
 * then create a record in salesforce, attach the items to be commited 
 * and finally call heroku to procede 
 * @return {[type]} [description]
 */
app.doCommit = function(){

    lockScreen();

    //get selectd
    coGridHelper.datasource = app.datasource;
    
    //validate
    var sel = coGridHelper.getSelectedObj();
    if(!sel.length){
        alert(copadoPageLabels.SELECT_AT_LEAST_ONE_ITEM);
        unlockScreen();
        return;
    }
	if( !(elt_commitMessage.value||'').trim()) {
		alert(copadoPageLabels.ENTER_COMMIT_MESSAGE);
		unlockScreen();
		return;
	}
    //create record
    var commitId = app.createCommitSObject();

    //attach
    commitId && coGridHelper.saveSelected(commitId , 'MetaData', null, true, function(){
        console.debug('... callBackEnd');
        app.callBackEnd(commitId);
    });

    //back
    return false;

};

/**
 * Create the grid. 
 * @param  {[type]} data [description]
 * @return {[type]}      [description]
 */
app.startGrid = function (data) {         
    try{    

        //filter  items
        var len = data.length, 
        filtered = [];

        while(len--){
            //filter only staticresources type
            if(app.filteredTypes.indexOf(data[len].t)!= -1){
                //initialize selection
                data[len].s = data[len].s || false;
				data[len].r = data[len].r || false;
                filtered.push(data[len]);
            }
        }

        var height = utilsV2.getUrlParameter('height');
        height = (height)?height:400;
    
        var pageSize = utilsV2.getUrlParameter('pageSize');
        pageSize = (pageSize)?parseInt(pageSize):200;

        var theme = 'base',
        source = {
            localdata: filtered,
            datafields: [
                { name: 's', type: 'bool' },
				{ name: 'r', type: 'bool' },
                { name: 't', type: 'string' },
                { name: 'n', type: 'string' },
                { name: 'b', type: 'string' },
                { name: 'd', type: 'string' },
                { name: 'cb', type: 'string' },
                { name: 'cd', type: 'string' }
            ],
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                commit(true);
                filtered[rowid] = rowdata;
            }
        },

        //adapter wrapper
        dataAdapter = new $copado.jqx.dataAdapter(source),
        
        //keep jquery pointer for performance query
        $grid = $copado('<div>');
        
        $copado('#jqxGrid').html($grid);
        //save local source
        app.datasource = source;
        
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
            pagesizeoptions: ['10', '50','100','500','1000','5000'],
            pagesize: pageSize,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: [
              {text: copadoLabels.selected, columntype: 'checkbox', filtertype: 'bool', datafield: 's', width: 60 },
              {text: copadoLabels.RETRIEVE_ONLY, columntype: 'checkbox', filtertype: 'bool', datafield: 'r', width: 85 },
              {text: copadoLabels.name, filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'n'},
              {text: copadoLabels.type, datafield: 't', filtertype: 'checkedlist',editable:false ,  columntype: 'textbox', width: 120 },
              {text: copadoLabels.LastModifiedById, filtertype: 'textbox', editable:false, datafield: 'b', width: 120},
              {text: copadoLabels.LastModifiedDate, filtertype: 'textbox', editable:false, datafield: 'd', width: 120},
              {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield: 'cb', width: 220},
              {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield: 'cd', width: 120}
            ],
            ready: function(){
              console.log('ready grid event');
             
            }
        });

        app.$grid = $grid;
        
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
        
        $grid.on('cellvaluechanged', function (event) { 
            if ($grid.jqxGrid('getrowdata', event.args.rowindex).r === true) {
                $grid.jqxGrid('getrowdata', event.args.rowindex).s = true;
                $grid.jqxGrid('refresh');
                $grid.jqxGrid('applyfilters');
            }
        });

    }
    catch(e){
        console.error(e);
        throw e;
    }
};  

/**
 * Refresh cache
 * @return {[type]} [description]
 */
app.refreshCache = function(){
    statusManager.startProcess(function() {
        //$copado('[id*=removeCacheContainer]').html('');
        $copado('[id$=removeCache]').hide();
        $copado('[id*=removeCacheContainer]').hide();
        $copado('#jqxGrid').html(loadingHTML);
        
        //app.init(app.conf, true);
        utilsV2.onSuccessCB = function(res){
            var obj = $copado.parseJSON(res);
            if(obj.copadoJobId){
                statusManager.copadoJobId = obj.copadoJobId;
                statusManager.startStatusChecker();
            }
        }
        utilsV2.getRemote(app.conf.server.metadataUrl);
    });
};

/**
 * update or hide refresh button
 * @param  {[type]} date [description]
 * @return {[type]}      [description]
 */
app.createCacheDeleteButton = function(date){
    if(!date){
        $copado('[id*=removeCacheContainer]').hide();
    }
    else{
        var $btn = $copado('[id$=removeCache]');
        $btn.length && $btn.html($btn.html().replace('__DATE__',date)).show();
    }    
};

/**
 * Retrieve the metadata and start the grid. 
 * @param  {[type]} conf  [description]
 * @param  {[type]} force [description]
 * @return {[type]}       [description]
 */
app.initGrid = function(conf,force){

    var QueryString = function () {
      // This function is anonymous, is executed immediately and 
      // the return value is assigned to QueryString!
      var query_string = {};
      var query = window.location.search.substring(1);
      var vars = query.split("&");
      for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
            // If first entry with this name
        if (typeof query_string[pair[0]] === "undefined") {
          query_string[pair[0]] = decodeURIComponent(pair[1]);
            // If second entry with this name
        } else if (typeof query_string[pair[0]] === "string") {
          var arr = [ query_string[pair[0]],decodeURIComponent(pair[1]) ];
          query_string[pair[0]] = arr;
            // If third or later entry with this name
        } else {
          query_string[pair[0]].push(decodeURIComponent(pair[1]));
        }
      } 
      return query_string;
    }();
    
    // note: can be null
    app.userStoryId = QueryString.userStoryId;

    console.info("initGrid", conf, QueryString.MetadataPreselectionId);
    
    //get metadata and saved statics resources and save
    dw.u.getCachedRemote({
       url: conf.server.metadataUrl,
       name:'MetaData',
       parentId: conf.data.orgId,
       force: force,
       success:function(metaOrgData, cachedDate){
            app.createCacheDeleteButton(cachedDate);
            // if this comes
            if(QueryString.MetadataPreselectionId) {
                savedItems = dw.u.getAttachById(QueryString.MetadataPreselectionId);
                console.debug("gitCommit: MetadataPreselectionId=", QueryString.MetadataPreselectionId, savedItems);
                if(savedItems) {
                    savedItems = Base64.decode(savedItems[0].Body);
                    savedItems = $copado.parseJSON(savedItems);
                    metaOrgData = rock.mergeSavedMeta(metaOrgData, savedItems);
                }else{
                    alert("Could not load selections from other User Story commits.");
                }
            }
            app.startGrid(metaOrgData);
            unlockScreen();
       },
       error: function(r){
           console.log('Error: ',r);
       }
   }); 
};

/**
 * Set the basic configuration, 
 * Get supported types and create the grid. 
 * @param  {[type]} conf  [description]
 * @param  {[type]} force [description]
 * @return {[type]}       [description]
 */
app.init = function(conf, force){
    console.log('init app using:', conf)
    app.conf = conf;

    //do normalize ns to empty string or value
    app.conf.ns = app.conf.ns || '';

    //start component
    lockScreen();
    
    dw.u.getRemote(app.conf.server.typesUrl,function(res){
        app.filteredTypes = res;
        app.initGrid(conf,force);
    });

};


}(gitCommit)); //end closure
