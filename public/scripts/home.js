$(document).ready(function() {
  total();
  champions();
  roles();
});

function total() {
  $.ajax({
    url: '/api/home/total',
    type: 'GET',
    dataType: 'json',
    success: function(r) {
      if(r.success) {
        console.log(r.total);
        $('#total').text(r.total);
      }
    },
    complete: function() {
      setTimeout(total, 5000);
    }
  });
}

function champions() {
    var counter, positions;
    $.ajax({
        url: '/api/home/champions',
        type: 'GET',
        dataType: 'json',
        success: function (r) {
            counter = 0;
            positions = {
                0: "first",
                1: "second",
                2: "third"
            };
            if(r.success){
                $.each(r.champions, function (key, value) {
                    $('#champions').append("<li class='role mdl-list__item " + positions[counter] + "'><span class='mdl-list__item-primary-content'><img src='http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/" + value.key + ".png' class='icon-responsive'> " + value.name + "</span><span>" + value.points + "</span></li>");
                    counter++;
                    if(counter > 2){
                        return false;
                    }
                });
            }
        }
    });
}

function roles() {
    var counter, positions;
    $.ajax({
        url: '/api/home/roles',
        type: 'GET',
        dataType: 'json',
        success: function (r) {
            counter = 0;
            positions = {
                0: "first",
                1: "second",
                2: "third"
            };
            if(r.success){
                console.log(r);
                $.each(r.roles, function(key, value){
                    $('#roles').append("<li class='role mdl-list__item " + positions[counter] + "'><span class='mdl-list__item-primary-content'><img src='/static/roles/" + key.toLowerCase() + ".png' class='img-responsive'>" + key + "</span><span>" + value + "</span></li>");
                    counter++;
                    if(counter > 2){
                        return false;
                    }
                });
            }
        }
    });    
}