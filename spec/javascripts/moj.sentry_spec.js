describe('Modules.Sentry', function() {

  beforeEach(function() {
    loadFixtures('sentry.html');
    moj.Modules.Sentry.init();
  });

  describe('...init', function() {
    it('should configure Raven', function() {
      expect(Raven.isSetup()).toBe(true);
    });
  });

  describe('...capture', function() {

    var cb = jasmine.createSpy('cb');

    beforeEach(function () {
      spyOn(Raven, 'context').and.callThrough();
      moj.Modules.Sentry.capture(cb);
    });

    it('call the function and wraps it in Raven.context', function() {
      expect(Raven.context).toHaveBeenCalled();
      expect(cb).toHaveBeenCalled();
    });
  })
});
