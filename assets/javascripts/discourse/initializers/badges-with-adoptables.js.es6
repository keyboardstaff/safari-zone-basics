import UserBadges from 'discourse/controllers/user-badges';

export default {
  name: 'safari-zone-basics',
  initialize: function() {
    UserBadges.reopen({
      // sortedBadgesWithoutAdoptables: Ember.computed.sort('model', 'badgeSortOrder').filter(b => b.badge_grouping_id !== 9),
      // sortedAdoptables: Ember.computed.sort('model', 'badgeSortOrder').filter(b => b.badge_grouping_id === 9)
    });
  }
};