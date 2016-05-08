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
              var winrateClass = (winrate >= 50) ? "positive" : "negative";
              var kdaClass = "";
              if(value.kda < 2){
                 kdaClass = "negative";
              } else if(value.kda >= 2 && value.kda < 2.5){
                  kdaClass = "yellow";
              } else if(value.kda >= 2.5 && value.kda < 4) {
                  kdaClass = "positive";
              } else if(value.kda >= 4) {
                  kdaClass = "blue";
              }
              console.log(kdaClass + ' ' + value.kda);
              if(value.games === undefined){
                $('#championsTable').append('<tr><td>' + counter + '</td> <td class="mdl-data-table__cell--non-numeric"> <img src="http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/' + value.championKey + '.png" class="champions-table-img">' + value.championName + '</td> <td>' + value.championLevel + '</td> <td>' + value.championPoints + '</td> <td colspan="3" style="text-align: center;"> No ranked games found this season. </td></tr>');
              } else {
                $('#championsTable').append('<tr><td>' + counter + '</td> <td class="mdl-data-table__cell--non-numeric"> <img src="http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/' + value.championKey + '.png" class="champions-table-img">' + value.championName + '</td> <td>' + value.championLevel + '</td> <td>' + value.championPoints + '</td> <td>' + value.games + '</td> <td class="' + winrateClass + '">' + winrate + '%</td><td class="' + kdaClass + '">' + value.kda + '</td></tr>');
              }
              counter++;
          });
      }
    }
  }).done(function(){
      pagination();
  });
}

function pagination() {
    $('table').each(function() {
        var currentPage = 0;
        var numPerPage = 10;
        var $table = $(this);
        $table.bind('repaginate', function() {
            $table.find('tbody tr').hide().slice(currentPage * numPerPage, (currentPage + 1) * numPerPage).show();
        });
        $table.trigger('repaginate');
        var numRows = $table.find('tbody tr').length;
        var numPages = Math.ceil(numRows / numPerPage);
        var $pager = $('<div class="pager"></div>');
        var $pagerBottom = $('<div class="pager2"></div>');
        for (var page = 0; page < numPages; page++) {
            $('<span class="page-number mdl-button mdl-js-button mdl-button--raised"></span>').text(page + 1).bind('click', {
                newPage: page
            }, function(event) {
                currentPage = event.data['newPage'];
                $table.trigger('repaginate');
                $(this).addClass('active').siblings().removeClass('active');
            }).appendTo($pager).addClass('clickable');
        }
        for (var page = 0; page < numPages; page++) {
            $('<span class="page-number mdl-button mdl-js-button mdl-button--raised"></span>').text(page + 1).bind('click', {
                newPage: page
            }, function(event) {
                currentPage = event.data['newPage'];
                $table.trigger('repaginate');
                $(this).addClass('active').siblings().removeClass('active');
            }).appendTo($pagerBottom).addClass('clickable');
        }
        $pager.insertBefore('.table-responsive').find('span.page-number:first').addClass('active');
        $pagerBottom.insertAfter('.table-responsive').find('span.page-number:first').addClass('active');
    });
}
