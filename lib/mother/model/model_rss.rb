require "rss/maker"
require "active_support"

module Mother
  module ModelRSS

    def to_rss(options={})
      options =
              {
                      :max_results=>25,
                      :version=>"2.0",
                      :sort=>true
              }.merge(options)

      feed = RSS::Maker.make(options[:version]) do |rss|

        rss.channel.title = val(self, :rss_title, :title) || self.name.titleize
        rss.channel.link = options[:feed_link] || val(self, :rss_link, :link, :url, :uri) || "#nolink"
        rss.channel.description = val(self, :rss_description, :description) || "List of recent #{self.name.titleize.pluralize}"
        rss.items.do_sort = options[:sort] if options[:sort]

        order_string = val(self,:rss_sort,:rss_order,:sort,:order_by)
        order_string ||= "updated_at desc" if self.respond_to? :updated_at
        order_string ||= "$natural -1"


        self.find(:all,:order=>order_string, :limit=>options[:max_results]).each do |document|
          item = rss.items.new_item
          item.title = val(document, :rss_title,:title,:name)
          item.link = options[:item_link_template].call(document) if options[:item_link_template]
          item.link ||= val(document, :rss_link, :link, :url, :uri, :path) || ""
          rss_date = val(document, :rss_date, :updated_at)
          item.date = (Time.parse(rss_date).localtime if rss_date) || Time.now
          item.description = val(document, :rss_description, :description, :summary)
        end

      end


    feed.to_xml

    end

    private

    def val(target,*candidates)
      candidates.each do |candidate|
        if (target.respond_to? candidate)
          return target.send(candidate).to_s
        end
      end
      nil
    end
  end
end
     