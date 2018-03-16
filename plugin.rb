# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics


#@HACK there has to be a better way to do it than this shitty metaprogramming
after_initialize do
  About.class_eval do
    Group.all.select { |g| g.custom_fields['display_on_staff'] == 't' }.each do |g|
      define_method(g.name) { g.members }
      define_method(g.name + "_color") { g.flair_bg_color }
      define_method(g.name + "_name") { g.name }
      define_method(g.name + "_icon") { g.flair_url }
      define_method(g.name + "_count") { g.users.length }
    end
  end

  AboutSerializer.class_eval do
    Group.all.select { |g| g.custom_fields['display_on_staff'] == 't' }.each do |g|
      has_many g.name.to_sym, serializer: UserNameSerializer, embed: :objects
      has_one (g.name + "_name").to_sym, embed: :objects
    end
  end
end