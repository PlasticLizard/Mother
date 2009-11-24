require "rss/maker"
require "active_support"
require "erb"

module Mother
  module ModelRSS

    def to_rss(options={})
      options =
              {
                      :max_results=>25,
                      :version=>"2.0",
                      :sort=>true,
                      :item_link_template=>"#nolink"
              }.merge(options)

      feed = RSS::Maker.make(options[:version]) do |rss|

        rss.channel.title = self.name.titleize
        rss.channel.link = options[:feed_link] || "#nolink"
        rss.channel.description = "List of recent #{self.name.titleize.pluralize}"
        rss.items.do_sort = options[:sort] if options[:sort]

        order_string =  "$natural -1" ||
         ( "updated_at desc" if self.respond_to? :updated_at)

        self.find(:all,:order=>order_string, :limit=>options[:max_results]).each do |model|
          item_from_model(rss,model,options)
        end

      end

      feed.to_xml
    end

    private

    def item_from_model(rss,model,options)
      item = rss.items.new_item
          item.title = model.name
          item.link = ERB.new(options[:item_link_template]).result(binding)
          item.date = (Time.parse(model.updated_at).localtime if model.updated_at) || Time.now
          item.description = model.description if model.respond_to? :description
    end


  end
end
     