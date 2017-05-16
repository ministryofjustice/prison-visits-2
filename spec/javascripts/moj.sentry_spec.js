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

});
