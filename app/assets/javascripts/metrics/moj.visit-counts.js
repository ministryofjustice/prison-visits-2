(function () {
  'use strict';

  moj.Metrics.VisitCounts = {
    el: '.js-VisitsCounts',

    init: function () {
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback($.proxy(this.drawCharts, this));

      this.$el = $(this.el);
    },
    drawCharts: function() {

      var visitCounts = this.$el.data('visit-counts');
      var data = new google.visualization.DataTable();

      data.addColumn('date',   'Date')
      data.addColumn('number', 'Booked')
      data.addColumn('number', 'Cancelled')
      data.addColumn('number', 'Rejected')
      data.addColumn('number', 'Withdrawn')
      visitCounts.forEach(function(visitCount, i) {
        var date = new Date();
        date.setTime(Date.parse(visitCount.date));
        var row = [
          date,
          parseInt(visitCount.booked),
          parseInt(visitCount.cancelled),
          parseInt(visitCount.rejected),
          parseInt(visitCount.withdrawn)
        ];
        data.addRow(row)

      }, this);

      var options = {
        'title': 'Visits by processing states (Click and drag to zoom in, right click to reset)',
        'chartArea': { 'width': '75%', 'height': 300, 'left': 80 },
        'height': 400,
        'explorer': {
          'axis': 'horizontal',
          'actions': ['dragToZoom', 'rightClickToReset'],
          'zoomDelta': 18
        },
        'vAxis': {
          'title': 'Number of visits'
        }
      };

      var chart = new google.visualization.AreaChart(this.$el.get(0));
      chart.draw(data, options);
    }

  };
}());
