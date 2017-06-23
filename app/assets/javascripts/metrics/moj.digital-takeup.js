(function() {
  'use strict';

  moj.Metrics.DigitalTakeup = {
    el: '.js-DigitalTakeup',

    init: function() {
      this.$el = $(this.el);
      this.i18n = this.$el.data('i18n');
      if(this.$el.length > 0){
        google.charts.load('current', {
          'packages': ['corechart']
        });
        google.charts.setOnLoadCallback($.proxy(this.drawCharts, this));
      }
    },

    drawCharts: function() {
      var queryString = encodeURIComponent('select B, F, G');
      var URL = 'https://docs.google.com/spreadsheets/d/1JSuPGZ0WAVRyZe8ZUBZ4VuBjUea3AIpqXscKVUY0tRc/gviz/tq?tq=',
        query = new google.visualization.Query(URL+queryString);

      var dateQueryString = encodeURIComponent('select D2:E2'),
        dateQuery = new google.visualization.Query('https://docs.google.com/spreadsheets/d/1JSuPGZ0WAVRyZe8ZUBZ4VuBjUea3AIpqXscKVUY0tRc/gviz/tq?range=D2:E2');

      query.send($.proxy(this.handleQueryResponse, this));
      dateQuery.send($.proxy(this.handleDates, this));
    },

    handleDates: function(response){
      var data = response.getDataTable(),
        startDate = data.getValue(0, 0),
        endDate = data.getValue(0, 1);

      var dateRange = $('<p/>', {
          class: 'font-small',
          html: this.formatDate(startDate)+' - '+this.formatDate(endDate)
      });

      dateRange.insertBefore(this.$el[0]);
    },

    formatDate: function(date){
      var day = date.getDate(),
        month = this.i18n.months[date.getMonth()],
        year = date.getFullYear();
      return day+' '+month+' '+year;
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