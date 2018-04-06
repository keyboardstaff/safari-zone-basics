import UserBadges from 'discourse/controllers/user-badges';

export default {
  name: 'safari-zone-basics',
  initialize: function() {
    UserBadges.reopen({
      sortedBadgesWithoutAdoptables: Ember.computed.filter('model', b => b.badge_grouping_id !== 9),
      sortedAdoptables: Ember.computed.filter('model', b => b.badge_grouping_id === 9)
    });
  }
};