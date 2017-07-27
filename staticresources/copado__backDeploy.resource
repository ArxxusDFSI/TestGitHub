var backDeploy = backDeploy || {};
backDeploy.bindings = backDeploy.binding || {};
backDeploy.polling = backDeploy.polling || {};
backDeploy.data = backDeploy.data || {};
backDeploy.config = backDeploy.config || {};
backDeploy.config.imageUrl = backDeploy.config.imageUrl || {};
backDeploy.branch = backDeploy.branch || {};
backDeploy.floater = backDeploy.floater || {};
backDeploy.diff = backDeploy.diff || {};
backDeploy.labels = backDeploy.labels || {};
backDeploy.error = backDeploy.error || {};

var $copado = $copado || jQuery.noConflict();


backDeploy.config.ns = copadoApp.ns;
backDeploy.config.fileName = 'PROGRESS_STATUS_COPADO';
backDeploy.config.resultName = 'result.json';
backDeploy.config.viewType = 0;
backDeploy.config.contextSize = 5;
backDeploy.config.leftContent = '';
backDeploy.config.rightContent = '';
backDeploy.config.fromBranch = '';
backDeploy.config.toBranch = '';
backDeploy.config.currentUserId = '';
backDeploy.config.canvas = $copado('#boxCanvas').connectSVG();
backDeploy.config.imageUrl.loading = '../../src/statics/img/icons/loading.gif';
backDeploy.config.imageUrl.confirm = '../../src/statics/img/icons/confirm16.png';
backDeploy.config.imageUrl.error = '../../src/statics/img/icons/error16.png';
backDeploy.config.imageUrl.spacer = '../../src/statics/img/icons/s.gif';
backDeploy.config.imageUrl.lookup = '../../src/statics/img/icons/view.png';
backDeploy.config.herokuServer = '';
backDeploy.polling.lastTimeInProgress = null;
backDeploy.polling.jobsInProgress = false;
backDeploy.polling.INTERVAL = 20;

backDeploy.data.flowId = copadoApp.data.flowId;
backDeploy.data.diffIndex = {};
backDeploy.data.mapStepIdEnvironments = [];
backDeploy.data.mapBoxIdToStepId = [];
backDeploy.data.stepIds = [];
backDeploy.data.env2branchMap = [];
backDeploy.data.DiffLinkTypePressed = '';
backDeploy.data.FlowStepPressed = '';
backDeploy.data.results = {};
backDeploy.data.currentGrid = {};
backDeploy.data.permissions = [];
backDeploy.labels.AHEAD = 'ahead';
backDeploy.labels.BEHIND = 'behind';
backDeploy.labels.LOADING = 'Loading';
backDeploy.labels.NAME = 'Name';
backDeploy.labels.BRANCH = 'Branch';
backDeploy.labels.TEST_LEVEL = 'Test Level';
backDeploy.labels.AUTO_MERGE_DEPLOY = 'Auto Merge & Deploy';
backDeploy.labels.YES = 'Yes';
backDeploy.labels.NO = 'No';
backDeploy.labels.NEXT_ENVIRONMENT = 'Next Environment';
backDeploy.labels.MORE_DETAILS = 'More Details';
backDeploy.labels.IN_SYNC = 'In Sync';
backDeploy.labels.VIEW_DEPLOYMENT_STATUS = 'View Deployment Status';
backDeploy.labels.SYNC_BUTTON = 'Sync';
backDeploy.labels.CLICK_TO_VIEW_DETAILS = 'Click to view details';
backDeploy.labels.SYNC_NOT_ALLOWED = 'You are not allowed to perform this action. Please check with your administrator or refresh the page if the permissions were recently changed.';
backDeploy.labels.ARE_YOU_SURE = 'Are you sure?';


