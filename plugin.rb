# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics

after_initialize do
  About.class_eval do
    def moderators
      @moderators = User.all
    end
  end
end