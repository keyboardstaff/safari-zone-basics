import User from 'discourse/controllers/user';

export default {
  name: 'safarizone-basics-users-hide-pms',
  initialize: function() {
    User.reopen({
      /* i have no idea why my code is working */
      // showPrivateMessages(viewingSelf) {
      //   return this.siteSettings.enable_personal_messages && viewingSelf;
      // }
    });
  }
};