backDeploy.polling.startPolling = function(){
    setInterval(function(){
        backDeploy.polling.doPolling();
    }, 5000);
};
backDeploy.polling.doPolling = function(){
    if(backDeploy.polling.jobsInProgress==true){
        var timeDiff = (new Date().getTime() - backDeploy.polling.lastTimeInProgress.getTime())/1000;
        if(timeDiff>backDeploy.polling.INTERVAL){
            backDeploy.polling.lastTimeInProgress = null;
            backDeploy.polling.jobsInProgress = false;
            backDeploy.processAttachments();
        }
    }
};
backDeploy.processAttachments = function(){
    if(!backDeploy.data.flowId || backDeploy.data.stepIds.length==0)return [];
    var inProgressFlow = false;
    // copy the array backDeploy.data.stepIds, since it'll be changed.
    var localList = backDeploy.data.stepIds.slice();
    localList.push(backDeploy.data.flowId);
    var idString = '';
    for(var i=0; i<localList.length; i++){
        idString += ((i!=0)?',':'') + '\''+localList[i]+'\'';
    }
    var q1 = 'Select Id, Name, ParentId From Attachment where ParentId IN ('+idString+') and Name IN (\''+backDeploy.config.resultName+'\',\''+backDeploy.config.fileName+'\') order by Name DESC';
    result =  sforce.connection.query(q1);
    records = result.getArray('records');
    if(records.length>0){
        var atts = [];
        for(var i=0; i<records.length; i++){
            var attachmentId = records[i].Id;
            if(records[i].ParentId==backDeploy.data.flowId && records[i].Name==backDeploy.config.fileName)
                inProgressFlow=true;
            var att = JsRemoting.attachments.getDecodedAttachmentById(attachmentId);
            backDeploy.statusHandler(att);
        }
    }
    (inProgressFlow)?lockScreen():unlockScreen();
    return records;
};
backDeploy.getFlowStepCoordinates = function(){
    var records = JsRemoting.deploymentFlows.getFlowStepCoordinates(backDeploy.config.ns, backDeploy.data.flowId);
    if(records[0][backDeploy.config.ns+'Branch_Management_Coordinates__c']==null){
        __coordinates__ = records[0][backDeploy.config.ns+'Flow_Step_Coordinates__c'];
    }
    else{
        __coordinates__ = records[0][backDeploy.config.ns+'Branch_Management_Coordinates__c'];
    }
    return __coordinates__;
};
backDeploy.getsetCoordinates = function(){
    console.log('Setting coordinates...');
    var __coordinates__ = backDeploy.getFlowStepCoordinates();
    if(__coordinates__ && __coordinates__.length != 0){
        var tmp = backDeploy.splitCoordinates(__coordinates__);
        for(var i=0; i<tmp.length; i++){
            var tmp2 = tmp[i].split('-');
            var box = document.getElementById(tmp2[0]);
            if(box != null){
                box.style.left = tmp2[1];
                box.style.top = tmp2[2];
            }
        }
    }
    backDeploy.drawEnvironmentConnections();
};
backDeploy.initialiseDraggable = function(){
    console.log('Initialising draggable...');
    if(copadoApp.envConnections.length>0){
        $copado('.jsEnvBoxWrapper').draggable({
            drag: function(event, ui){
                backDeploy.config.canvas.redrawLines();
                backDeploy.floater.repositionFloater(ui.helper.attr('id'));
            },
            stop: function( event, ui ) {
                backDeploy.getsetLocations(ui.helper.attr('id'), ui.position.left,ui.position.top); 
            }
        });
    }
    else{
        console.log('copadoApp.envConnections array is empty!');
        $copado('.jsEnvBoxWrapper').draggable(); 
    }
};
backDeploy.getsetLocations = function(id, top, left){
    var envBoxes = $copado('.jsEnvBoxWrapper');
    var new_data = [''];
    for(var i = 0; i<envBoxes.length; i++) {
        new_data[i] = envBoxes[i].getAttribute('id')+'-'+envBoxes[i].style.left+'-'+envBoxes[i].style.top;
        if(envBoxes[i].getAttribute('Id') == id){
            new_data[i] = id+'-'+top+'px-'+left+'px';
        }
    }
    backDeploy.doUpdate(new_data.toString());
};
backDeploy.doUpdate = function(coordinates){
    console.log('Updating Flow...');
    if(coordinates.substring(0, 1)==','){
        coordinates = coordinates.substring(1);
    }
    var records = [];
    var r = new sforce.SObject(backDeploy.config.ns+"Deployment_Flow__c");
    r.Id = backDeploy.data.flowId;
    r[backDeploy.config.ns+'Branch_Management_Coordinates__c'] = coordinates;
    records[0] = r;
    //var result = sforce.connection.update(records);
    var result = JsRemoting.common.update(records);
    __coordinates__ = coordinates;
};
backDeploy.drawSVGlines = function(leftNode, rightNode, destinationNode, envConnection){
    console.log('Drawing SVG lines...');
    color = 'light-blue';
    if(envConnection.ContinuousIntegrationId) {
        if(!backDeploy.showCIEnvironments)
            return;
        color = 'green';
    }
    backDeploy.config.canvas.drawLine({
        left_node: leftNode,
        right_node: rightNode,
        destinationNode: destinationNode,
        horizantal_gap:25,
        error:true,
        style:'solid',
        color:color,
        width:2
    });
};
backDeploy.drawEnvironmentConnections = function(){
    console.log('Drawing environment connections...');
    for (i=0; i<copadoApp.envConnections.length; i++) {
        backDeploy.drawEnvironmentConnection(copadoApp.envConnections[i].fromEnvId, copadoApp.envConnections[i].toEnvId, copadoApp.envConnections[i]);
    }
    backDeploy.floater.initialiseDraggable();
};
backDeploy.cssToInteger = function(ip){
    if(!ip || ip=='auto')return 0;
    if(typeof ip == 'number')return parseInt(ip.toFixed());
    var ip = (ip.length>0)?ip.replace(new RegExp('px', 'g'), ''):ip;
    var output = (ip!='')?parseInt(ip):0;
    return parseInt(output.toFixed());
};
backDeploy.verifyPermission = function(destEnvId){
    var currentUserId = '';
    for(var i=0; i<backDeploy.data.permissions.length; i++){
        if(backDeploy.data.permissions[i][backDeploy.config.ns+'Environment__c']==destEnvId){
            return backDeploy.data.permissions[i][backDeploy.config.ns+'Allow_Deployments__c']=="true";
        }
    }
    return false;
};
backDeploy.callHerokuAction = function(fromEnvId, toEnvId, action){
    var floaterId = 'floater_'+fromEnvId+'-'+toEnvId;
    var flowStepId = backDeploy.data.mapBoxIdToStepId[fromEnvId+'-'+toEnvId];
    var url = backDeploy.config.herokuServer+'/json/v1/gitBranchSync/'+backDeploy.data.flowId+'/'+flowStepId+'/'+action+copadoApp.urlParameters;
    console.log('Calling Heroku', url);
    utilsV2.method = 'POST';
    utilsV2.onFailureCB = function(res){
        alert(res);
    };
    utilsV2.onSuccessCB = function(){ 
        if(action=='merge'){
            $copado('#'+floaterId+'_actionButtonPushUp').attr('value','Loading...');   
        }
        else if(action=='pull'){
            $copado('#'+floaterId+'_actionButtonPullDown').attr('value','Loading...');  
        }
    };
    var isSure = confirm(backDeploy.labels.ARE_YOU_SURE);
    if(isSure==false)return;

    var syncAllowed = backDeploy.verifyPermission(((action=='pull')?fromEnvId:toEnvId));
    if(syncAllowed==true){
        utilsV2.getRemote(url);
    }
    else{
        alert(backDeploy.labels.SYNC_NOT_ALLOWED);
    }
};
backDeploy.recalculate = function(el){
    el.value = 'Recalculating';
    var url = backDeploy.config.herokuServer+'/json/v1/branchStatuses/'+backDeploy.data.flowId+copadoApp.urlParameters;
    console.log('Calling Heroku', url);
    utilsV2.method = 'GET';
    utilsV2.onSuccessCB = function(){
        el.value = 'Recalculate';
    };
    utilsV2.onFailureCB = function(res){
        el.value = 'Recalculate';
        alert(res);
    };
    utilsV2.getRemote(url);
};
backDeploy.recalculateSingleBranch = function(el, branchName){
    el.value = 'Recalculating';
    var url = backDeploy.config.herokuServer+'/json/v1/branchStatuses/'+backDeploy.data.flowId+copadoApp.urlParameters+'&branch='+encodeURIComponent(branchName);
    console.log('Calling Heroku', url);
    utilsV2.method = 'GET';
    utilsV2.onSuccessCB = function(){
        el.value = '\u21ba';
    };
    utilsV2.onFailureCB = function(res){
        el.value = '\u21ba';
        alert(res);
    };
    utilsV2.getRemote(url);
};
backDeploy.bindings.bindMergeErrorShowDiff = function(){
    $copado('#div-m-eFileList').off('click');
    $copado('#div-m-eFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);//, {type:'merge'}
};
backDeploy.bindings.bindPullErrorShowDiff = function(){
    $copado('#div-p-eFileList').off('click');
    $copado('#div-p-eFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);//, {type:'merge'}
};
backDeploy.bindings.bindMergeMergedShowDiff = function(){
    $copado('#div-m-mFileList').off('click');
    $copado('#div-m-mFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);//, {type:'merge'}
};
backDeploy.bindings.bindPullMergedShowDiff = function(){
    $copado('#div-p-mFileList').off('click');
    $copado('#div-p-mFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);//, {type:'merge'}
};
backDeploy.bindings.bindbehindShowDiff = function(){
    $copado('#behindFileList').off('click');
    $copado('#behindFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);
};
backDeploy.bindings.bindaheadShowDiff = function(){
    $copado('#aheadFileList').off('click');
    $copado('#aheadFileList').on('click', '.js-show-diff', backDeploy.diff.showDiff);
};
backDeploy.bindings.bindActions = function(){
    backDeploy.bindings.bindbehindShowDiff();
    backDeploy.bindings.bindaheadShowDiff();
    backDeploy.bindings.bindPullErrorShowDiff();
    backDeploy.bindings.bindMergeErrorShowDiff();
};
backDeploy.setIframeLocker = function(url){
    $copado('#copadoIframe').attr('data-src', url);
};
backDeploy.floater.repositionFloater = function(boxId){
    var $box = $copado('#'+boxId);
    var array = $box.attr('data-floaters');
    // NR: CI boxes have no floaters
    if(!array || !array.length)
        return;
    array = array.split(',');
    for(var i=0; i<array.length; i++){
        var envIds = array[i].replace(new RegExp('floater_', 'g'),'').split('-');
        backDeploy.floater.drawFloaterDiv(envIds[0], envIds[1]);
    }
};
backDeploy.floater.openDeploymentStatus = function(el){
    var deploymentId = $copado(el).attr('data-deploymentId');
    backDeploy.setIframeLocker('/apex/deploymentStatus?id='+deploymentId);
    openIframeBox();
};
backDeploy.floater.resetIcons = function(boxId){
    $copado('#'+boxId+'_mergeValidation > img').prop('src',backDeploy.config.imageUrl.spacer);
    $copado('#'+boxId+'_pullValidation > img').prop('src',backDeploy.config.imageUrl.spacer);
    $copado('#'+boxId+'_mergeError > img').prop('src',backDeploy.config.imageUrl.spacer);
    $copado('#'+boxId+'_pullError > img').prop('src',backDeploy.config.imageUrl.spacer);
};
backDeploy.floater.drawFloaterDiv = function(fromEnvId, toEnvId){
    var floaterId = 'floater_'+fromEnvId+'-'+toEnvId;

    var html = "<div id='"+floaterId+"' data-fromEnvId='"+fromEnvId+"' data-toEnvId='"+toEnvId+"' class='backDeploy statusBox js-draggable' style='position:absolute;'>"+
            "<div id='"+floaterId+"_content' class='backDeploy content' style='display:block;'>"+
                "<div id='"+floaterId+"_NoSync' class='backDeploy' style='display:none;'>"+
                    "<table>"+
                        "<tr>"+
                            "<td></td>"+
                            "<td><span id='"+floaterId+"_sourceBranch'> </span></td>"+
                            "<td><span id='"+floaterId+"_destinationBranch'> </span></td>"+
                        "</tr>"+
                        "<tr>"+
                            "<td></td>"+
                            "<td><span id='"+floaterId+"_commitsAhead'> </span></td>"+
                            "<td><span id='"+floaterId+"_commitsBehind'> </span></td>"+
                        "</tr>"+
                        "<tr>"+
                            "<td>Validation</td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_mergeValidation' onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"merge\");'><img src='"+backDeploy.config.imageUrl.spacer+"' /></a></td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_pullValidation' onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"pull\");'><img src='"+backDeploy.config.imageUrl.spacer+"' /></a></td>"+
                        "</tr>"+
                        "<tr>"+
                            "<td>Differences</td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' class='js-showList' id='"+floaterId+"_mergeDiff' onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"merge\");'><img src='"+backDeploy.config.imageUrl.lookup+"' /></a></td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' class='js-showList' id='"+floaterId+"_pullDiff' onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"pull\");'><img src='"+backDeploy.config.imageUrl.lookup+"' /></a></td>"+
                        "</tr>"+
                        "<tr>"+
                            "<td>Errors</td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_mergeError'onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"merge\");'><img src='"+backDeploy.config.imageUrl.lookup+"' /></a></td>"+
                            "<td class='tdIcons'><a alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_pullError' onclick='backDeploy.showGridList(\""+fromEnvId+"\",\""+toEnvId+"\", \"pull\");'><img src='"+backDeploy.config.imageUrl.lookup+"' /></a></td>"+
                        "</tr>"+
                        "<tr>"+
                            "<td></td>"+
                            "<td class='tdIcons'><input alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_actionButtonPushUp' style='display:none;' class='btn actionButton' type='button' value='"+backDeploy.labels.SYNC_BUTTON+"' onclick='backDeploy.callHerokuAction(\""+fromEnvId+"\",\""+toEnvId+"\",\"merge\");'/></td>"+
                            "<td class='tdIcons'><input alt='"+backDeploy.labels.CLICK_TO_VIEW_DETAILS+"' id='"+floaterId+"_actionButtonPullDown' style='display:none;' class='btn actionButton' type='button' value='"+backDeploy.labels.SYNC_BUTTON+"' onclick='backDeploy.callHerokuAction(\""+fromEnvId+"\",\""+toEnvId+"\",\"pull\");'/></td>"+
                        "</tr>"+
                    "</table>"+
                "</div>"+
                "<div id='"+floaterId+"_DeploymentComplete' class='backDeploy inSync' style='display:none;'>"+
                    "<img id='"+floaterId+"-DeploymentComplete-img' src='"+backDeploy.config.imageUrl.confirm+"' title='Deployment Completed' />"+
                    "<div id='"+floaterId+"_DeploymentCompleteMessage'>Deployment Completed</div>"+
                "</div>"+
                "<div id='"+floaterId+"_InSync' class='backDeploy inSync' style='display:none;'>"+
                    "<img id='"+floaterId+"-inSync-img' src='"+backDeploy.config.imageUrl.confirm+"' title='"+backDeploy.labels.IN_SYNC+"' />"+
                    "<div id='"+floaterId+"_inSyncMessage'>"+backDeploy.labels.IN_SYNC+"</div>"+
                "</div>"+
                "<div id='"+floaterId+"_InProgress' class='backDeploy inProgress' style='display:none;'>"+
                    "<img id='"+floaterId+"-status-img' src='"+backDeploy.config.imageUrl.loading+"' title='"+backDeploy.labels.LOADING+"' />"+
                    "<div id='"+floaterId+"_statusMessage'> </div>"+
                    "<input type='button' id='"+floaterId+"_deploymentStatus' style='display:none;' class='btn' onclick='backDeploy.floater.openDeploymentStatus(this)' data-deploymentid='' value='"+backDeploy.labels.VIEW_DEPLOYMENT_STATUS+"' />"+
                "</div>"+
            "</div>"+
        "</div>";
    $copado('#'+floaterId).attr('data-flowStepId', backDeploy.data.mapBoxIdToStepId['"'+fromEnvId+'-'+toEnvId+'"']);
    if($copado('#'+floaterId).length==0)$copado("#boxCanvas").append(html);
    var $fromEnvBox = $copado('#wrapper_'+fromEnvId);
    var $toEnvBox = $copado('#wrapper_'+toEnvId);
    var $floaterBox = $copado('#'+floaterId);
    
    var fromFloaters = $fromEnvBox.attr('data-floaters').split(',');
    var toFloaters = $toEnvBox.attr('data-floaters').split(',');
    if(fromFloaters && fromFloaters.length==1 && fromFloaters[0]=='')fromFloaters.splice(0,1);
    if(toFloaters && toFloaters.length==1 && toFloaters[0]=='')toFloaters.splice(0,1);

    if(fromFloaters.indexOf(floaterId)==-1)fromFloaters.push(floaterId);
    if(toFloaters.indexOf(floaterId)==-1)toFloaters.push(floaterId);
    $fromEnvBox.attr('data-floaters', fromFloaters);
    $toEnvBox.attr('data-floaters', toFloaters);

    //calculate middle of line.
    var middle_line_height = backDeploy.floater.calculateMiddleHeight($fromEnvBox, $toEnvBox);
    var middle_line_width = backDeploy.floater.calculateMiddleWidth($fromEnvBox, $toEnvBox);
    var floater_offset_height = 0;
    var floater_offset_width = $floaterBox.width()/2;

    var final_floater_top = (middle_line_height-floater_offset_height)+'px';
    var final_floater_left = (middle_line_width-floater_offset_width)+'px';
    
    //position floater
    $floaterBox.css('top', final_floater_top);
    $floaterBox.css('left', final_floater_left);
};
backDeploy.floater.calculateMiddleHeight = function($a, $b){
    var ah = backDeploy.cssToInteger($a.css('top'));
    var bh = backDeploy.cssToInteger($b.css('top'));
    var middle = ((bh>ah)?bh:ah) - ((bh>ah)?bh-ah:ah-bh)/2;
    return middle;
};
backDeploy.floater.calculateMiddleWidth = function($a, $b){
    var me = backDeploy;
    var spacer = 25; //arrow spacer
    var aw = me.cssToInteger($a.css('left'));
    var bw = me.cssToInteger($b.css('left'));
    var l = (bw>aw)?me.cssToInteger(aw):me.cssToInteger(bw);
    var r = (bw<aw)?me.cssToInteger(aw):me.cssToInteger(bw);
    var _R = r-spacer;
    var _lw = (bw>aw)?$a.width():$b.width();
    var _lwt = me.cssToInteger(_lw)+spacer;
    var _l = parseInt(l);
    var _L = (_l + _lwt);
    var middle = ((_R-_L)/2+_L);
    return middle;
};
backDeploy.floater.showInProgress = function(boxId, type){
    $copado('#'+boxId+'_InProgress').show();
    $copado('#'+boxId+'_NoSync').hide();
    $copado('#'+boxId+'_InSync').hide();
    $copado('#'+boxId+'_DeploymentComplete').hide();
    if(type=='GitBranchStatus'){
        backDeploy.data.results = [];
        backDeploy.floater.resetIcons(boxId);
    }
};
backDeploy.floater.hideInProgress = function(boxId){
    $copado('#'+boxId+'_InProgress').hide();
    backDeploy.floater.setStatusMessage(boxId, '');
};
backDeploy.floater.setDiffLinkVisibility = function(boxId, obj){
    $copado('#'+boxId+'_pullDiff').hide();
    $copado('#'+boxId+'_mergeDiff').hide();
    if(obj.filesMergedBehind && obj.filesMergedBehind.length>0)$copado('#'+boxId+'_pullDiff').show();
    if(obj.filesMergedAhead && obj.filesMergedAhead.length>0)$copado('#'+boxId+'_mergeDiff').show();
};
backDeploy.floater.setDeploymentLinkVisibility = function(boxId, obj){
    $copado('#'+boxId+'_deploymentStatus').hide();
    if(obj.deploymentId){
        $copado('#'+boxId+'_deploymentStatus').attr('data-deploymentid', obj.deploymentId);
        $copado('#'+boxId+'_deploymentStatus').show();
    }
};
backDeploy.floater.setButtonsVisibility = function(boxId, obj){
    if(!obj || !boxId)return null;

    $copado('#'+boxId+'_actionButtonPushUp').hide();
    $copado('#'+boxId+'_actionButtonPullDown').hide();

    if(obj.mergeValidationSuccess){
        $copado('#'+boxId+'_actionButtonPushUp').show();
    }
    if(obj.pullValidationSuccess){
        $copado('#'+boxId+'_actionButtonPullDown').show();
    }
    return true;
};
backDeploy.floater.setStatusMessage = function(boxId, value){
    $copado('#'+boxId+'_statusMessage').text(value);
};
backDeploy.floater.setValidationLinkVisibility = function(boxId, obj){
    $copado('#'+boxId+'_pullValidation').hide();
    $copado('#'+boxId+'_mergeValidation').hide();
    $copado('#'+boxId+'_pullValidation > img').attr('src', backDeploy.config.imageUrl.spacer);
    $copado('#'+boxId+'_mergeValidation > img').attr('src', backDeploy.config.imageUrl.spacer);

    if(obj.pullValidationSuccess==false){
        $copado('#'+boxId+'_pullValidation').show();
        $copado('#'+boxId+'_pullValidation > img').attr('src', backDeploy.config.imageUrl.error);
    }
    else if(obj.pullValidationSuccess==true){
        $copado('#'+boxId+'_pullValidation').show();
        $copado('#'+boxId+'_pullValidation > img').attr('src', backDeploy.config.imageUrl.confirm);
    }
    if(obj.mergeValidationSuccess==false){
        $copado('#'+boxId+'_mergeValidation').show();
        $copado('#'+boxId+'_mergeValidation > img').attr('src', backDeploy.config.imageUrl.error);
    }
    else if(obj.mergeValidationSuccess==true){
        $copado('#'+boxId+'_mergeValidation').show();
        $copado('#'+boxId+'_mergeValidation > img').attr('src', backDeploy.config.imageUrl.confirm);
    }
};
backDeploy.floater.showInSyncMessage = function(boxId){
    $copado('#'+boxId+'_NoSync').hide();
    $copado('#'+boxId+'_InSync').show();
    $copado('#'+boxId+'_InProgress').hide();
    $copado('#'+boxId+'_DeploymentComplete').hide();
};
backDeploy.floater.hideInSyncMessage = function(boxId){
    $copado('#'+boxId+'_InSync').hide();
    $copado('#'+boxId+'_NoSync').show();
    //$copado('#'+boxId+'_InProgress').hide();
};
/**/
backDeploy.floater.setFloaterContent = function(boxId, obj, parentType){
    console.debug("setFloaterContent", boxId, obj, parentType);
    //parentType = flow | step
    if(!obj) { $copado('#'+boxId+'_content').append('<div class="backDeploy">No results to display</p>'); return; }
    if(!backDeploy.data.mapStepIdEnvironments) { $copado('#'+boxId+'_content').append('<div class="backDeploy">No flow step to display</p>'); return; }

    //Set branch names
    $copado('#'+boxId+'_sourceBranch').html(obj.sourceBranch);
    $copado('#'+boxId+'_destinationBranch').html(obj.destinationBranch); 


    if(parentType=='flow'){
        //Set in Sync message
        if(obj.commitsBehind==0 && obj.commitsAhead==0){
            backDeploy.floater.showInSyncMessage(boxId);
            $copado('#'+boxId+'_NoSync').hide();
            $copado('#'+boxId+'_InProgress').hide(); 
        }
        else{
            backDeploy.floater.hideInSyncMessage(boxId);
            (obj.pullConflictedFiles && obj.pullConflictedFiles.length>0)?$copado('#'+boxId+'_pullError').show():$copado('#'+boxId+'_pullError').hide();
            (obj.mergeConflictedFiles && obj.mergeConflictedFiles.length>0)?$copado('#'+boxId+'_mergeError').show():$copado('#'+boxId+'_mergeError').hide();
        }
        backDeploy.floater.setDiffLinkVisibility(boxId, obj);
        $copado('#'+boxId+'_commitsBehind').html(obj.commitsBehind+' '+backDeploy.labels.BEHIND);
        $copado('#'+boxId+'_commitsAhead').html(obj.commitsAhead+' '+backDeploy.labels.AHEAD);
   
    }
    else if(parentType=='step'){
        if(obj.isDeployment==true){
            $copado('#'+boxId+'_DeploymentComplete').show();
            $copado('#'+boxId+'_NoSync').hide();
            $copado('#'+boxId+'_InSync').hide();
            $copado('#'+boxId+'_InProgress').hide();
        }
        ((obj.pullValidationErrors && obj.pullValidationErrors.length>0)||(obj.pullDeploymentErrors && obj.pullDeploymentErrors.length>0))?$copado('#'+boxId+'_pullError').show():$copado('#'+boxId+'_pullError').hide();
        ((obj.mergeValidationErrors && obj.mergeValidationErrors.length>0)||(obj.mergeDeploymentErrors && obj.mergeDeploymentErrors.length>0))?$copado('#'+boxId+'_mergeError').show():$copado('#'+boxId+'_mergeError').hide();
        
        //Set Validation link visibility
        backDeploy.floater.setValidationLinkVisibility(boxId, obj);
        
        //Set buttons to enabled/disabled
        backDeploy.floater.setButtonsVisibility(boxId, obj);
    }
};
backDeploy.floater.hideActionButtons = function(){
    for(var i=0; i<backDeploy.data.stepIds.length; i++){
        var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[backDeploy.data.stepIds[i]];
        $copado('#'+boxId+'_actionButtonPullDown').hide();
        $copado('#'+boxId+'_actionButtonPushUp').hide();
    }
};
backDeploy.floater.hideDiffLinks = function(){
    var boxId = 'floater_'+backDeploy.data.stepIds[i];
    for(var i=0; i<backDeploy.data.stepIds.length; i++){
        var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[backDeploy.data.stepIds[i]];
        $copado('#'+boxId+'_pullDiff').hide();
        $copado('#'+boxId+'_mergeDiff').hide();
    }
};
backDeploy.floater.getFloaterObjectFromArray = function(stepId, array){
    for(var i=0; i<array.length;i++){
        if(array[i].id==stepId)return array[i];
    }
    return null;
};
backDeploy.floater.initialiseDraggable = function(){
    $copado('.js-draggable').draggable();
};

backDeploy.displayLogs = function(dbug) {
    console.debug('Finished?', dbug);
    var elt = document.getElementById('syncLogs');
    elt.innerText = '';
    // NR: retrieve the "Logs" notes, and show it.
    var q = "SELECT Body FROM Note WHERE Title='Logs' AND ParentId='"+backDeploy.data.flowId+"' ORDER BY LastModifiedDate DESC limit 1",
    result =  sforce.connection.query(q),
    records = result.getArray("records");
    for(var ix=0; ix<records.length ; ix++) {
        elt.innerText = (''+records[ix].Body).replace(/(:[0-9]+)\.[0-9]+/g, '$1').replace(/\n/g,'\n\n');
    }
};

backDeploy.statusHandler = function(attachment){
    if(!attachment || attachment.Body.length==0)return false;

    var obj = JSON.parse(attachment.Body);
    console.debug('backDeploy.statusHandler obj=', obj, attachment.Name, attachment.ParentId);
    
    if(attachment.Name==backDeploy.config.resultName){
        backDeploy.data.results[attachment.ParentId] = obj;

        if(attachment.ParentId==backDeploy.data.flowId){
            for(var i=0; i<backDeploy.data.stepIds.length; i++){
                var stepId = backDeploy.data.stepIds[i];
                if(stepId) {
                    var stepObject = backDeploy.floater.getFloaterObjectFromArray(stepId, obj);
                    var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[stepId];
                    console.assert(backDeploy.data.mapStepIdEnvironments[stepId], ["error: an env is not mapped", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
                    backDeploy.floater.hideInProgress(boxId);
                    backDeploy.floater.setFloaterContent(boxId, stepObject, 'flow');
                }
            }
            unlockScreen(); 
        }
        else{
            var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[attachment.ParentId];
            console.assert(attachment.ParentId && backDeploy.data.mapStepIdEnvironments[attachment.ParentId], ["error: an attachment parentId is not mapped", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
            console.debug("...", boxId, obj, attachment.ParentId)
            backDeploy.floater.setFloaterContent(boxId, obj, 'step');
        }
    }
    else{
        //Progress Status Copado
        if(attachment.ParentId==backDeploy.data.flowId){
            if(obj.isFinished==false){
                backDeploy.polling.jobsInProgress = true;
                backDeploy.polling.lastTimeInProgress = new Date();
                lockScreen();
                setLockScreenMessage(obj.status);
                backDeploy.floater.hideDiffLinks();
                backDeploy.floater.hideActionButtons();
                for(var i=0; i<backDeploy.data.stepIds.length; i++){
                    var stepId = backDeploy.data.stepIds[i];
                    if(stepId) {
                        var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[stepId];
                        console.assert(backDeploy.data.mapStepIdEnvironments[stepId], ["error: an env is not mapped (1)", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
                        backDeploy.floater.hideInSyncMessage(boxId);
                        backDeploy.floater.showInProgress(boxId, obj.type);
                    }
                }
            }
            else{
                var att = JsRemoting.attachments.getDecodedAttachment(backDeploy.data.flowId, backDeploy.config.resultName);
                var go = JSON.parse(att.Body);
                backDeploy.data.results[backDeploy.data.flowId] = go;
                for(var i=0; i<go.length; i++){
                    var stepId = go[i].id;
                    if(stepId) {
                        var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[stepId];
                        console.assert(backDeploy.data.mapStepIdEnvironments[stepId], ["error: an env is not mapped (2)", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
                        backDeploy.floater.hideInProgress(boxId);
                        //backDeploy.floater.setStatusMessage(boxId, 'Calculating...');
                        backDeploy.floater.setFloaterContent(boxId, go[i], 'flow');
                    }
                }
                unlockScreen();
            }
        }
        else{
            if(obj.isFinished==false){
                backDeploy.polling.jobsInProgress = true;
                backDeploy.polling.lastTimeInProgress = new Date();
                if(attachment.ParentId) {
                    var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[attachment.ParentId];
                    console.assert(stepId && backDeploy.data.mapStepIdEnvironments[attachment.ParentId], ["error: an env is not mapped (3)", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
                    backDeploy.floater.showInProgress(boxId, obj.type);
                    backDeploy.floater.hideInSyncMessage(boxId);
                    backDeploy.floater.setStatusMessage(boxId, obj.status);
                }
            }
            else{
                var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[attachment.ParentId];
                console.assert(stepId && backDeploy.data.mapStepIdEnvironments[attachment.ParentId], ["error: an env is not mapped (4)", stepId, backDeploy.data.mapStepIdEnvironments[stepId]]);
                backDeploy.floater.setFloaterContent(boxId, obj, 'step');

                setTimeout(function() {
                    var result = JsRemoting.attachments.getDecodedAttachment(attachment.ParentId, backDeploy.config.resultName);
                    if(result){
                        var localObject = JSON.parse(result.Body);
                        backDeploy.data.results[attachment.ParentId] = localObject;
                        backDeploy.floater.hideInProgress(boxId);
                        backDeploy.floater.setFloaterContent(boxId, localObject, 'step');
                        backDeploy.displayLogs(3);
                        unlockScreen();
                    }
                }, 1000);
            }
        }
        backDeploy.displayLogs(1);
    }
};


backDeploy.drawEnvironmentConnection = function(fromEnvId, toEnvId, envConnection){
    console.log('Draw connection: '+fromEnvId+' '+toEnvId);
    backDeploy.setDestinatonEnvName(fromEnvId, toEnvId);
    var fromEnvBox = '#wrapper_'+fromEnvId;
    var toEnvBox = '#wrapper_'+toEnvId;
    backDeploy.drawSVGlines(fromEnvBox, toEnvBox, toEnvBox, envConnection);
    if(!envConnection.ContinuousIntegrationId)
        backDeploy.floater.drawFloaterDiv(fromEnvId, toEnvId);
};
backDeploy.addDetailHover = function(env){
    var content = '';
    content = '<b>'+backDeploy.labels.NAME+':</b> '+env.envName+'<br />'+
        '<b>'+backDeploy.labels.BRANCH+':</b> '+((env.branch)?env.branch:'')+'<br />'+
        '<b>'+backDeploy.labels.TEST_LEVEL+':</b> '+((env.testLevel)?env.testLevel:'')+'<br />'+
        '<b>'+backDeploy.labels.AUTO_MERGE_DEPLOY+':</b> '+((env.autoMergeDeploy && env.autoMergeDeploy=='true')?backDeploy.labels.YES:backDeploy.labels.NO)+'<br />'+
        '<b>Flow Step Id:</b> '+env.flowStepId;
    var elt = $copado('#viewInfo_'+env.envId);
    if(elt && elt.length)
        elt.jqxTooltip({ content:content, position:'mouse', name:env.envName+'Details'});
};
backDeploy.drawEnvironmentBoxes = function(){
    console.log('Drawing Environment Boxes...');
    for(var i=0; i<copadoApp.environments.length; i++) { 
        backDeploy.addEnvBox(null, copadoApp.environments[i].envName, copadoApp.environments[i].envId, copadoApp.environments[i].flowStepId, copadoApp.environments[i].branch, copadoApp.environments[i]);
        backDeploy.addDetailHover(copadoApp.environments[i]);
    }
    backDeploy.getsetCoordinates();
    backDeploy.initialiseDraggable();
};
backDeploy.setDestinatonEnvName = function(fromEnvId, toEnvId){
    console.log('Setting Destination Environment Name...');
    var toEnvName = $copado('#'+toEnvId+'_title').text();
    $copado('#nextDestEnvBody_'+fromEnvId).text(toEnvName);
    if(toEnvName.length>0)$copado('#detailModeBody_'+fromEnvId).show();
    $copado('#box_'+fromEnvId+' #hdn_DestEnvName').val(toEnvName);
    $copado('#box_'+fromEnvId+' #hdn_DestEnvId').val(toEnvId);
};
backDeploy.setEnvironmentValues = function(envId, destEnvName, destEnvId, flowStepId){
    console.log('Setting Environment values...');
    backDeploy.setDestinatonEnvName(envId, destEnvId);
    $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
    //$copado('#detailMode_'+envId).show();
};
backDeploy.buildEnvBox = function(envName, envId, style, branch){
    console.debug('backDeploy.buildEnvBox', envName, branch);
    style = (style=='' || style==null || typeof style == 'undefined')?'':style;
    branch = (typeof branch=='undefined'||branch==null)?'':branch;
    // NR: this determines if this EnvBox is the dest org of a CI job.
    // if so, it needs to be rendered differently.
    var step = backDeploy.data.flowStepMapByToEnvId? backDeploy.data.flowStepMapByToEnvId[envId] : null;
    var s;
    if(step && step.ContinuousIntegrationId) {
        s = "<div style='"+style+"'class='jsEnvBoxWrapper CIStepWrapper' id='wrapper_"+envId+"' data-flowStepId=''>"+
                "<div id='box_"+envId+"' class='envBox CIStep'>"+
                    "<h3 class='clearfix'>"+
                        "<a onclick='javascript:return false;' class='title' target='_blank'>"+envName+"</a>"+
                    "</h3>"+
                    "<div class='envContent'>"+
                        "<ol class='rowItems'>"+
                            "<li>"+
                                "<div id='detailMode_"+envId+"' style='display:block;'>"+
                                    "<span id='branchHeader_"+envId+"' style='font-weight:bolder'>CI Status: </span><span>"+step.ContinuousIntegrationStatus+"</span><br />"+
                                    "<hr/>"+
                                    "<span onclick=\"window.open('/"+step.ContinuousIntegrationId+"')\">View CI</span>"+
                                "</div>"+
                            "</li>"+
                        "</ol>"+
                    "</div>"+
                "</div>"+
            "</div>";
        console.warn(s);
    }else{
        s = "<div style='"+style+"'class='jsEnvBoxWrapper' id='wrapper_"+envId+"' data-flowStepId='' data-floaters=''>"+
                "<div id='box_"+envId+"' class='envBox'>"+
                    "<h3 class='clearfix'>"+
                        "<a onclick='javascript:return false;' id='"+envId+"_title' class='title' target='_blank'>"+envName+"</a>"+
                    "</h3>"+
                    "<div class='envContent'>"+
                        "<ol class='rowItems'>"+
                            "<li>"+
                                "<div id='detailMode_"+envId+"' style='display:block;'>"+
                                    "<div id='detailModeBody_"+envId+"' style='display:none;'>"+
                                        "<span id='nextDestEnvHeader_"+envId+"' style='font-weight:bolder'>"+backDeploy.labels.NEXT_ENVIRONMENT+": </span><span id='nextDestEnvBody_"+envId+"'></span><hr />"+
                                    "</div>"+
                                    "<span id='branchHeader_"+envId+"' style='font-weight:bolder'>"+backDeploy.labels.BRANCH+": </span><span id='branchBody_"+envId+"'>"+branch+"</span><br />"+
                                    "<span id='viewInfo_"+envId+"'>"+backDeploy.labels.MORE_DETAILS+"</span>"+
                                    "<br/><div style=\"text-align: right\">"+
                                    '<input type="button" class="btn" onclick="backDeploy.recalculateSingleBranch(this,\''+branch.replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0')+'\');" value="&#x21ba;" title="Recalculate this branch" />'+
                                "</div></div>"+
                            "</li>"+
                        "</ol>"+
                    "</div>"+
                    "<input type='hidden' id='hdn_DestEnvId' value='' />"+
                    "<input type='hidden' id='hdn_DestEnvName' value='' />"+
                    "<input type='hidden' id='hdn_Branch' value='"+branch+"' />"+
                "</div>"+
            "</div>";
    }
    return s;
};
backDeploy.environmentboxOnCanvas = function(envId){
    if($copado('#box_'+envId).length)return true;
    return false;
};
backDeploy.addEnvBox = function(fromEnvId, envName, envId, flowStepId, branch, environment){
    var style = '';
    if(typeof fromEnvId != 'undefined' && fromEnvId!=null){
        $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
        var top = $copado('#wrapper_'+fromEnvId).css('top');
        var left = $copado('#wrapper_'+fromEnvId).css('left');
        var width = $copado('#wrapper_'+fromEnvId).width();
        style = 'top:'+top+'; left:'+ (parseInt(left)+width+50)+'px;';
    }
    if(backDeploy.environmentboxOnCanvas(envId)==false){
        $copado("#boxCanvas").append(backDeploy.buildEnvBox(envName, envId, style, branch, environment));
        $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
        if($copado('#box_'+envId+' #hdn_DestEnvName').val() != ''){
            $copado('#nextDestEnvBody_'+envId).val($copado('#box_'+envId+' #hdn_DestEnvName').val());
            $copado('#detailModeBody_'+envId).show();
        }
    }
};
backDeploy.splitCoordinates = function(s){
    var data = s.split(',');
    return data;
};

backDeploy.queryCIRecords = function(environments){
    var i;
    console.log('queryCIRecords...');

    backDeploy.data.env2CIMap = {};

    // get a hashmap of which branch goes to which list of envs.
    var envConnectionMapByBrach = {}, allEnvIds={};

    //environments.push({envName: map[v].envName, envId:map[v].envId, flowStepId:map[v].flowStepId, branch:branch, testLevel:map[v].testLevel, autoMergeDeploy:map[v].autoMergeDeploy});
    for(i=0; i<environments.length; i++){
        envConnectionMapByBrach[environments[i].branch] = envConnectionMapByBrach[environments[i].branch] || [];
        envConnectionMapByBrach[environments[i].branch].push(environments[i]);
        allEnvIds[environments[i].envId]=environments[i];
    }

    // now request all the CI records associated to each envConnection.toEnvId
    // we will filter the git branches later.
    var records = JsRemoting.deploymentFlows.getCIRecords(backDeploy.config.ns, copadoApp.data.repositoryId);

    var newEnvConnections = [], t;
    backDeploy.data.flowStepMapByToEnvId  = {};

    for(i=0; i<records.length; i++){
        var branch = records[i][backDeploy.config.ns+'Branch__c'];
        var toEnvId = records[i][backDeploy.config.ns+'Destination_Org_Credential__r'][backDeploy.config.ns+'Environment__c'];
        var toEnvName = records[i][backDeploy.config.ns+'Destination_Org_Credential__r'][backDeploy.config.ns+'Environment__r'].Name;
        var status = records[i][backDeploy.config.ns+'Status__c'];
        var envs = envConnectionMapByBrach[branch];
        if(!envs || envs.length === 0) {
            console.log("... branch", branch, "not found in ", envConnectionMapByBrach, environments);
            continue;
        }
        if(allEnvIds[toEnvId]) {
            var warningMessage = "- Cannot show "+toEnvName+" of <a target='_blank' href='/"+records[i].Id+"'>"+records[i].Name+"</a><br/>";
            console.warn(warningMessage);
            $copado('#warningMessages').append(warningMessage);
            backDeploy.data.hasCIWarningMessages = true;
            continue;
        }

        // Add the environments ONLY if they are not previously listed.

        for(j=0; j<envs.length; j++){
            var env = envs[j];
            if( env.branch === branch ) {
                t = {
                    flowStepId: 'CIRecord_'+records[i].Id, 
                    fromEnvId: env.envId, 
                    fromEnvName: env.envName, 
                    toEnvId: toEnvId, 
                    toEnvName: toEnvName, 
                    branch: branch, 
                    testLevel: 0, 
                    autoMergeDeploy: false,
                    ContinuousIntegrationId: records[i].Id,
                    ContinuousIntegrationStatus: status
                };
                console.log('found NR:', t, env);
                backDeploy.data.flowStepMapByToEnvId[t.toEnvId] = t;
                newEnvConnections.push(t);
            }else{
                console.log('discard NR:', env);
            }
        }
    }
    // load the new environments (not listed in the deployment flow)
    backDeploy.addToEnvironmentArray(newEnvConnections);
    // append the new env connections to the existing array.
    Array.prototype.push.apply(copadoApp.envConnections, newEnvConnections);
    
    console.log('queryCIRecords found: ',newEnvConnections);
};
backDeploy.queryFlowSteps = function(){
    var NS = backDeploy.config.ns;
    copadoApp.envConnections = [];
    backDeploy.data.env2branchMap = [];
    backDeploy.data.stepIds = [];
    var records = JsRemoting.deploymentFlows.queryFlowSteps(backDeploy.config.ns, backDeploy.data.flowId);
    for(var i=0; i<records.length; i++){
        var r = records[i];
        backDeploy.data.env2branchMap[r[NS+'Source_Environment__c']] = r[NS+'Branch__c'];
        copadoApp.envConnections.push({
            flowStepId: r.Id, 
            fromEnvId: r[NS+'Source_Environment__c'], 
            fromEnvName: r[NS+'Source_Environment__r'].Name, 
            toEnvId: r[NS+'Destination_Environment__c'], 
            toEnvName: r[NS+'Destination_Environment__r'].Name, 
            branch: r[NS+'Branch__c'], testLevel:r[NS+'Test_Level__c'], 
            autoMergeDeploy: r[NS+'Automatically_Merge_and_Deploy__c']
        });
        backDeploy.data.mapStepIdEnvironments[r.Id] = r[NS+'Source_Environment__c']+'-'+r[NS+'Destination_Environment__c'];
        backDeploy.data.mapBoxIdToStepId[r[NS+'Source_Environment__c']+'-'+r[NS+'Destination_Environment__c']] = r.Id;
        backDeploy.data.stepIds.push(r.Id);
    }
};
backDeploy.getFlowSteps = function(){
    console.log('Get Flow Steps...');
    backDeploy.queryFlowSteps();
    copadoApp.environments = backDeploy.createEnvironmentArray(copadoApp.envConnections);
    backDeploy.queryCIRecords(copadoApp.environments); // NR: after the flow steps and envs are loaded, we can query the CI records
};
backDeploy.sforceFailure = function(error){
    console.error('An error has occured with the Salesforce Ajax Toolkit: ',error);
};
backDeploy.hasOtherEnvConnections = function(envId){
    if(envId == null || envId.length==0)return false;
    var count = 0;
    for (var i=0; i<copadoApp.envConnections.length; i++){
        if(copadoApp.envConnections[i].fromEnvId == envId)count++;
        if(copadoApp.envConnections[i].toEnvId == envId)count++;
    }
    if(count > 2)return true;
    return false;
};
backDeploy.addToEnvironmentArray = function(envConns){
    var map = new Object();
    for(var i=0; i<envConns.length; i++){
        backDeploy.data.env2branchMap[envConns[i].fromEnvId] = envConns[i].branch;
        var tmpFrom = [{envName:envConns[i].fromEnvName, envId:envConns[i].fromEnvId, flowStepId:envConns[i].flowStepId, branch:envConns[i].branch, testLevel:envConns[i].testLevel, autoMergeDeploy:envConns[i].autoMergeDeploy}];
        var tmpTo = [];
        if(tmpFrom[0].toEnvId && tmpFrom[0].toEnvId!==null || tmpFrom[0].toEnvId!==''){
            tmpTo = [{envName:envConns[i].toEnvName, envId:envConns[i].toEnvId, flowStepId:envConns[i].flowStepId, branch:'', testLevel:'', autoMergeDeploy:false}];
            map[envConns[i].toEnvId] = tmpTo[0];
        }
        map[envConns[i].fromEnvId] = tmpFrom[0];
    }
    for(var v in map){
        var branch = (typeof backDeploy.data.env2branchMap[map[v].envId]!='undefined')?backDeploy.data.env2branchMap[map[v].envId]:copadoApp.data.mainBranch;
        copadoApp.environments.push({envName: map[v].envName, envId:map[v].envId, flowStepId:map[v].flowStepId, branch:branch, testLevel:map[v].testLevel, autoMergeDeploy:map[v].autoMergeDeploy});
    }
    return copadoApp.environments;
};
backDeploy.createEnvironmentArray = function(envConnections){
    copadoApp.environments = [];
    return backDeploy.addToEnvironmentArray(envConnections);
};
backDeploy.getPermissions = function(){
    backDeploy.data.permissions = JsRemoting.backDeploy.getPermissionsForUser(backDeploy.config.ns, backDeploy.config.currentUserId);
};
backDeploy.loadPage = function(){
    setLockScreenMessage(backDeploy.labels.LOADING);
    lockScreen();
    try{
        console.log('Loading Page function...');
        backDeploy.getPermissions();
        backDeploy.getFlowStepCoordinates();
        backDeploy.getFlowSteps();
        backDeploy.drawEnvironmentBoxes();
        backDeploy.processAttachments();
        backDeploy.polling.startPolling();
    }
    catch(error){
        unlockScreen();
        alert(error);
    }
    backDeploy.displayLogs(0)
};
backDeploy.showGridList = function(envSourceId, envDestinationId, type){
    setLockScreenMessage(backDeploy.labels.LOADING);
    lockScreen();
    setTimeout(function(){
        try{
            var flowStepId = backDeploy.data.mapBoxIdToStepId[envSourceId+'-'+envDestinationId];
            backDeploy.data.DiffLinkTypePressed = type;
            backDeploy.data.FlowStepPressed = flowStepId;
            backDeploy.config.leftContent = '';
            backDeploy.config.rightContent = '';

            var boxId = 'floater_'+backDeploy.data.mapStepIdEnvironments[flowStepId];
            backDeploy.config.fromBranch = $copado('#box_'+envSourceId+' h3').text();
            backDeploy.config.toBranch = $copado('#box_'+envDestinationId+' h3').text();
            
            $copado('#behindDiffs').hide();
            $copado('#aheadDiffs').hide();
            $copado('#pullErrors').hide();
            $copado('#mergeErrors').hide();
            $copado('#pullValidationErrors').hide();
            $copado('#pullDeploymentErrors').hide();
            $copado('#mergeValidationErrors').hide();
            $copado('#mergeDeploymentErrors').hide();
            $copado('#pullMerged').hide();
            $copado('#mergeMerged').hide();

            $copado('#div-bh-diff').hide();
            $copado('#div-ah-diff').hide();
            $copado('#div-p-e').hide();
            $copado('#div-m-e').hide();
            $copado('#div-p-v-e').hide();
            $copado('#div-p-d-e').hide();
            $copado('#div-m-v-e').hide();
            $copado('#div-m-d-e').hide();

            $copado('#behindFileList').html('');
            $copado('#behindDiffWrapper').html('');
            $copado('#aheadFileList').html('');
            $copado('#aheadDiffWrapper').html('');

            $copado('#div-p-eFileList').html('');
            $copado('#div-p-eDiffWrapper').html('');
            $copado('#div-m-eFileList').html('');
            $copado('#div-m-eDiffWrapper').html('');
            $copado('#div-m-mFileList').html('');
            $copado('#div-m-mDiffWrapper').html('');
            $copado('#div-p-mFileList').html('');
            $copado('#div-p-mDiffWrapper').html('');

            var objFlow = backDeploy.data.results[backDeploy.data.flowId] || {};
            var objStep = backDeploy.data.results[flowStepId] || {};
            for(var i=0; objFlow.length; i++){
                if(objFlow[i].id==flowStepId){
                    objFlow = objFlow[i];
                    break;
                }
            }
                
            $tabsUL = $copado('tabsUL');
            
            var tabIndex = null;
            if(objFlow.filesMergedBehind && objFlow.filesMergedBehind.length>0){
                tabIndex = (tabIndex==null)?0:tabIndex;
                $copado('#behindDiffs').show();
                $copado('#div-bh-diff').show();
                $copado('#pullMerged').show();
                $copado('#div-p-m').show();
                backDeploy.data.diffIndex['pull'] = backDeploy.diff.getDiffIndex(objFlow, 'pull');
                backDeploy.diff.renderFileList(backDeploy.data.diffIndex['pull'], 'pull');
                backDeploy.bindings.bindbehindShowDiff();
                backDeploy.diff.renderFileList(backDeploy.data.diffIndex['pull'], 'div-p-m');
                backDeploy.bindings.bindPullMergedShowDiff();
            }
            if(objFlow.filesMergedAhead && objFlow.filesMergedAhead.length>0){
                tabIndex = (tabIndex==null)?1:tabIndex;
                $copado('#aheadDiffs').show();
                $copado('#div-ah-diff').show();
                $copado('#mergeMerged').show();
                $copado('#div-m-m').show();
                backDeploy.data.diffIndex['merge'] = backDeploy.diff.getDiffIndex(objFlow, 'merge');
                backDeploy.diff.renderFileList(backDeploy.data.diffIndex['merge'], 'merge');
                backDeploy.bindings.bindaheadShowDiff();
                backDeploy.diff.renderFileList(backDeploy.data.diffIndex['merge'], 'div-m-m');
                backDeploy.bindings.bindMergeMergedShowDiff();
            }
            if(!objFlow.pullSuccess && objFlow.pullConflictedFiles && objFlow.pullConflictedFiles.length>0){
                tabIndex = (tabIndex==null)?2:tabIndex;
                $copado('#pullErrors').show();
                $copado('#div-p-e').show();
                backDeploy.diff.renderFileList(objFlow.pullConflictedFiles, 'div-p-e');
                backDeploy.bindings.bindPullErrorShowDiff();
            }
            if(!objFlow.mergeSuccess && objFlow.mergeConflictedFiles && objFlow.mergeConflictedFiles.length>0){
                tabIndex = (tabIndex==null)?3:tabIndex;
                $copado('#mergeErrors').show();
                $copado('#div-m-e').show();
                backDeploy.diff.renderFileList(objFlow.mergeConflictedFiles, 'div-m-e');
                backDeploy.bindings.bindMergeErrorShowDiff();
            }
            if(objStep.pullValidationErrors && objStep.pullValidationErrors.length>0){
                tabIndex = (tabIndex==null)?4:tabIndex;
                $copado('#pullValidationErrors').show();
                $copado('#div-p-v-e').show();
                backDeploy.error.renderErrorList(objStep.pullValidationErrors, 'div-p-v-e');
            }
            if(objStep.pullDeploymentErrors && objStep.pullDeploymentErrors.length>0){
                tabIndex = (tabIndex==null)?5:tabIndex;
                $copado('#pullDeploymentErrors').show();
                $copado('#div-p-d-e').show();
                backDeploy.error.renderErrorList(objStep.pullDeploymentErrors, 'div-p-d-e');
            }
            if(objStep.mergeValidationErrors && objStep.mergeValidationErrors.length>0){
                tabIndex = (tabIndex==null)?6:tabIndex;
                $copado('#mergeValidationErrors').show();
                $copado('#div-m-v-e').show();
                backDeploy.error.renderErrorList(objStep.mergeValidationErrors, 'div-m-v-e');
            }
            if(objStep.mergeDeploymentErrors && objStep.mergeDeploymentErrors.length>0){
                tabIndex = (tabIndex==null)?7:tabIndex;
                $copado('#mergeDeploymentErrors').show();
                $copado('#div-m-d-e').show();
                backDeploy.error.renderErrorList(objStep.mergeDeploymentErrors, 'div-m-d-e');
            }
            createPopUpWindow(backDeploy.config.fromBranch+' vs  '+backDeploy.config.toBranch, tabIndex);
        }
        catch(error){
            alert(error);
        }
    }, 33);
    unlockScreen();
};

backDeploy.error.renderErrorList = function(res, divId){
    $copado('div[id="'+divId+'"]').show();
    var me = backDeploy;        
    var source = {
        localdata: res,
        datafields: [
            { name: 'l', type: 'string' },
            { name: 'm', type: 'string' },
            { name: 't', type: 'string' }
        ],
        datatype: 'array'
    },
    dataAdapter = new $copado.jqx.dataAdapter(source),

    //keep jquery pointer for performance query
    $grid = $copado('<div>');
    
    $copado('div[id="'+divId+'"]').html($grid);

    var preRender = function(row, column, value){  
        return '<pre class="co-preCell">'+value+'</pre>';
    };

    $grid.jqxGrid({
        width: '100%',
        source: dataAdapter,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: false, 
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50','100','200','500','1000','2000','5000'],
        pagesize: 20,
        sortable: true,
        columnsresize: true,
        autorowheight: true,
        autoheight: true,
        altrows: true,
        localization: localizationobj,
        columns: [
          {text:'Level' , columntype:'textbox', filtertype:'textbox', datafield:'l', width:80},
          {text:'Message', filtertype:'textbox', filtercondition:'contains', datafield:'m', cellsrenderer:preRender},
          {text:'Copado Tip', datafield:'t', filtertype:'textbox', filtercondition:'contains', columntype:'textbox', cellsrenderer:preRender, width:'20%'}
        ]
    });
    backDeploy.data.currentGrid = $grid;
};
// DIFF namespace
backDeploy.diff.getDiffIndex = function(obj, type){
    if(obj){
        if(type=='pull' && obj && obj.filesMergedBehind && obj.filesMergedBehind.length>0)return obj.filesMergedBehind;
        if(type=='merge' && obj && obj.filesMergedAhead && obj.filesMergedAhead.length>0)return obj.filesMergedAhead;
    }
    return [];
};
backDeploy.diff.getDivId = function(type){
    var divId = '';
    if(type=='pull')divId='behind';
    if(type=='merge')divId='ahead';
    if(type=='div-p-m'||type=='div-p-e')divId=type;
    if(type=='div-m-m'||type=='div-m-e')divId=type;
    return divId;
}
backDeploy.diff.renderFileList = function(res, type){
    var divId = backDeploy.diff.getDivId(type);
    

    $copado('div[id="'+divId+'FileList"]').show();

    var me = backDeploy;
    var _type = '';
    if(type=='pull'||type=='div-p-m'||type=='div-p-e')_type='pull';
    if(type=='merge'||type=='div-m-m'||type=='div-m-e')_type='merge';
    me.data.diffIndex[_type] = res;

    var source = {
        localdata: res,
        datafields: [
            { name: 'f', type: 'string' },
            { name: 'd', type: 'string' }
        ],
        datatype: 'array',
        updaterow: function (rowid, rowdata, commit) {
            commit(true);
            me.data.diffIndex[_type][rowid] = rowdata;
        }
    },

    //adapter wrapper
    dataAdapter = new $copado.jqx.dataAdapter(source),
    
    //keep jquery pointer for performance query
    $grid2 = $copado('<div>');
    
    $copado('div[id="'+divId+'FileList"]').html($grid2);

    /**
     * Helper to colour status cell by status
     * @param  {[type]} row         [description]
     * @param  {[type]} column      [description]
     * @param  {[type]} value       [description]
     * @param  {[type]} defaultHtml [description]
     * @return {[type]}             [description]
     */
    var cellsrenderer = function (row, column, value, defaultHtml) {
        var color = false;
        if (value == 'delete' ) {
          color = '#FFC6C6';
        }else if (value == 'update' ) {
          color = '#FFFFE3';
        }else if (value == 'create'){
          color = '#CCFFCC'
        }
        if(color){
          var element = $copado(defaultHtml);
          element.css({ 'background-color': color, 'text-align': 'center'});
          return element[0].outerHTML;
        }
        return defaultHtml;
    };

    /**
     * [cellsrendererView ]
     *  Helper to render show detail link on update row's
     */
    var cellsrendererView = function (row, column, value, defaultHtml) {
        if(me.data.diffIndex[_type][row].d == 'update'){
          var element = $copado(defaultHtml );
          //var localType = (type=='div-p-e')?'pull':((type=='div-m-e')?'merge':type);
          element.append('<a class="js-show-diff" data-type="'+type+'">Show Differences</a>');
          element.css({ 'cursor': 'pointer'});
          return element[0].outerHTML;
        }
        return defaultHtml;
    };
    
    $grid2.jqxGrid({
        width: '100%',
        source: dataAdapter,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: true, 
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50','100','200','500'],
        pagesize: 50,
        sortable: true,
        columnsresize: true,
        autorowheight: true,
        autoheight: true,
        altrows: true,
        localization: localizationobj,
        columns: [
            {text:copadoLabels.type, filtertype:'checkedlist', datafield:'d', width:120, cellsrenderer:cellsrenderer},
            {text:copadoLabels.name, filtertype:'textbox', filtercondition:'contains', editable:false, datafield:'f', cellsrenderer:cellsrendererView}
        ]
    });
    backDeploy.data.currentGrid = $grid2;

    backDeploy.bindings.bindActions();
};

/**
 * get attachment, unzip content 
 * then search the file name (this must be full relative name)
 * finally returns file content as text
 * @param  {[type]} fileName   [description]
 * @param  {[type]} attachName [description]
 * @param  {[type]} parentId   [description]
 * @return {[type]}            [description]
 */
backDeploy.diff.getZippedFileContentByName = function(fileName, attachName, parentId){
    try{
        if(fileName==''){
            alert('A filename was not selected to be retrieved from the Zip file.');
            return '';
        }
        var att = JsRemoting.attachments.getAttachmentByFileName(parentId, attachName);
        
        if(!att.length)return '';
        var zip = new JSZip(att[0].Body,{base64:true});
        return zip.file(fileName).asText(); 
    }
    catch(error){
        alert(error);
        unlockScreen();
        return '';
    }
};

/**
 * This method should recover the source and destination zips
 * then uncompress it 
 * and finally call show detailed diff popup
 * @return {[type]} [description]
 */
backDeploy.diff.showDiff = function(){
    console.log('show diff started ...');
    setLockScreenMessage(backDeploy.labels.LOADING);
    lockScreen();
    try{
        $el = $copado(this);
        setTimeout(function(){backDeploy.diff.retrieveContent($el)},33);
    }
    catch(error){
        unlockScreen();
        alert(error);
    }
};

/**
 * helper to avoid ui render engine freeze
 * @return {[type]} [description]
 */
backDeploy.diff.retrieveContent = function($el){
    //recover file name from event
    var me = backDeploy;
    //recover first string from wrapper div
    fileName = $el.parent().text().replace('Show Differences','');
    var type = $el.attr('data-type');

    if(type=='merge'){
        me.config.leftContent  = me.diff.getZippedFileContentByName(fileName, type+'Source.zip', me.data.FlowStepPressed);
        me.config.rightContent = me.diff.getZippedFileContentByName(fileName, type+'Destination.zip', me.data.FlowStepPressed);
    }
    else if(type=='pull'){
        me.config.leftContent = me.diff.getZippedFileContentByName(fileName, type+'Destination.zip', me.data.FlowStepPressed);
        me.config.rightContent  = me.diff.getZippedFileContentByName(fileName, type+'Source.zip', me.data.FlowStepPressed);
    }
    else if(type=='div-p-m'){
        me.config.leftContent = me.diff.getZippedFileContentByName(fileName, 'pullMerged.zip', me.data.FlowStepPressed);
        me.config.rightContent = me.diff.getZippedFileContentByName(fileName, 'pullSource.zip', me.data.FlowStepPressed);
    }
    else if(type=='div-m-m'){
        me.config.leftContent = me.diff.getZippedFileContentByName(fileName, 'mergeMerged.zip', me.data.FlowStepPressed);
        me.config.rightContent = me.diff.getZippedFileContentByName(fileName, 'mergeDestination.zip', me.data.FlowStepPressed);
    }
    else if(type=='div-p-e'){
        me.config.leftContent = me.diff.getZippedFileContentByName(fileName, 'pullConflicts.zip', me.data.FlowStepPressed);
        me.config.rightContent = me.diff.getZippedFileContentByName(fileName, 'mergeConflicts.zip', me.data.FlowStepPressed);
    }
    else if(type=='div-m-e'){
        me.config.leftContent = me.diff.getZippedFileContentByName(fileName, 'mergeConflicts.zip', me.data.FlowStepPressed);
        me.config.rightContent = me.diff.getZippedFileContentByName(fileName, 'pullConflicts.zip', me.data.FlowStepPressed);
    }else{
        console.warn('backDeploy.diff.retrieveContent type not found', type);
    }
    me.diff.renderDiff(type);
};

backDeploy.diff.renderDiff = function(type){
    console.log('start rendering...');
    var byId = function (id) { return document.getElementById(id); },
        baseText = difflib.stringAsLines(backDeploy.config.leftContent),
        newText = difflib.stringAsLines(backDeploy.config.rightContent),
        sm = new difflib.SequenceMatcher(baseText, newText),
        opcodes = sm.get_opcodes(),
        diffoutputdiv = $copado('div[id="'+backDeploy.diff.getDivId(type)+'DiffWrapper"]')[0];

    diffoutputdiv.innerHTML = '';
    console.log('drawing content...');
    diffoutputdiv.appendChild(diffview.buildView({
        baseTextLines: baseText,
        newTextLines: newText,
        opcodes: opcodes,
        baseTextName: ((type=='div-p-m'||type=='div-p-e'||type=='pull')?backDeploy.config.toBranch:backDeploy.config.fromBranch),
        newTextName: ((type=='div-m-m'||type=='div-m-e'||type=='merge')?backDeploy.config.toBranch:backDeploy.config.fromBranch),
        contextSize: backDeploy.config.contextSize,
        viewType: backDeploy.config.viewType,
    }));
    console.log('finished, unlocking screen...');
    unlockScreen();
};
backDeploy.showHideCIEnvironments = function(isShow){
    console.log('backDeploy.showHideCIEnvironments isShow=', isShow);
    backDeploy.showCIEnvironments = isShow;
    if(isShow)
        $copado('.CIStepWrapper').show();
    else
       $copado('.CIStepWrapper').hide();
    document.getElementById(window.warningMessagesPageBlockSectionId).style.display = (backDeploy.data.hasCIWarningMessages && isShow)?'block':'none';
    backDeploy.reinitiateCanvas();
};
backDeploy.reinitiateCanvas = function(){
    console.log('Reinitiating canvas...');
    $copado('#boxCanvas canvas').remove();
    backDeploy.config.canvas = $copado('#boxCanvas').connectSVG();
    backDeploy.getsetCoordinates();
};

