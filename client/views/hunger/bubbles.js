Template.visualizeHunger.rendered = function()
{
var width = 960,
    height = 500;

var nodes = d3.range(200).map(function() { return {radius: 10}; }),
    root = nodes[0],
    color = d3.scale.category10();

root.radius = 0;
root.fixed = true; 

var force = d3.layout.force()
    .gravity(0.05)
    .charge(function(d, i) { return i ? 0 : -2000; })
    .nodes(nodes)
    .size([width, height]);

force.start();

var svg = d3.select("#hunger").append("svg")
    .attr("width", width)
    .attr("height", height);



var entered = svg.selectAll("circle")
    .data(nodes.slice(1))
  .enter();



entered.append("circle")
    .attr("r", function(d) { return d.radius; })
    .style("fill", function(d, i) { 
      if(i < 130)
      {
        return color(1);//#0000FF;
      }
      else if (i < 186)
      {
        return color(2);//#FF0000;
      }
      else if (i < 195)
      {
        return color(3);//##00FF00;
      }
      else
      {
      return color(4);//##FFFF00;
      }
      //return color(i % 200); 
    });

force.on("tick", function(e) {
  var q = d3.geom.quadtree(nodes),
      i = 0,
      n = nodes.length;

  while (++i < n) q.visit(collide(nodes[i]));

  svg.selectAll("circle")
      .attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; });
});

svg.on("mousemove", function() {
  var p1 = d3.mouse(this);
  root.px = p1[0];
  root.py = p1[1];
  force.resume();
});

function collide(node) {
  var r = node.radius + 16,
      nx1 = node.x - r,
      nx2 = node.x + r,
      ny1 = node.y - r,
      ny2 = node.y + r;
  return function(quad, x1, y1, x2, y2) {
    if (quad.point && (quad.point !== node)) {
      var x = node.x - quad.point.x,
          y = node.y - quad.point.y,
          l = Math.sqrt(x * x + y * y),
          r = node.radius + quad.point.radius;
      if (l < r) {
        l = (l - r) / l * .5;
        node.x -= x *= l;
        node.y -= y *= l;
        quad.point.x += x;
        quad.point.y += y;
      }
    }
    return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
  };
}
}