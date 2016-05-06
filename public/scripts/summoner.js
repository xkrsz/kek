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
        
        var tier = r.league.tier;
        console.log(tier);
        var tiers = {
            "BRONZE": "#594733",
            "SILVER": "#A1B5AC",
            "GOLD": "#CFB53B",
            "PLATINUM": "#337A7E",
            "DIAMOND": "#75C8E8",
            "MASTER": "#7C918A",
            "CHALLENGER": "#F7C95A"
        };
        
        $('.summoner img').css('border-color', tiers[tier]);
      }
    }
  });
}
