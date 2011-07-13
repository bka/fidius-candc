// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// ,error:function(jqXHR,data,errorThrown){alert(jqXHR.responseText+data+errorThrown);}
var dialog_content;

$(document).ready(function(){
  $(document).ajaxError(function(e,jqXHR,data,errorThrown) {
    alert(jqXHR.responseText);
    $('#loading_indicator').hide();
  });

  $(document).ajaxSend(function(e,jqXHR,options) {
    // do not show loading indicator on priodical update
    if(options.url != "/actions/update_all"){
      $('#loading_indicator').show();
    }
  });
  $(document).ajaxComplete(function(e,jqXHR,options) {
    // do not show loading indicator on priodical update
    if(options.url != "/actions/update_all"){
      $('#loading_indicator').hide();
      update_all();
    }
  });

});

function open_tasks(){
  link_to_dialog('/tasks', 'Tasks');
}

function open_console(path){
	if ((!term) || (term.closed)) {

    $('#console_dialog').html("");
    jQuery.ajax("/console/dialog",{asnyc:false});
    $('#console_dialog').dialog('open');
  }
}

function link_to_dialog(path,title){
  jQuery.ajax(path);
  $('#standard_dialog').html("");
  $('#standard_dialog').dialog('open', title);
}

function update_all(){
  jQuery.ajax('/actions/update_all');
}

function closed_event_dialog(){
  jQuery.ajax('/actions/dialog_closed');  
}

function attack_host(host_id){
  link_to_dialog('/hosts/'+host_id+'/exploits', "Attack Host");
}

function attack_interface(interface_id){
  link_to_dialog('/interfaces/'+interface_id+'/exploits', "Attack Interface");
}

function attack_service(service_id){
  link_to_dialog('/services/'+service_id+'/exploits', "Attack Service");
}

function autoexploit_host(host_id){
  jQuery.ajax('/actions/attack_host',{data:"host_id="+host_id});
}

function autoexploit_interface(interface_id){
  jQuery.ajax('/actions/attack_interface',{data:"interface_id="+interface_id});
}

function autoexploit_service(service_id){
  jQuery.ajax('/actions/attack_service',{data:"service_id="+service_id});
}

function exploit_with_ai_host(host_id){
  jQuery.ajax('/actions/attack_ai_host',{data:"host_id="+host_id});
}

function exploit_with_ai_interface(interface_id){
  jQuery.ajax('/actions/attack_ai_interface',{data:"interface_id="+interface_id});
}

function exploit_with_ai_service(service_id){
  jQuery.ajax('/actions/attack_ai_service',{data:"service_id="+service_id});
}
function reconnaissance_from_interface(interface_id){
  jQuery.ajax('/actions/reconnaissance_from_interface',{data:"interface_id="+interface_id});
}
function booby_trapping(host_id){
  jQuery.ajax('/actions/booby_trapping',{data:"host_id="+host_id});
}

function nvd_entries(host_id){
  jQuery.ajax("/hosts/"+host_id+"/nvd_entries");
}

function pick_exploit(id){
  jQuery.ajax("/exploits/"+id+"/pick");
}

function run_single_exploit_host(host_id, exploit_id){
  jQuery.ajax('/actions/single_exploit_host',{data:{'host_id':host_id, 'exploit_id':exploit_id}});
}

function run_single_exploit_interface(interface_id, exploit_id){
  jQuery.ajax('/actions/single_exploit_interface',{data:{'interface_id':interface_id, 'exploit_id':exploit_id}});
}


function run_single_exploit_service(service_id, exploit_id){
  jQuery.ajax('/actions/single_exploit_service',{data:{'service_id':service_id, 'exploit_id':exploit_id}});
}

var storePos = [];
function save_layout(){
  storePos = [];
  for(i=0;i<layout.nodes().length;i++){
    node = layout.nodes()[i];
    storePos[node.hostID] = {x:node.x,y:node.y,marked:node.marked};
  }
}

function mark_host(hostID){
  if(hostID != -1){
    for(i=0;i<layout.nodes().length;i++){
      node = layout.nodes()[i];
      node.marked=false;
    }
    for(i=0;i<layout.nodes().length;i++){
      node = layout.nodes()[i];
      if(hostID == node.hostID){
        node.marked=true;
      }
    }
    save_layout();
    layout.reset();
    vis.render();
    restore_layout();
  }
}

function restore_layout(){
  for(i=0;i<layout.nodes().length;i++){
    node = layout.nodes()[i];
    if(storePos[node.hostID]){
      layout.nodes()[i].x = storePos[node.hostID].x;
      layout.nodes()[i].y = storePos[node.hostID].y;
      layout.nodes()[i].marked = storePos[node.hostID].marked;
    }
  }
  vis.render();
}

function remove_finished_tasks(){
  jQuery.ajax('/actions/remove_finished_tasks');
}

