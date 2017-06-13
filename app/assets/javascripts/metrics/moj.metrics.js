(function() {
  'use strict';

  moj.Metrics.Percentiles = {
    el: '.js-Metrics',
    options: {
      'title': 'Percentiles distribution',
      'chartArea': {
        'width': '65%',
        'height': 300,
        'left': 80
      },
      'height': 350,
      'isStacked': true,
      'vAxis': {
        'title': 'Number of days'
      },
      'explorer': {
        'axis': 'horizontal',
        'actions': ['dragToZoom', 'rightClickToReset']
      }
    },
    init: function() {
      this.$el = $(this.el);
      if(this.$el.length > 0){
        google.charts.load('current', {
          'packages': ['corechart', 'bar']
        });
        google.charts.setOnLoadCallback($.proxy(this.drawCharts, this));
      }
    },
    parseData: function() {
      var percentiles = this.$el.data('percentiles');

      percentiles = percentiles.map(function name(e) {
        var date = new Date();
        date.setTime(Date.parse(e.date))
        e.date = date;
        return e;
      });

      var data = new google.visualization.arrayToDataTable([
        [{
          type: 'datetime',
          label: 'Day'
        }, {
          type: 'number',
          label: 'Median'
        }, {
          type: 'number',
          label: '95th Percentile'
        }]
      ]);

      data.addRows(percentiles.map(function(dataRow) {
        return [dataRow.date, dataRow.median, dataRow.ninety_fifth_percentile];
      }));

      return data;
    },
    drawCharts: function() {
      var chart = new google.visualization.ColumnChart(this.$el.get(0))
      chart.draw(this.parseData(), this.options);
    }
  };
}());