Template.visualize2.rendered = function()
{
  var scale = 250,
    R = 6371,
    projection = d3.geo.stereographic().translate([0, 0]).scale(scale).clipAngle(180),
    path = d3.geo.path().projection(projection),
    format = d3.format(",.0f"),
    tooltip = d3.select("body").append("div").attr("class", "tooltip"),
    category = d3.scale.category10();

queue()
    .defer(d3.json, "world-110m.json")
    .defer(d3.csv, "codes.csv")
    .defer(d3.csv, "areas.csv")
    .defer(d3.tsv, "world-country-names.tsv")
    .defer(d3.csv, "continents.csv")
    .await(function(error, world, codes, areas, names, continents) {
      var nameById = {},
          areaById = {},
          idByAlpha = {},
          continentById = {};
      continents.forEach(function(d) {
        continentById[d.id] = d.continent;
      });
      names.forEach(function(d) {
        nameById[d.id] = d.name;
      });
      codes.forEach(function(d) {
        idByAlpha[d.a3] = d.n3;
      });
      areas.forEach(function(d) {
        areaById[idByAlpha[d.code]] = +d.area;
      });
      var arr = _.filter(topojson.feature(world, world.objects.countries).features, function(country){
        var ids = [566, 586, 50, 356, 76, 360, 840, 156, 392, 643];//[50, 76, 156, 356, 360, 392, 566, 586, 643, 840];
        return _.contains(ids, country.id);
      });
      console.log(arr);
      var svg = d3.select("#map").selectAll("svg")
          .data(arr)
        .enter().append("svg")
          .each(function(d) {
            d.area = 5000000 / (R * R) || d3.geo.area(d);
            kappa = areaById[d.id];
            var svg = d3.select(this),
                b = d3.geo.bounds(d),
                centroid = b[0][0] === -180 && b[1][0] === 180
                  ? [100, .5 * (b[0][1] + b[1][1])] // Russia
                  : [.5 * (b[0][0] + b[1][0]), .5 * (b[0][1] + b[1][1])];


            projection.rotate(Math.abs(b[0][1]) === -90 ? [0, 90] : Math.abs(b[1][1]) === 90 ? [0, -90] : [-centroid[0], -centroid[1]]);
            var bounds = path.bounds(d),
                area = path.area(d),
                s = Math.sqrt(d.area / area) * scale,
                dx = bounds[1][0] - bounds[0][0],
                dy = bounds[1][1] - bounds[0][1];
            svg 
                .attr("width", dx * s + 150)
                .attr("height", dy * s + 150)
              .append("g")
                .attr("transform", "scale(" + s + ")translate(" + [10 - bounds[0][0], 10 - bounds[0][1]] + ")")
              .append("path")
                .style("fill", category(continentById[d.id]))
                .attr("d", path);
          })
          .sort(function(a, b) { return areaById[b.id] - areaById[a.id]; })
          .on("mouseover", function(d, i) {
            var t = tooltip.html("").style("display", "block");
            t.append("span").attr("class", "country").text(nameById[d.id]);
            t.append("span").text(": " + areaById[d.id] + "% growth");
            t.append("span").text("; ranked " + ++i).append("sup").text(ordinal(i));
            t.append("span").text("; " + continentById[d.id]);
            t.append("span").text(".");
            var bounds = path.bounds(d),
                area = path.area(d),
                s = Math.sqrt(d.area / area) * scale,
                dx = bounds[1][0] - bounds[0][0],
                dy = bounds[1][1] - bounds[0][1];

            d.area = 10000000 / (R * R) || d3.geo.area(d);

            var factor =  1 + (areaById[d.id]/100),
                centerX = svg.width/2,
                centerY = svg.height/2;

            console.log(this);

            d3.select(this).transition().style("transform", "scale("+factor+")");//("width", (dx * s + 150) *  (1 + (areaById[d.id]/100))  );
            //d3.select(this).attr("height", (dy * s + 150) * (1 + (areaById[d.id]/100))  );
          })
          .on("mouseout", function(d) {
            var bounds = path.bounds(d),
                area = path.area(d),
                s = Math.sqrt(d.area / area) * scale,
                dx = bounds[1][0] - bounds[0][0],
                dy = bounds[1][1] - bounds[0][1];
            tooltip.style("display", null);

            d.area = 5000000 / (R * R) || d3.geo.area(d);

            d3.select(this).transition().style("transform", "scale(1)");

            // svg.attr("width", (dx * s + 150) );
            // svg.attr("height", (dy * s + 150)  );
          });
    });

function ordinal(d) {
  var e = d % 100;
  return ["st", "nd", "rd", "th"][3 < e && e < 21 ? 3 : Math.min(d % 10 - 1, 3)];
}

}









Template.visualize.rendered = function()
{
    $('#container').highcharts({
        chart: {
            type: 'spline'
        },
        title: {
            text: 'Population and Estimates over time'
        },
        subtitle: {
            text: 'from the UN database'
        },
        xAxis: {
            categories: [1800, 1820, 1840, 1860, 1880, 1900, 1920, 1940, 1960, 1980, 2000, 2020, 2040, 2060, 2080, 2100]
        },
        yAxis: {
            title: {
                text: 'Population'
            },
            labels: {
                formatter: function () {
                    return this.value + ' Billion';
                }
            },
            ceiling: 16
        },
        tooltip: {
            crosshairs: true,
            shared: true
        },
        plotOptions: {
            spline: {
                marker: {
                    radius: 4,
                    lineColor: '#666666',
                    lineWidth: 1
                }
            }
        },
        series: [{
            name: 'Recorded Population',
            marker: {
                symbol: 'circle'
            },
            data: [null, null, null, null, null, null, null, 2.3, 3, 4.4, 6.1]
        },
        {
            name: 'Estimated Population',
            marker: {
                symbol: 'circle'
            },
            data: [1, 1.1 , 1.2, 1.35, 1.5, 1.67, 1.85, 2.3, null, null, null]
        },
        {
            name: 'Low Estimate',
            marker: {
                symbol: 'diamond'
            },
            data: [null, null, null, null, null, null, null, null, null, null, 6.1, 7.45, 8.1, 7.95, 7.2, 6.1]
        },
        {
            name: 'Middle Estimate',
            marker: {
                symbol: 'triangle'
            },
            data: [null, null, null, null, null, null, null, null, null, null, 6.1, 7.6, 8.8, 9.6, 10, 10.2]
        },
        {
            name: 'High Estimate',
            marker: {
                symbol: 'square'
            },
            data: [null, null, null, null, null, null, null, null, null, null, 6.1, 7.9, 9.65, 11.4, 13.5, 15.7]
        }
        ],
    });
}