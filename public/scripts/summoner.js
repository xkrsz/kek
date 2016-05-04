$(document).ready(function() {
  summoner();
});

function summoner() {
  $.ajax({
    url: '/api/summoner/league/eune/1371',
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
        $.each( r.league, function( key, value ) {
          alert( key + ": " + value );
        });
      }
    }
  });
}
