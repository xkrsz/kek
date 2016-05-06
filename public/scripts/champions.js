$(document).ready(function() {
    $('#championsTab').one('click', function() {
        champions();
    });
});

function champions() {
  $.ajax({
    url: '/api/summoner/champions/' + summonerData.identity.region + '/' + summonerData.identity.id,
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
          var counter = 1;
          $.each(r.champions, function (index, value) {
              var winrate = Number((value.winrate * 100).toFixed(0));
              console.log(winrate);
              if(value.games === undefined){
                $('#championsTable').append('<tr><td>' + counter + '</td> <td class="mdl-data-table__cell--non-numeric"> <img src="http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/' + value.championKey + '.png">' + value.championName + '</td> <td>' + value.championLevel + '</td> <td>' + value.championPoints + '</td> <td colspan="3" style="text-align: center;"> No ranked games found this season </td></tr>');
              } else {
                $('#championsTable').append('<tr><td>' + counter + '</td> <td class="mdl-data-table__cell--non-numeric"> <img src="http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/' + value.championKey + '.png">' + value.championName + '</td> <td>' + value.championLevel + '</td> <td>' + value.championPoints + '</td> <td>' + value.games + '</td> <td>' + winrate + '%</td><td>' + value.kda + '</td></tr>');
              }
              counter++;
          });
      }
    }
  });
}
