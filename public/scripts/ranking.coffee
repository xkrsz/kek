ranking = ->
  $.ajax {
    type: 'GET'
    dataType: 'json'
    url: '/api/ranking/overall'
    success: (r) ->
      if r.success
        for summoner, i in r.summoners
          try
            $('#summoners').append '<tr><td>' + Number(i + 1) + '</td>' +
            '<td class="mdl-data-table__cell--non-numeric"><a href="/summoner/' + summoner.region + '/' + summoner.key + '">' + summoner.name + '</a></td>' +
            '<td class="mdl-data-table__cell--non-numeric">' + summoner.region.toUpperCase() + '</td>' +
            '<td class="mdl-data-table__cell--non-numeric">' + summoner.role + '</td>' +
            '<td class="mdl-data-table__cell--non-numeric">' + summoner.champion + '</td>' +
            '<td>' + summoner.totalPoints + '</td>' +
            '<td>' + summoner.games + '</td>' +
            '<td>' + (summoner.winrate * 100).toFixed(0) + '%</td>' +
            '<td>' + summoner.tier + ' ' + summoner.division + '</td>' +
            '</tr>'
          catch e
            console.log e
  }

$(document).ready ->
  ranking()
