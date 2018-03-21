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
        .order(:username_lower)
    end
  end

  AboutSerializer.class_eval do
    STAFF_GROUPS = [
      # exclude admins and mods bc they're already defined
      :hstaff
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

  # require_dependency 'current_user'

  # class DevConstraint

  #   def initialize(options = {})
  #     @require_master = options[:require_master]
  #   end

  #   def matches?(request)
  #     return false if @require_master && RailsMultisite::ConnectionManagement.current_db != "default"
  #     provider = Discourse.current_user_provider.new(request.env)
  #     provider.current_user &&
  #       provider.current_user.admin? &&
  #       custom_dev_check(request)
  #   rescue Discourse::InvalidAccess
  #     false
  #   end

  #   # Extensibility point: plugins can overwrite this to add additional checks
  #   # if they require.
  #   def custom_dev_check(request)
  #     true
  #   end

  # end

  # Discourse::Application.routes.append do
  #   get "customize" => "color_schemes#index", constraints: DevConstraint.new
  #   get "customize/themes" => "themes#index", constraints: DevConstraint.new
  #   get "customize/colors" => "color_schemes#index", constraints: DevConstraint.new
  #   get "customize/colors/:id" => "color_schemes#index", constraints: DevConstraint.new
  #   get "customize/permalinks" => "permalinks#index", constraints: DevConstraint.new
  #   get "customize/embedding" => "embedding#show", constraints: DevConstraint.new
  #   put "customize/embedding" => "embedding#update", constraints: DevConstraint.new
  # end
end