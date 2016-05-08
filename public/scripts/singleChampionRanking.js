$(document).ready(function() {
    var champion = '';
    champion = window.location.pathname.slice(18);
    $('#header').text(champion.charAt(0).toUpperCase() + champion.slice(1) + ' Ranking');
    singleChampionRanking(champion);
});

function singleChampionRanking(champion) {
    return $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/api/ranking/champion/' + champion,
      success: function(r) {
        if (r.success) {
            console.log(r);
            var counter = 1;
            $.each(r.summoners, function(index, value) {
                $('#singleChampion').append('<tr><td>' + Number(counter) + '</td>' + '<td class="mdl-data-table__cell--non-numeric">' + value.name + '</td>' + '<td class="mdl-data-table__cell--non-numeric">' + value.region.toUpperCase() + '</td><td>' + value.points  + '<td class="mdl-data-table__cell--non-numeric tier-data">' + value.division + '<img src="/static/tiers/' + value.tier.toLowerCase() + '.png" class="tier-img"></td></tr>');
               counter++;
            });
        }
      }
    }).done(function(){
      setTimeout(function() {
        $("#championsDimmer").removeClass('active');
      }, 10);
        pagination();
    });
    
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
        for (var page = 0; page < numPages; page++) {
            $('<span class="page-number mdl-button mdl-js-button mdl-button--raised"></span>').text(page + 1).bind('click', {
                newPage: page
            }, function(event) {
                currentPage = event.data['newPage'];
                $table.trigger('repaginate');
                $(this).addClass('active').siblings().removeClass('active');
            }).appendTo($pager).addClass('clickable');
        }
        $pager.insertAfter('.table-responsive').find('span.page-number:first').addClass('active');
    });
}
}
