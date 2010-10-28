deleteLink = function() {
  var href = $(this).attr('href');
  alert(href);
  $.ajax({
    url: href,
    type: 'DELETE'
  });
};

$(document).ready(function() {
  $(".delete").click(deleteLink);
});

