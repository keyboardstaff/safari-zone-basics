import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'enable-has-hstaff-star',
  initialize() {
    withPluginApi('0.8.15', api => {
      api.modifyClass('controller:user', {
        has_hstaff_star: function() {
          this.get('model.custom_fields.has_hstaff_star');
        },
      });
    });
  }
}