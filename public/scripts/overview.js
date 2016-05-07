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
          console.log(r);
          var counter = 0;
          var css = '';
          //$('#spinner').fadeOut();
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
        var names = [];
        $.each(r.roles, function(key, value){
           labels.push(key); 
           names.push(value);
        });

        var ctx = $("#rolesChart");
        
        var roles = {
            labels: labels,
            datasets: [
                {
                    data: names,
                    backgroundColor: [
                        "#3F5478",
                        "#8A9FC2",
                        "#7F8BA5",
                        "#BBC1BD",
                        "#A1A0A4",
                        "#1282A2"
                    ],
                    hoverBackgroundColor: [
                    ]
                }]
        };
          
        var rolesChart = new Chart(ctx, {
            type: 'pie',
            data: roles
        });
    }
  });
}
