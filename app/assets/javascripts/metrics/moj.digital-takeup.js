(function() {
  'use strict';

  moj.Metrics.DigitalTakeup = {
    el: '.js-DigitalTakeup',

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
      var queryString = encodeURIComponent('select B, F, G');
      var URL = 'https://docs.google.com/spreadsheets/d/1JSuPGZ0WAVRyZe8ZUBZ4VuBjUea3AIpqXscKVUY0tRc/gviz/tq?tq='+queryString,
        query = new google.visualization.Query(URL);

      // query.send(this.handleQueryResponse, this);
      query.send($.proxy(this.handleQueryResponse, this));
    },

    handleQueryResponse: function(response){
      var data = response.getDataTable(),
        options = {
          'colors': ['#005EA5', '#B10D1E', '#F499BE', '#6F71AF', '#0A0C0C', '#6F777B', '#D53880', '#41BBF9'],
          'chartArea': {
            // 'width': '80%',
            'height': 1300
          },
          'firstRowNumber': 2,
          'height': 1400,
          'legend': { 'position': 'top'},
          'isStacked': true,
          'vAxis' : {
            'textStyle' : {
              'fontSize': 10
            }
          },
          'hAxis' : {
            'textStyle' : {
              'fontSize': 10
            }
          }
        };

      var chart = new google.visualization.BarChart(this.$el[0]);
      chart.draw(data, options);
    }

  };
}());