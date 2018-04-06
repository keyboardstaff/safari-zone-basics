import UserSummary from 'discourse/controllers/user-summary';
import computed from 'ember-addons/ember-computed-decorators';

export default {
  name: 'profile-fields-on-user-summary',
  initialize: function() {
    UserSummary.reopen({
      publicUserFields: Ember.computed.alias('userController.publicUserFields')
    });
  }
};