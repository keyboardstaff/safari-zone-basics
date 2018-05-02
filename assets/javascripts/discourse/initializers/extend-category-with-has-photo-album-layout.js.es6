import Discovery from 'discourse/controllers/discovery';

export default {
  name: 'extend-categories-with-has-photo-album-layout',
  initialize: function() {
    Discovery.reopen({
      photoAlbumLayout: function() {
        this.category.get('id') === 7;
      }
    });
  }
};