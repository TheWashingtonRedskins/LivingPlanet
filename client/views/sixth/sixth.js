if (Meteor.isClient) {
  var state =1;
  var pie, innerRadius, outerRadius, arc, color, svg;
  var dataVal0=[];
  var dataVal1=[];
  var legend=[];
  function arcs(data2, data3) {
      var arcs0 = pie(data2),
          arcs1 = pie(data3),
          i = -1,
          arc;
      while (++i < data3.length) {
        arc = arcs0[i];
        arc.innerRadius = innerRadius;
        arc.outerRadius = outerRadius;
        arc.next = arcs1[i];
      }
      return arcs0;
    }

    function transition(state) {
      var path = d3.selectAll(".arc > path")
          .data(state ? arcs(dataVal0, dataVal1) : arcs(dataVal1, dataVal0));

      // Wedges split into two rings.
      var t0 = path.transition()
          .duration(1000)
          .attrTween("d", tweenArc(function(d, i) {
            return {
              innerRadius: i & 1 ? innerRadius : (innerRadius + outerRadius) / 2,
              outerRadius: i & 1 ? (innerRadius + outerRadius) / 2 : outerRadius
            };
          }));

      // Wedges translate to be centered on their final position.
      var t1 = t0.transition()
          .attrTween("d", tweenArc(function(d, i) {
            var a0 = d.next.startAngle + d.next.endAngle,
                a1 = d.startAngle - d.endAngle;
            return {
              startAngle: (a0 + a1) / 2,
              endAngle: (a0 - a1) / 2
            };
          }));

      // Wedges then update their values, changing size.
      var t2 = t1.transition()
            .attrTween("d", tweenArc(function(d, i) {
              return {
                startAngle: d.next.startAngle,
                endAngle: d.next.endAngle
              };
            }));

      // Wedges reunite into a single ring.
      var t3 = t2.transition()
          .attrTween("d", tweenArc(function(d, i) {
            return {
              innerRadius: innerRadius,
              outerRadius: outerRadius
            };
          }));

      //setTimeout(function() { transition(!state); }, 5000);
    }

    function tweenArc(b) {
      return function(a, i) {
        var d = b.call(this, a, i), i = d3.interpolate(a, d);
        for (var k in d) a[k] = d[k]; // update data
        return function(t) { return arc(i(t)); };
      };
    }

  Template.pie.rendered =function(){
    var width = 960,
    height = 500;
    outerRadius = Math.min(width, height) * .5 - 10;
    innerRadius = outerRadius * .6;

    var data,
        data0 = [{value: 17987, type: "Threatened with extinction", percentage: 37}, {value: 875, type: "Extinct", percentage: 2}, {value: 3931, type: "Near threatened", percentage: 8}, {value: 6548, type: "Data deficient", percentage: 14},{value: 19032, type: "Least cocnern", percentage: 40}],//[{value: 19032, type: "Least Concern", percentage: 40}, {value: 3931, type: "Near threatened", percentage: 8}, {value: 9075, type: "Vulnerable", percentage: 19}, {value: 4891, type: "Endangered", percentage: 10},{value: 3325, type: "Critically endangered", percentage: 7},{value: 875, type: "Extinct", percentage: 2},{value: 6548, type: "Data deficient", percentage: 14}],//2009
        data1 = [{value: 15589, type: "Threatened with extinction", percentage: 41}, {value: 844, type: "Extinct", percentage: 2}, {value: 3700, type: "Near threatened", percentage: 10}, {value: 3580, type: "Data deficient", percentage: 10},{value: 14334, type: "Least cocnern", percentage: 38}];//2004

    color = d3.scale.category20();

    arc = d3.svg.arc();

    pie = d3.layout.pie()
        .sort(null);

    svg = d3.select("#pie").append("svg")
        .attr("width", width)
        .attr("height", height);

    for (i = 0; i < data0.length; i ++) {
     dataVal0[i] = data0[i].value;
     legend[i] = {"type": data0[i].type, "color": color(i)};
    }

    for (i = 0; i < data1.length; i ++) {
      dataVal1[i] = data1[i].value;
    }

    svg.selectAll(".arc")
        .data(arcs(dataVal0, dataVal1))
      .enter().append("g")
        .attr("class", "arc")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")
      .append("path")
        .attr("fill", function(d, i) { return color(i); })
        .attr("d", arc);

    transition(state);

    var content = "<div id='legend'>";
    for (i = 0; i < legend.length; i ++) {
      content +="<div class='swatchCont'><div class='swatch' style='background-color: " + legend[i].color + ";'></div>" + legend[i].type + "</div>";
    }
    content += "</div>";
    $('#pie').after(content);
  };

  // Inside the if (Meteor.isClient) block, right after Template.body.helpers:
  Template.pie.events({
    "click #yearOp1": function (event) {

      if (!state){
        state = !state;
        transition(state);
      }

    },
    "click #yearOp2": function (event) {
   
      if (state){
        state = !state;
        transition(state);
      }

    }
  });
}

