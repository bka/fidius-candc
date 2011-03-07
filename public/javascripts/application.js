// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// ,error:function(jqXHR,data,errorThrown){alert(jqXHR.responseText+data+errorThrown);}
$(document).ready(function(){
  $(document).ajaxError(function(e,jqXHR,data,errorThrown) {
    alert(jqXHR.responseText);
    $('#loading_indicator').hide();
  });

  $(document).ajaxSend(function(e,jqXHR,options) {
    $('#loading_indicator').show();
  });
  $(document).ajaxStop(function() {
    $('#loading_indicator').hide();
  });

});
