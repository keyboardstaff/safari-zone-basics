# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics

#@HACK clean this up and DRY up code
after_initialize do
  About.class_eval do

    STAFF_GROUPS ||= [
      # exclude admins and mods bc they're already defined
      :hstaff,
      :bss,
      :developers,
      :discord_staff,
      :social_media,
      :zine_staff
    ]

    attr_accessor *STAFF_GROUPS

    def hstaff
      @hstaff = find_group(55)
    end

    def admins
      @admins = find_group(41)
    end

    def moderators
      @moderators = find_group(44)
    end

    def bss
      @bss = find_group(53)
    end

    def developers # and designers
      @developers = (find_group(47) + find_group(57)).uniq
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
        .order(:username_lower)
    end
  end

  AboutSerializer.class_eval do
    STAFF_GROUPS ||= [
      # exclude admins and mods bc they're already defined
      :hstaff,
      :bss,
      :developers,
      :discord_staff,
      :social_media,
      :zine_staff
    ]

    STAFF_GROUPS.each do |group|
      has_many group, serializer: UserNameSerializer, embed: :objects
    end
  end

  # require_dependency 'topic_query'
  # TopicQuery.class_eval do
  #   def list_category_topic_ids(category)
  #     query = default_results(category: category.id)
  #     pinned_ids = query.where('topics.pinned_at IS NOT NULL AND topics.category_id = ?', category.id).limit(nil).order('pinned_at DESC').pluck(:id)
  #     non_pinned_ids = query.where('topics.pinned_at IS NULL OR topics.category_id <> ?', category.id).pluck(:id)

  #     (pinned_ids + non_pinned_ids)[0...@options[:per_page]]
  #   end
  # end
end