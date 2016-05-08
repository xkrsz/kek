$(document).ready(function() {
    championsRanking();
});

function championsRanking() {
    return $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/api/ranking/champions',
      success: function(r) {
        if (r.success) {
            console.log(r);
            var counter = 1;
            $.each(r.champions, function(index, value) {
               $("#champions").append('<tr class="tr-link" data-href="/ranking/champion/' + value.key + '"><td>' + counter + '</td><td class="mdl-data-table__cell--non-numeric"><img src="http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/' +value.key + '.png" class="ranking-img">' + value.name + '</td><td>' + value.points + '</td></tr>'); 
               //$("#championsDropdown").append('<a class="mdl-navigation__link" href="/ranking/champion/' + value.key + '"> <li class="mdl-menu__item">' + value.name + '</li></a>');
               counter++;
            });
        }
      }
    }).done(function(){
      setTimeout(function() {
        $("#championsDimmer").removeClass('active');
      }, 10);
        $("#champions tr").on('click', function (e) {
            window.location = $(this).data('href');
        });
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
