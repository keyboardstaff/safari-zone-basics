import computed from 'ember-addons/ember-computed-decorators';
import { durationTiny } from 'discourse/lib/formatter';

// should be kept in sync with 'UserSummary::MAX_BADGES'
const MAX_BADGES = 6;

export default Ember.Controller.extend({
  userController: Ember.inject.controller('user'),
  user: Ember.computed.alias('userController.model'),

  @computed("model.badges.length")
  moreBadges(badgesLength) { return badgesLength >= MAX_BADGES; },

  @computed('model.time_read')
  timeRead(timeReadSeconds) {
    return durationTiny(timeReadSeconds);
  },

  @computed('model.time_read', 'model.recent_time_read')
  showRecentTimeRead(timeRead, recentTimeRead) {
    return timeRead !== recentTimeRead && recentTimeRead !== 0;
  },

  @computed('model.recent_time_read')
  recentTimeRead(recentTimeReadSeconds) {
    return recentTimeReadSeconds > 0 ? durationTiny(recentTimeReadSeconds) : null;
  },

  @computed('model.user_fields.@each.value')
  publicUserFields() {
    const siteUserFields = this.site.get('user_fields');
    if (!Ember.isEmpty(siteUserFields)) {
      const userFields = this.get('model.user_fields');
      return siteUserFields.filterBy('show_on_profile', true).sortBy('position').map(field => {
        Ember.set(field, 'dasherized_name', field.get('name').dasherize());
        const value = userFields ? userFields[field.get('id').toString()] : null;
        return Ember.isEmpty(value) ? null : Ember.Object.create({ value, field });
      }).compact();
    }
  }
});