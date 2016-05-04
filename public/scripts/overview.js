$(document).ready(function() {
  overview();
});

function overview() {
  $.ajax({
    url: '/api/summoner/overview/' + summonerData.identity.region + '/' + summonerData.identity.id,
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
          $('#totalPoints').text(r.totalPoints);
      }
    }
  });
}
