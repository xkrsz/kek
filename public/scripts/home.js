$(document).ready(function() {
  total();
});

function total() {
  $.ajax({
    url: '/api/home/total',
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
        console.log(r.total);
        $('#total').text(r.total);
      }
    },
    complete: function() {
      setTimeout(total, 5000);
    }
  });
}
