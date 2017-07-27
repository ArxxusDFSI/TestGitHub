var snapshotDifferences = snapshotDifferences || {};

//closure
(function(app){

	app = app || {};

	//basic types to filter
	app.filteredTypes = ['ApexClass'];

	/**
	 * shitch to edit mode the grid
	 * @return {[type]} [description]
	 */
	app.edit = function(){
		//toogle edition mode
		$copado('#btnSelectionsSave, #btnSelectionsCancel').show();
		$copado('#btnSelectionsEdit').hide();
		app.editionMode = true;
		app.$grid.jqxGrid('clearfilters');
	};

	/**
	 * cancel the edit mode
	 * @param  {[type]} keep if false restore previous values on grid by reloading the grid
	 * @return {[type]}      [description]
	 */
	app.cancel = function(keep){
		//toogle edition mode
		$copado('#btnSelectionsSave, #btnSelectionsCancel').hide();
		$copado('#btnSelectionsEdit').show();
		app.editionMode = false;

		if(!keep){
	        $copado('#jqxGrid').html(loadingHTML);
			app.init(app.conf, false);
		}
		else{
			app.addSelectedFilter(app.$grid);	
		}
		// NR: if this was the first change on the checked items of the grid, enable saving the changes.
    	app.diffCalculationGridDirty = false;
	};

	/**
	 * get selected items and save in unzipe attach related to git_backup
	 * @return {[type]} [description]
	 */
	app.save = function(){
		coGridHelper.datasource = app.datasource;
		coGridHelper.saveSelected(app.conf.data.id, app.conf.attachmentName, null, true, function(){
			app.cancel(true);
		});
		// NR: if this was the first change on the checked items of the grid, enable saving the changes.
    	app.diffCalculationGridDirty = false;
	};

	app.getSelectedElementList = function() {
		coGridHelper.datasource = app.datasource;
		return coGridHelper.getSelectedObj();
	};



	/**
	 * Refresh cache
	 * @return {[type]} [description]
	 */
	app.refreshCache = function(){
		/*
		$copado('[id$=removeCache]').hide();
	    $copado('[id*=removeCacheContainer]').hide();
	    $copado('#jqxGrid').html(loadingHTML);
		app.init(app.conf, true);
		*/

		// Starts the status manager and then continues with call the webhook
		// NOTE: we are sending a different parentId for the status attachment, that's why startProcess() gets a true parameter at the end
        lockScreen();
		statusManager.startProcess(function() {
			$copado('[id$=removeCache]').hide();
		    $copado('[id*=removeCacheContainer]').hide();
		    $copado('#jqxGrid').html(loadingHTML);
			
		    utilsV2.onSuccessCB = function(res){
		        var obj = $copado.parseJSON(res);
		        if(obj.copadoJobId){
		            statusManager.copadoJobId = obj.copadoJobId;
		            statusManager.successFunction = copadoApp.onCacheRefreshSuccess;
		            statusManager.startStatusChecker();
		        }
		    };
		    // NR: added __ORGID__ replacement, that was missing, while searching for US-0000259
		    var url = app.conf.server.metadataUrl.replace(new RegExp('__ORGID__', 'g'), app.conf.data.orgId);
		    console.log('app.refreshCache NR: url='+url, 'app.conf.server.metadataUrl='+app.conf.server.metadataUrl, 'app.conf.data.orgId='+app.conf.data.orgId);
		    utilsV2.getRemote(url);
		}, true);
	};

	/**
	 * Apply filter to grid. 
	 * @param  {[type]} grid reference [description]
	 * @return {[type]}      [description]
	 */
	app.addSelectedFilter = function($grid){
	    try{
	        console.log('Apply filter to show only selections');
	        var filtergroup2 = new $copado.jqx.filter();
	        var filter2 = filtergroup2.createfilter('booleanfilter', true, 'EQUAL');
	        filtergroup2.addfilter(1, filter2);
	        $grid.jqxGrid('clearfilters');
	        $grid.jqxGrid('addfilter', 's', filtergroup2);
	        $grid.jqxGrid('applyfilters');
	    }
	    catch(e){
	    	console.error('addfilter',e);
	    };
	};

	/**
	 * Create the grid. 
	 * @param  {[type]} data [description]
	 * @return {[type]}      [description]
	 */
	app.startGrid = function (data) {
		console.debug('app.startGrid');
	    try{    
	    	//filter  items
	    	var len = data.length, 
	    	filtered = [];

	    	while(len--){
	    		//filter only by filterTypes
	    		if(app.filteredTypes.indexOf(data[len].t)!= -1){
	    			//initialize selection
	    			data[len].s = data[len].s || false;
	    			filtered.push(data[len]);
	    			app.hasPreviousSelected = app.hasPreviousSelected || data[len].s;
	    		}
	    	}

	        var theme = 'base',
	        source = {
	            localdata: filtered,
	            datafields: [
	            	{ name: 's', type: 'bool' },
	                { name: 't', type: 'string' },
	                { name: 'n', type: 'string' },
	                { name: 'b', type: 'string' },
	                { name: 'd', type: 'string' },
	                { name: 'cb', type: 'string' },
	                { name: 'cd', type: 'string' }
	            ],
	            datatype: 'array',
	            updaterow: function (rowid, rowdata, commit) {
	            	if(!app.diffCalculationGridDirty) {
	            		// NR: if this was the first change on the checked items of the grid, enable saving the changes.
		            	app.diffCalculationGridDirty = true;
		            	snapshotDifferences.edit();
	            	}
	                commit(true);
	                filtered[rowid] = rowdata;
	            }
	        },

	        //adapter wrapper
	        dataAdapter = new $copado.jqx.dataAdapter(source),
	        
	        //keep jquery pointer for performance query
	        $grid = $copado('<div id="grdSelections">');
	        
	        $copado('#jqxGrid').html($grid);
	        //save local source
	        app.datasource = source;
	        
	        $grid.jqxGrid({
	            width: '100%',
	            height: '250px',
	            source: dataAdapter,
	            showfilterrow: true,
	            filterable: true,
	            theme: theme,
	            editable: true, 
	            selectionmode: 'none',
	            enablebrowserselection: true,
	            pageable: true,
	            pagesizeoptions: ['10', '50','100','500','1000','5000'],
	            pagesize: 200,
	            sortable: true,
	            columnsresize: true,
	            localization: localizationobj,
	            columns: [
					{text: copadoLabels.selected, columntype:'checkbox', filtertype:'bool', datafield:'s', width:60},
					{text: copadoLabels.name, filtertype:'textbox', filtercondition:'contains', editable:false, datafield:'n'},
					{text: copadoLabels.type, datafield: 't', filtertype:'checkedlist',editable:false, columntype:'textbox', width:120},
					{text: copadoLabels.LastModifiedById, filtertype:'textbox', editable:false, datafield:'b', width:120},
					{text: copadoLabels.LastModifiedDate, filtertype:'textbox', editable:false, datafield:'d', width:120},
					{text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield:'cb', width:220},
					{text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield:'cd', width:120}
	            ],
	            ready: function(){
		            console.log('ready grid event');
		            app.hasPreviousSelected && app.addSelectedFilter($grid);
		      	}
	        });

			var selectAll = function(sel){
				$grid.jqxGrid('beginupdate');
				var list = $grid.jqxGrid('getrows');
				for(var i in list){
					source.localdata[ list[i].dataindex || i ].s = sel;
				}
				
				// NR: if there was a change on the checked items of the grid, enable saving the changes.
		    	app.diffCalculationGridDirty = true;
            	//snapshotDifferences.edit();
            	$copado('#btnSelectionsSave, #btnSelectionsCancel').show();

				$grid.jqxGrid('endupdate');
				setTimeout(function(){$grid.jqxGrid('updatebounddata','cells');},222);
			},
			
			$unselectAll = $copado('<button id="btnUnselectAll" class="btnSelectUnselectAll">'+copadoLabels.unselect_all+'</button>').
				on('click',function(e){
					e.preventDefault();
					selectAll(false);
				}),
			
			$selectAll = $copado('<button id="btnSelectAll" class="btnSelectUnselectAll">'+copadoLabels.select_all+'</button>').
				on('click', function(e){
					e.preventDefault();
					selectAll(true);
				});
	   
			// NR: clear any previous select/unselect buttons, before re-adding them
			$copado('.btnSelectUnselectAll').remove();
			$copado('#grdSelections .jqx-grid-pager > div')
				.prepend($unselectAll)
				.prepend($selectAll);

			app.$grid = $grid;
	    }
	    catch(e){
	        console.error(e);
	        throw e;
	    }
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
	app.initGrid = function(conf, force){

	    //get metadata
	    var url = conf.server.metadataUrl.replace(new RegExp('__ORGID__', 'g'), conf.data.orgId);
	    console.log('app.initGrid, NR: url='+url, 'conf.server.metadataUrl='+conf.server.metadataUrl, 'conf.data.orgId='+conf.data.orgId);

	    dw.u.getCachedRemote({
	       url: url,
	       name: conf.attachmentName,
	       parentId: conf.data.orgId,
	       force: force,
	       success: function(metaOrgData, cachedDate){

	       		var savedItems = dw.u.getSavedData(conf.data.id, conf.attachmentName);                  
            	if(savedItems)metaOrgData = coGridHelper.mergeSavedData(metaOrgData, savedItems);  

	            app.createCacheDeleteButton(cachedDate);
	            app.startGrid(metaOrgData);
	            unlockScreen();
	       },
	       error: function(r){
	           console.log('Error: ',r)
	       }
	   });
	};

	/**
	 * Initialise application
	 * @param  {[type]} conf  [description]
	 * @param  {[type]} force [description]
	 * @return {[type]}       [description]
	 */
	app.init = function(conf, force){
		app.conf = conf;
	    //do normalize ns to empty string or value
	    app.conf.ns = app.conf.ns || '';

	    //Get the Metadata types and assign to filteredTypes property
	    dw.u.getRemote(app.conf.server.typesUrl, function(res){
	        app.filteredTypes = res;
	        app.initGrid(conf, force);
	    });
	}
}(snapshotDifferences)); //end closure