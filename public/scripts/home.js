$(document).ready(function() {
  champions();
  roles();
});

function champions() {
    var counter, positions, labels, points;
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
                
                counter = 0;
                labels = [];
                points = [];
                $.each(r.champions, function(key, value) {
                   labels.push(value.name);
                   points.push(value.points);
                   counter++;
                   if(counter >= 10){
                       return false;
                   }
                });
                console.log(labels.length);
                var ctx = $("#championsChart");
                
                var champions = {
                    labels: labels,
                    datasets: [
                        {
                            data: points,
                            backgroundColor: [
                               "#c6b7b7",
                                "#4f4f4f",
                               "#636363",
                                "#213380" ,
                                "#384474" ,
                                "#4f5568",
                               "#66655c",
                                "#7d7650" ,
                                "#948644", 
                                "#ab9638"    
                            ]
                        }]
                };
                
                var chempionsChart = new Chart(ctx, {
                    type: 'pie',
                    data: champions
                });
            }
        }
    });
}

function roles() {
    var counter, positions, labels, points, avgPoints;
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
                $.each(r.roles, function(key, value){
                    $('#roles').append("<li class='role mdl-list__item " + positions[counter] + "'><span class='mdl-list__item-primary-content'><img src='/static/roles/" + key.toLowerCase() + ".png' class='img-responsive'>" + key + "</span><span>" + value + "</span></li>");
                    counter++;
                    if(counter > 2){
                        return false;
                    }
                });
                labels = [];
                points = [];
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
                            ]
                        }]
                };
                  
                var rolesChart = new Chart(ctx, {
                    type: 'pie',
                    data: roles
                });
                
                avgPoints = 0;
                for(var i = 0; i < points.length; i++){
                    avgPoints += points[i];
                }
                avgPoints = Number((avgPoints / 6).toFixed(0));
                labels.push("Average");
                points.push(avgPoints);
                var ctx2 = $('#avgChart');
                
                var rolesAvg = {
                    labels: labels,
                    datasets: [
                        {   
                            label: "Roles Points",
                            data: points,
                            backgroundColor: [
                                colors[labels[0]],
                                colors[labels[1]],
                                colors[labels[2]],
                                colors[labels[3]],
                                colors[labels[4]],
                                colors[labels[5]],
                                "#FF6384"
                            ]  
                        }]
                };
                
                var avgChart = new Chart(ctx2, {
                   type: 'bar',
                   data: rolesAvg
                });
            }
        }
    }).done(function(){
              setTimeout(function() {
        $("#championsDimmer").removeClass('active');
      }, 10);
    });    
}