import User from 'discourse/controllers/user';

export default {
  name: 'safarizone-basics-users-hide-pms',
  initialize: function() {
    User.reopen({
      /* doesn't work. can't override existing function? */
      // showPrivateMessages(viewingSelf) {
      //   return this.siteSettings.enable_personal_messages && viewingSelf;
      // }
    });
  }
};