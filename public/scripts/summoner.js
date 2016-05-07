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
        $('#played').text(played);
        $('#wins').text(r.league.wins);
        $('#losses').text(r.league.losses);
        var color = (r.league.winrate >= 0.50) ? "#16AB39" : "#D01919";
        $('#winrate').text(r.league.winrate).css('color', color);
        
        var tier = r.league.tier;
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
