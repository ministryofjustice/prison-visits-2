//= require jquery
//= require jasmine-jquery

var input = $('<div class="js-clearRadioButtons">' +
  '<label class="block-label date-box selected" for="visit_slot_granted">' +
  '<input checked="checked" type="radio" value="2017-01-24T14:00/16:00" name="visit[slot_granted]" id="visit_slot_granted">' +
  '</label>' +
  '<a href="#" id="clear" class="js-clearRadioButton" data-target="visit[slot_granted]">Clear selection</a>' +
  '</div>');

describe('Clear radio button', function() {

  beforeEach(function() {
    $('body').append(input);
  });

  describe('Init', function() {
    beforeEach(function() {
      spyOn(moj.Modules.clearRadioButtons, 'bindEvents');
    });
    it('should call `this.bindEvents`', function() {
      moj.Modules.clearRadioButtons.init();
      expect(moj.Modules.clearRadioButtons.bindEvents).toHaveBeenCalled();
    });
  });

  describe('Checked', function() {
    it('input should be checked', function() {
      expect($('#visit_slot_granted').is(':checked')).toBe(true);
    });

    it('label should have `selected` class', function() {
      expect($('#visit_slot_granted').parent('label')).toHaveClass('selected');
    });
  });

  describe('Unchecked', function() {
    beforeEach(function() {
      moj.Modules.clearRadioButtons.init();
      $('.js-clearRadioButton').trigger('click');
    });
    it('should uncheck the input', function() {
      expect($('#visit_slot_granted').is(':checked')).toBe(false);
    });
    it('should remove the `selected` class from the label', function() {
      expect($('#visit_slot_granted').parent('label')).not.toHaveClass('selected');
    });
  });


});