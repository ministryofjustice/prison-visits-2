describe('Match visitor to NOMIS', function() {

  beforeEach(function() {
    loadFixtures('visitor_details.html');
    moj.Modules.MatchVisitors.init();
  });

  describe('On select of visitor ID 125888', function() {

    beforeEach(function() {
      $('#visitors-fixture li:eq(0) select').val('12588').trigger('change');
    });

    it('should disable all other select options with value 125888', function() {
      expect($('#visitors-fixture li:eq(0) select option:eq(1)')).not.toBeDisabled();
      expect($('#visitors-fixture li:eq(1) select option:eq(1)')).toBeDisabled();
      expect($('#visitors-fixture li:eq(2) select option:eq(1)')).toBeDisabled();
    });

    it('should disable the not on list checkbox', function() {
      expect($('#visit_visitors_attributes_0_not_on_list')).toBeDisabled();
    });

    it('should uncheck the not on list checkbox', function() {
      expect($('#visit_visitors_attributes_0_not_on_list')).not.toBeChecked();
    });

    it('should check the banned checkbox', function() {
      expect($('#visit_visitors_attributes_0_banned')).toBeChecked();
    });

    it('visitor item to be banned', function() {
      expect($('#visitors-fixture li:eq(0)').data('banned')).toBe(true);
    });

    it('visitor item to be processed', function() {
      expect($('#visitors-fixture li:eq(0)').data('processed')).toBe(true);
    });

  });

  describe('On select and deselect of visitor ID 125888', function() {

    beforeEach(function() {
      $('#visitors-fixture li:eq(0) select').val('12588').trigger('change');
      $('#visitors-fixture li:eq(0) select').val('').trigger('change');
    });

    it('should enable all other select options with value 125888', function() {
      expect($('#visitors-fixture li:eq(0) select option:eq(1)')).not.toBeDisabled();
      expect($('#visitors-fixture li:eq(1) select option:eq(1)')).not.toBeDisabled();
      expect($('#visitors-fixture li:eq(2) select option:eq(1)')).not.toBeDisabled();
    });

    it('should enable the not on list checkbox', function() {
      expect($('#visit_visitors_attributes_0_not_on_list')).not.toBeDisabled();
    });

    it('should keep the banned checkbox checked', function() {
      expect($('#visit_visitors_attributes_0_banned')).toBeChecked();
    });

    it('visitor item to be banned', function() {
      expect($('#visitors-fixture li:eq(0)').data('banned')).toBe(true);
    });

    it('visitor item to be unprocessed', function() {
      expect($('#visitors-fixture li:eq(0)').data('processed')).toBe(false);
    });

  });

});
