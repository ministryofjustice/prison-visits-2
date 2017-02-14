//= require jquery
//= require jasmine-jquery

var html = $('<table id="myTable" class="tablesorter">' +
  '<thead><tr><th id="h1">heading1</th><th>heading2</th><th>heading3</th></tr></thead>' +
  '<tbody>' +
  '<tr id="row1" role="row">' +
  '<td>3</td>' +
  '<td>3</td>' +
  '<td>3</td>' +
  '</tr>' +
  '<tr id="row2" role="row">' +
  '<td>2</td>' +
  '<td>2</td>' +
  '<td>2</td>' +
  '</tr>' +
  '<tr id="row3" role="row">' +
  '<td>1</td>' +
  '<td>1</td>' +
  '<td>1</td>' +
  '</tr>' +
  '</tbody></table>');

describe('Tablesorter', function() {

  beforeEach(function() {
    $('body').append(html);
    moj.Modules.tableSorter.init();
  });

  describe('Classes', function() {
    it('table to have `tablesorter-default`', function() {
      expect($('#myTable')).toHaveClass('tablesorter-default');
    });
    it('table header row to have `tablesorter-headerRow`', function() {
      expect($('#myTable thead tr')).toHaveClass('tablesorter-headerRow');
    });
    it('table header row column to have `tablesorter-headerRow`', function() {
      expect($('#myTable thead tr th:first')).toHaveClass('tablesorter-header');
    });
  });

  describe('Sorting a column', function() {

    beforeEach(function(done) {
      spyOnEvent('#h1', 'click');
      $('#h1').trigger('click');
      done();
    }, 1000);

    it('should change the order of the first column to 1,2,3', function(done) {
      setTimeout(function() {
        // This can take a little while for some reason
        expect($('.tablesorter td:first').text()).toBe('1');
        done();
      }, 9000);
    }, 10000);
    it('should have triggered the click event on the first heading', function() {
      expect('click').toHaveBeenTriggeredOn('#h1');
    });
  });

});