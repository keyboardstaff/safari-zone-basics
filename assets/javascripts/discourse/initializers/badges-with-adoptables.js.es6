import UserBadges from 'discourse/controllers/user-badges';

export default {
  name: 'safari-zone-basics-adoptables',
  initialize: function() {
    UserBadges.reopen({
      sortedBadgesWithoutAdoptables: Ember.computed.filter('model', b => b.name !== "Bellossom"),
      sortedAdoptables: Ember.computed.filter('model', b => b.name === "Bellossom")
    });
  }
};