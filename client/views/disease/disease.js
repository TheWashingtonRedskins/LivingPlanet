$(function () {
  $('#container').highcharts({
    chart: {
      zoomType: 'xy'
    },
    title: {
      text: 'Pandemics per Century'
    },
    subtitle: {
      text: 'Source: Wikipedia'
    },
    xAxis: [{
      categories: ['15th', '16th', '17th', '18th', '19th', '20th', '21st']
    }],
    yAxis: [{ // Primary yAxis
      labels: {
        format: '{value}°C',
        style: {
          color: Highcharts.getOptions().colors[1]
        }
      },
      title: {
        text: 'Number of Pandemics',
        style: {
          color: Highcharts.getOptions().colors[1]
        }
      }
    }],
    tooltip: {
      shared: true
    },
    legend: {
      layout: 'vertical',
      align: 'left',
      x: 120,
      verticalAlign: 'top',
      y: 100,
      floating: true,
      backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
    },
    series: [{
      name: 'Pandemics',
      type: 'column',
      yAxis: 1,
      data: [1, 3, 1, 8, 6, 2],
      tooltip: {
      }

    }, {
      name: 'Temperature',
      type: 'spline',
      data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
      tooltip: {
        valueSuffix: '°C'
      }
    }]
  });
});
