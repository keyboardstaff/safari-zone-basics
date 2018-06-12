export default {
  setupComponent(attrs) {
    if (!attrs.model.custom_fields) {
      attrs.model.custom_fields = {};
    }
  }
};