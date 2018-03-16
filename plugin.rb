# name: safari-zone-basics
# about: A collection of small tweaks for the Safari Zone forum.
# version: 0.1
# authors: Flower_Child
# url: https://github.com/tipsypastels/safari-zone-basics


#@HACK clean this up and DRY up code
after_initialize do
  About.class_eval do
    attr_accessor :groups
    # inefficient but probably okay as long as there aren't that many groups
    def groups
      @groups = Group.all.select do |group|
        group.custom_fields['display_on_staff'] == 't'
      end.sort do |g1, g2| 
        g1.custom_fields['staff_order'] <=> g2.custom_fields['staff_order']
      end
    end
  end

  AboutSerializer.class_eval do
    has_many :groups, serializer: BasicGroupSerializer, embed: :objects
  end
end