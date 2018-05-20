import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'enable-group-extra-name-fields',
  initialize() {
    withPluginApi('0.8.15', api => {
      api.modifyClass('controller:group', {
        full_leader_name: function() {
          this.get('model.custom_fields.full_leader_name');
        },

        full_plural_name: function() {
          this.get('model.custom_fields.full_plural_name');
        }
      });
    });
  }
}