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

      // unnecessary duplication, should call totalPostCount() when you figure out how
      @computed('model.days_visited', 'model.topic_count', 'model.post_count')
      averagePostsPerDay: function(daysVisited, topicCount, postCount) {
        var totalPostCount = topicCount + postCount;
        if (daysVisited == 0) return postCount;
        return postCount / daysVisited;
      }
    });
  }
};