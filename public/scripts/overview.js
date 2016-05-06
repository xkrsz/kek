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
          //$('#spinner').fadeOut();
          $('#totalPoints').text(r.totalPoints);
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
              $('.champions').append("<li class='role mdl-list__item " + css + "'><span class='mdl-list__item-primary-content'><img src='http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/" + value.championName + ".png' class='icon-responsive'> " + value.championName + "</span><span>" + value.championPoints + "</span></li>");
              console.log(css);
              console.log(counter);
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
              $('.roles').append("<li class='role mdl-list__item " + css + "'><span class='mdl-list__item-primary-content'>" + key + "</span><span>" + value + "</span></li>");
              counter++;
              if(counter > 2){
                  return false;
              }
          });
      }
    }
  });
}
