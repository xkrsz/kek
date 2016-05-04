$(document).ready(function() {
  summoner();
});

function summoner() {
  $.ajax({
    url: '/api/summoner/league/' + summonerData.identity.region + '/' + summonerData.identity.id,
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
        $('#tier').text(r.league.tier + ' ' + r.league.division);
        var played = r.league.wins + r.league.losses;
        console.log(played);
        $('#played').text(played);
        $('#wins').text(r.league.wins);
        $('#losses').text(r.league.losses);
        $('#winrate').text(r.league.winrate);
      }
    }
  });
}
