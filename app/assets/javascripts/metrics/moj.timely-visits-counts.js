(function() {
  'use strict';

  moj.Metrics.TimelyVisitsCount = {
    el: '.js-TimelyVisitsCount',

    init: function() {
      this.$el = $(this.el);
      if(this.$el.length > 0){
        google.charts.load('current', {
          'packages': ['corechart']
        });
        google.charts.setOnLoadCallback($.proxy(this.drawCharts, this));
      }
    },
    drawCharts: function() {

      var visitCounts = this.$el.data('visit-counts');
      var data = new google.visualization.DataTable();

      data.addColumn('date', 'Date')
      data.addColumn('number', 'Timely')
      data.addColumn('number', 'Overdue')

      visitCounts.forEach(function(visitCount, i) {
        var date = new Date();
        date.setTime(Date.parse(visitCount.date));
        var row = [
          date,
          parseInt(visitCount.timely),
          parseInt(visitCount.overdue)
        ];

        data.addRow(row)
      }, this);

      var options = {
        'title': 'Timely and Overdue visit counts (Click and drag to zoom in, right click to reset)',
        'chartArea': {
          'width': '75%',
          'height': 300,
          'left': 80
        },
        'height': 400,
        'explorer': {
          'axis': 'horizontal',
          'actions': ['dragToZoom', 'rightClickToReset'],
          'zoomDelta': 6
        },
        'vAxis': {
          'title': 'Number of visits'
        }
      };

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.LineChart(this.$el.get(0));
      chart.draw(data, options);

    }

  };
}());