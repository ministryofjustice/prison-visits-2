//= require jquery
//= require jasmine-jquery



describe('Match visitors', function() {

  beforeEach(function() {
    loadFixtures('match_visitor.html');
  });

  describe('Init', function() {
    beforeEach(function() {
      moj.Modules.MatchVisitors.init();
    });
    it('should have a class', function() {
      expect(moj.Modules.MatchVisitors.$el).toHaveClass('.js-visitorList');
    });
  });

});