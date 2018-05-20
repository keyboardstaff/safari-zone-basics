export default {
  setupComponent(attrs) {
    if (!attrs.group.custom_fields) {
      attrs.group.custom_fields = {};
    }
  }
};