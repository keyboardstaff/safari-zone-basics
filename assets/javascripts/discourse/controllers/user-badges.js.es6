export default Ember.Controller.extend({
  user: Ember.inject.controller(),
  username: Ember.computed.alias('user.model.username_lower'),
  sortedBadges: Ember.computed.sort('model', 'badgeSortOrder').filter(badge => badge.badge_grouping_id !== 9),
  badgeSortOrder: ['badge.badge_type.sort_order', 'badge.name'],
});