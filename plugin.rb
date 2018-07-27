# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics

#@HACK clean this up and DRY up code
after_initialize do
  add_to_class(:guardian, :allow_theme?) do |theme_key|
    return true if Theme.user_theme_keys.include?(theme_key)
    return false if not Theme.theme_keys.include?(theme_key)

    # can_hotlink_user_theme? Theme.find_by(key: theme_key)
    is_staff?
  end
  
  BasicCategorySerializer.class_eval do
    attributes :notification_level_is_watching,
               :notification_level_is_tracking

    def notification_level_is_watching
      object.notification_level >= 3
    end

    def notification_level_is_tracking
      object.notification_level >= 2
    end
  end

  Category.class_eval do
    attr_accessor :subcategory_slugs
  end

  CategoryDetailedSerializer.class_eval do
    attributes :subcategory_slugs

    def include_subcategory_slugs?
      subcategory_slugs.present?
    end
  end

  CategoryList.class_eval do
    private def find_categories
      @categories = Category.includes(
        :uploaded_background,
        :uploaded_logo,
        :topic_only_relative_url,
        subcategories: [:topic_only_relative_url]
      ).secured(@guardian)

      @categories = @categories.where("categories.parent_category_id = ?", @options[:parent_category_id].to_i) if @options[:parent_category_id].present?

      if SiteSetting.fixed_category_positions
        @categories = @categories.order(:position, :id)
      else
        @categories = @categories.order('COALESCE(categories.posts_week, 0) DESC')
          .order('COALESCE(categories.posts_month, 0) DESC')
          .order('COALESCE(categories.posts_year, 0) DESC')
          .order('id ASC')
      end

      @categories = @categories.to_a

      category_user = {}
      default_notification_level = nil
      unless @guardian.anonymous?
        category_user = Hash[*CategoryUser.where(user: @guardian.user).pluck(:category_id, :notification_level).flatten]
        default_notification_level = CategoryUser.notification_levels[:regular]
      end

      allowed_topic_create = Set.new(Category.topic_create_allowed(@guardian).pluck(:id))
      @categories.each do |category|
        category.notification_level = category_user[category.id] || default_notification_level
        category.permission = CategoryGroup.permission_types[:full] if allowed_topic_create.include?(category.id)
        category.has_children = category.subcategories.present?
      end

      if @options[:parent_category_id].blank?
        subcategories = {}
        subcategory_slugs = {}
        to_delete = Set.new
        @categories.each do |c|
          if c.parent_category_id.present?
            subcategories[c.parent_category_id] ||= []
            subcategories[c.parent_category_id] << c.id

            subcategory_slugs[c.parent_category_id] ||= []
            subcategory_slugs[c.parent_category_id] << c.slug
            to_delete << c
          end
        end
        @categories.each { |c| 
          c.subcategory_ids = subcategories[c.id] 
          c.subcategory_slugs = subcategory_slugs[c.id]
        }
        @categories.delete_if { |c| to_delete.include?(c) }
      end

      if @topics_by_category_id
        @categories.each do |c|
          topics_in_cat = @topics_by_category_id[c.id]
          if topics_in_cat.present?
            c.displayable_topics = []
            topics_in_cat.each do |topic_id|
              topic = @topics_by_id[topic_id]
              if topic.present? && @guardian.can_see?(topic)
                # topic.category is very slow under rails 4.2
                topic.association(:category).target = c
                c.displayable_topics << topic
              end
            end
          end
        end
      end
    end
  end

  TopicListItemSerializer.class_eval do
    def first_poster_username
      posters.first.try(:user).try(:username)
    end

    def category_name
      object&.category&.name
    end

    attributes :first_poster_username,
               :category_name
  end

  BasicTopicSerializer.class_eval do
      def first_poster_username
        posters.first.try(:user).try(:username)
      end

      def category_name
        object&.category&.name
      end

      def posters
        object.posters || []
      end

      attributes :first_poster_username, :category_name
    end

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

  # ListController.class_eval do
  #   Discourse.filters.each do |filter|
  #     define_method("category_#{filter}") do
  #       canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
  #       self.send(filter, category: @category.id, no_subcategories: true)
  #     end

  #     define_method("parent_category_category_#{filter}") do
  #        canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
  #        self.send(filter, category: @category.id, no_subcategories: true)
  #      end
  #   end
  # end

  TopicQuery.class_eval do
    def default_results(options = {})
      options.reverse_merge!(@options)
      options.reverse_merge!(per_page: per_page_setting)

      # Whether to return visible topics
      options[:visible] = true if @user.nil? || @user.regular?
      options[:visible] = false if @user && @user.id == options[:filtered_to_user]

      # Start with a list of all topics
      result = Topic.unscoped

      if @user
        result = result.joins("LEFT OUTER JOIN topic_users AS tu ON (topics.id = tu.topic_id AND tu.user_id = #{@user.id.to_i})")
          .references('tu')
      end

      category_id = get_category_id(options[:category])
      @options[:category_id] = category_id
      if category_id
        if options[:no_subcategories] || options[:page] # kinda weird lol but it should work?
          result = result.where('categories.id = ?', category_id)
        else
          sql = <<~SQL
            categories.id IN (
              SELECT c2.id FROM categories c2 WHERE c2.parent_category_id = :category_id
              UNION ALL
              SELECT :category_id
            ) AND
            topics.id NOT IN (
              SELECT c3.topic_id FROM categories c3 WHERE c3.parent_category_id = :category_id
            )
          SQL
          result = result.where(sql, category_id: category_id)
        end
        result = result.references(:categories)

        if !@options[:order]
          # category default sort order
          sort_order, sort_ascending = Category.where(id: category_id).pluck(:sort_order, :sort_ascending).first
          if sort_order
            options[:order] = sort_order
            options[:ascending] = !!sort_ascending ? 'true' : 'false'
          end
        end
      end

      # ALL TAGS: something like this?
      # Topic.joins(:tags).where('tags.name in (?)', @options[:tags]).group('topic_id').having('count(*)=?', @options[:tags].size).select('topic_id')

      if SiteSetting.tagging_enabled
        result = result.preload(:tags)

        if @options[:tags] && @options[:tags].size > 0

          if @options[:match_all_tags]
            # ALL of the given tags:
            tags_count = @options[:tags].length
            @options[:tags] = Tag.where(name: @options[:tags]).pluck(:id) unless @options[:tags][0].is_a?(Integer)

            if tags_count == @options[:tags].length
              @options[:tags].each_with_index do |tag, index|
                sql_alias = ['t', index].join
                result = result.joins("INNER JOIN topic_tags #{sql_alias} ON #{sql_alias}.topic_id = topics.id AND #{sql_alias}.tag_id = #{tag}")
              end
            else
              result = result.none # don't return any results unless all tags exist in the database
            end
          else
            # ANY of the given tags:
            result = result.joins(:tags)
            if @options[:tags][0].is_a?(Integer)
              result = result.where("tags.id in (?)", @options[:tags])
            else
              result = result.where("tags.name in (?)", @options[:tags])
            end
          end
        elsif @options[:no_tags]
          # the following will do: ("topics"."id" NOT IN (SELECT DISTINCT "topic_tags"."topic_id" FROM "topic_tags"))
          result = result.where.not(id: TopicTag.distinct.pluck(:topic_id))
        end
      end

      result = apply_ordering(result, options)
      result = result.listable_topics.includes(:category)
      result = apply_shared_drafts(result, category_id, options)

      if options[:exclude_category_ids] && options[:exclude_category_ids].is_a?(Array) && options[:exclude_category_ids].size > 0
        result = result.where("categories.id NOT IN (?)", options[:exclude_category_ids]).references(:categories)
      end

      # Don't include the category topics if excluded
      if options[:no_definitions]
        result = result.where('COALESCE(categories.topic_id, 0) <> topics.id')
      end

      result = result.limit(options[:per_page]) unless options[:limit] == false
      result = result.visible if options[:visible]
      result = result.where.not(topics: { id: options[:except_topic_ids] }).references(:topics) if options[:except_topic_ids]

      if options[:page]
        offset = options[:page].to_i * options[:per_page]
        result = result.offset(offset) if offset > 0
      end

      if options[:topic_ids]
        result = result.where('topics.id in (?)', options[:topic_ids]).references(:topics)
      end

      if search = options[:search]
        result = result.where("topics.id in (select pp.topic_id from post_search_data pd join posts pp on pp.id = pd.post_id where pd.search_data @@ #{Search.ts_query(term: search.to_s)})")
      end

      # NOTE protect against SYM attack can be removed with Ruby 2.2
      #
      state = options[:state]
      if @user && state &&
          TopicUser.notification_levels.keys.map(&:to_s).include?(state)
        level = TopicUser.notification_levels[state.to_sym]
        result = result.where('topics.id IN (
                                  SELECT topic_id
                                  FROM topic_users
                                  WHERE user_id = ? AND
                                        notification_level = ?)', @user.id, level)
      end

      require_deleted_clause = true

      if before = options[:before]
        if (before = before.to_i) > 0
          result = result.where('topics.created_at < ?', before.to_i.days.ago)
        end
      end

      if bumped_before = options[:bumped_before]
        if (bumped_before = bumped_before.to_i) > 0
          result = result.where('topics.bumped_at < ?', bumped_before.to_i.days.ago)
        end
      end

      if status = options[:status]
        case status
        when 'open'
          result = result.where('NOT topics.closed AND NOT topics.archived')
        when 'closed'
          result = result.where('topics.closed')
        when 'archived'
          result = result.where('topics.archived')
        when 'listed'
          result = result.where('topics.visible')
        when 'unlisted'
          result = result.where('NOT topics.visible')
        when 'deleted'
          guardian = @guardian
          if guardian.is_staff?
            result = result.where('topics.deleted_at IS NOT NULL')
            require_deleted_clause = false
          end
        end
      end

      if (filter = options[:filter]) && @user
        action =
          if filter == "bookmarked"
            PostActionType.types[:bookmark]
          elsif filter == "liked"
            PostActionType.types[:like]
          end
        if action
          result = result.where('topics.id IN (SELECT pp.topic_id
                                FROM post_actions pa
                                JOIN posts pp ON pp.id = pa.post_id
                                WHERE pa.user_id = :user_id AND
                                      pa.post_action_type_id = :action AND
                                      pa.deleted_at IS NULL
                             )', user_id: @user.id,
                                 action: action
                             )
        end
      end

      result = result.where('topics.deleted_at IS NULL') if require_deleted_clause
      result = result.where('topics.posts_count <= ?', options[:max_posts]) if options[:max_posts].present?
      result = result.where('topics.posts_count >= ?', options[:min_posts]) if options[:min_posts].present?

      result = TopicQuery.apply_custom_filters(result, self)

      @guardian.filter_allowed_categories(result)
    end
  end
end