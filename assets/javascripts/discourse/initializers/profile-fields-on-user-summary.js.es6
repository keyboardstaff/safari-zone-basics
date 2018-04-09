import UserSummary from 'discourse/controllers/user-summary';
import computed from 'ember-addons/ember-computed-decorators';

export default {
  name: 'profile-fields-on-user-summary',
  initialize: function() {
    UserSummary.reopen({
      publicUserFields: Ember.computed.alias('userController.publicUserFields'),

      @computed('model.topic_count', 'model.post_count')
      totalPostCount: function(topicCount, postCount) {
        return topicCount + postCount;
      },

      @computed('model.days_visited')
      averagePostsPerDay: function(daysVisited) {
        var postCount = totalPostCount();
        if (daysVisited == 0) return totalPostCount();
        return totalPostCount() / daysVisited;
      }
    });
  }
};