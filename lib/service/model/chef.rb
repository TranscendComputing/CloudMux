class Chef < ConfigManager
    include Mongoid::Document

    embeds_many :cookbooks
end