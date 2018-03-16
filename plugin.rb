# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics

after_initialize do
  About.class_eval do
    attr_accessor :groups

    STAFF_GROUPS = [ # todo make this IDs
      "Higher_Staff",
      "SZ_Moderators",
      "Battle_Server_Staff",
      "Development_Staff",
      "Discord_Staff",
      "Social_Birbs",
      "Zine_Staff"
    ]
    def groups
      @groups ||= STAFF_GROUPS.map do |group_name|
        Group.find_by(name: group_name)
      end
    end
  end
end