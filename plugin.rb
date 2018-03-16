# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics


#@HACK clean this up and DRY up code
after_initialize do
  About.class_eval do

    STAFF_GROUPS = [
      # exclude admins and mods bc they're already defined
      :bss,
      :developers,
      :discord_staff,
      :social_media,
      :zine_staff
    ]

    attr_accessor *STAFF_GROUPS

    def admins # actually hstaff
      @admins = find_group(55)
    end

    def moderators
      @moderators = find_group(44)
    end

    def bss
      @bss = find_group(53)
    end

    def developers
      @developers = find_group(47)
    end

    def discord_staff
      @discord_staff = find_group(45)
    end

    def social_media
      @social_media = find_group(51)
    end

    def zine_staff
      @zine_staff = find_group(49)
    end

    private

    def find_group(id)
      Group.find(id).users
        .human_users
        .order(:username_lowere)
    end
  end

  AboutSerializer.class_eval do
    About::STAFF_GROUPS.each do |group|
      has_many group, serializer: UserNameSerializer, embed: :objects
    end
  end
end