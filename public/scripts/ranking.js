$(document).ready(function() {
  ranking();
});

function ranking() {
  $.ajax({
    url: '/api/ranking/overall',
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
          
      }
    }
  });
}