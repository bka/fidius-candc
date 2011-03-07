// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// ,error:function(jqXHR,data,errorThrown){alert(jqXHR.responseText+data+errorThrown);}
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
  jQuery.ajax('/tasks');
  $('#tasks_dialog').dialog('open');
}

function update_all(){
  jQuery.ajax('/actions/update_all');
}
