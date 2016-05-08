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
          var counter = 0;
          var css = '';
          $('#totalPoints').text(r.totalPoints);
          $('#global').text("#" + r.rank + " out of " + r.rankCount + " in global ranking.");
          $('#masteryScore').text(r.masteryScore);
          $.each(r.topChampions, function (index, value) {
            switch (counter) {
              case 0:
                  css = 'first';
                  break;
                case 1:
                      css = 'second';
                      break;
                case 2:
                      css = 'third';
                      break;
          }
              $('.champions').append("<li class='role mdl-list__item " + css + "'><span class='mdl-list__item-primary-content'><img src='http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/" + value.championKey + ".png' class='icon-responsive'> " + value.championName + "</span><span>" + value.championPoints + "</span></li>");
              counter++;
              if(counter > 2){
                  return false;
              }
          });
          
          counter = 0;
          $.each(r.roles, function( key, value ) {
                            switch (counter) {
              case 0:
                  css = 'first';
                  break;
            case 1:
                  css = 'second';
                  break;
            case 2:
                  css = 'third';
                  break;
            default: 
                 css = '';
          }
              $('.roles').append("<li class='role mdl-list__item " + css + "'><span class='mdl-list__item-primary-content'><img src='/static/roles/" + key.toLowerCase() + ".png' class='icon-role icon-responsive'>" + key + "</span><span>" + value + "</span></li>");
              counter++;
              if(counter > 2){
                  return false;
              }
          });
      }
      
        var labels = [];
        var points = [];
        $.each(r.roles, function(key, value){
           labels.push(key); 
           points.push(value);
        });
        var ctx = $("#rolesChart");
        
        var colors = {
            "Assassin": "#681A20",
            "Fighter": "#AB8134",
            "Mage": "#4661EC",
            "Marksman": "#3B5236",
            "Support": "#1D615A",
            "Tank": "#63655B"
        };
        
        var roles = {
            labels: labels,
            datasets: [
                {
                    data: points,
                    backgroundColor: [
                        colors[labels[0]],
                        colors[labels[1]],
                        colors[labels[2]],
                        colors[labels[3]],
                        colors[labels[4]],
                        colors[labels[5]],
                    ],
                    hoverBackgroundColor: [
                    ]
                }]
        };
          
        var rolesChart = new Chart(ctx, {
            type: 'pie',
            data: roles
        });
        var labelsChampions = [];
        var pointsChampions = [];
        $.each(r.topChampions, function(key, value){
        console.log(value.championName);
           labelsChampions.push(value.championName); 
           pointsChampions.push(value.championPoints);
        });
        var ctx2 = $("#championsChart");
        
        var champions = {
            labels: labelsChampions,
            datasets: [
                {
                    data: pointsChampions,
                    backgroundColor: [
                        "#917C3B",
                        "#FBFBFC",
                        "#68442F",
                        "#D3FF93",
                        "#56727C"
                    ]
                }]
        };
        
        var championsChart = new Chart(ctx2, {
            type: 'pie',
            data: champions
        });
    }
  });
}
