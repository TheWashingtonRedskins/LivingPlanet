Template.pandemics.rendered = function () 
{
  $('#container').highcharts({
    chart: {
      type: 'column'
    },
    title: {
      text: 'Pandemics per Century'
    },
    xAxis: {
      categories: ['15th', '16th', '17th', '18th', '19th', '20th', '21st']
    },
    series: [{
      type: 'column',
      name: 'Century',
      data: [1, 2, 2, 3, 8, 6, 2]
    }
    ]
  });
};
