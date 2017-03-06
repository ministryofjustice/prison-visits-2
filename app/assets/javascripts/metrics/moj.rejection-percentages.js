(function () {
  'use strict';

  moj.Metrics.RejectionPercentage = {
    el: '.js-RejectionPercentages',

    init: function () {
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback($.proxy(this.drawCharts, this));

      this.$el = $(this.el);
    },
    drawCharts: function() {

      var rejectionPercentages = this.$el.data('rejections-percentages');
      var data                 = new google.visualization.DataTable();

      data.addColumn('date',   'Date')
      data.addColumn('number', 'No allowance')
      data.addColumn('number', 'Visitor not on list')
      data.addColumn('number', 'Visitor banned')
      data.addColumn('number', 'Slot unavailable')
      data.addColumn('number', 'No adult')
      data.addColumn('number', 'Prisoner details incorrect')
      data.addColumn('number', 'Prisoner non association')
      data.addColumn('number', 'Child protection issues')
      data.addColumn('number', 'Prisoner moved')
      data.addColumn('number', 'Prisoner released')
      data.addColumn('number', 'Duplicate visit request')
      data.addColumn('number', 'Prisoner banned')
      data.addColumn('number', 'Prisoner out of prison')

      rejectionPercentages.forEach(function(rejectionPercentage) {
        var date = new Date();
        date.setTime(Date.parse(rejectionPercentage.date))
        var row = [
          date,
          parseInt(rejectionPercentage.no_allowance),
          parseInt(rejectionPercentage.visitor_not_on_list),
          parseInt(rejectionPercentage.visitor_banned),
          parseInt(rejectionPercentage.slot_unavailable),
          parseInt(rejectionPercentage.no_adult),
          parseInt(rejectionPercentage.prisoner_details_incorrect),
          parseInt(rejectionPercentage.prisoner_non_association),
          parseInt(rejectionPercentage.child_protection_issues),
          parseInt(rejectionPercentage.prisoner_moved),
          parseInt(rejectionPercentage.prisoner_released),
          parseInt(rejectionPercentage.duplicate_visit_request),
          parseInt(rejectionPercentage.prisoner_banned),
          parseInt(rejectionPercentage.prisoner_out_of_prison)
        ];
        data.addRow(row)
      });


      var options = {
        'title': 'Rejection Reasons Percentages (Click and drag to zoom in, right click to reset)',
        'colors': ['#005EA5','#28A197', '#006435', '#FFBF48', '#F47738', '#B58840', '#B10D1E', '#F499BE', '#6F71AF', '#0A0C0C', '#6F777B', '#D53880', '#41BBF9'],
        'chartArea': { 'width': '65%', 'height': 300, 'left': 80 },
        'height': 400,
        'explorer': {
          'axis': 'horizontal',
          'actions': ['dragToZoom', 'rightClickToReset'],
          'zoomDelta': 2,
          'maxZoomIn': 0.05
        },
        'isStacked': 'percent',
        'vAxis': {
          'title': 'Percentage of rejected visits'
        }
      };

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.ColumnChart(this.$el.get(0));
      chart.draw(data, options);

    }

  };
}());
