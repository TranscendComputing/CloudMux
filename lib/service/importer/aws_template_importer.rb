require 'nokogiri'
require 'uri'
require 'open-uri'

class AwsTemplateImporter
  def import(account)
    # this html is really bad, so we'll brute force this by iterating through the heading tags, then finding the links under it that reference templates stored on s3
    doc = Nokogiri::HTML(fetch_page)
    headings = doc.xpath('//h2')
    headings.each do |heading_node|
      heading = heading_node.content
      log "Processing heading: #{heading}"
      if heading == "Recently added samples" or heading == "Template Features" or heading == "Compute Cluster" or heading == "Getting Started" or heading == "Templates for Whitepapers"
        # sample code category
        cat = Category.find(:first, :conditions=>{ :name=>"Sample Code"})
      elsif heading == "Open Source Applications"
        # application category
        cat = Category.find(:first, :conditions=>{ :name=>"Application"})
      elsif heading == "Application Framework Examples"
        # platform category
        cat = Category.find(:first, :conditions=>{ :name=>"Platform"})
      else
        log " skipping - category not found"
        next
      end
      table_node = heading_node.xpath('./following-sibling::table')[0]
      if table_node.nil? # not found, skip
        next
      end
      links = table_node.xpath("tr/td/a[substring(@href,1,10)='https://s3']")
      links = table_node.xpath("tr/td/table/tr/td/a[substring(@href,1,10)='https://s3']") if links.nil? or links.empty?
      links.each do |link|
        url = link['href']
        name = name_from_url(url)
        description = link.content
        log " importing #{name} into category #{cat.name}"
        import_stack(account, cat, url, name, description)
        # log "  link=#{link.to_s[0..75]}"
      end
    end
  end

  def import_stack(account, cat, url, name, description)
    begin
      template_content = open(url).read
      stack = Stack.create!(
                            :name=>name,
                            :description=>description,
                            :public=>true,
                            :category=>cat,
                            :account=>account
                            )
      template = Template.create!(
                                  :import_source=>url,
                                  :name=>name,
                                  :template_type=>Template::CLOUD_FORMATION,
                                  :raw_json=>template_content,
                                  :stack=>stack)
      stack.update_resource_groups!
    rescue => e
      log " skipping - failed to open or save: #{e}\n#{e.backtrace.join("\n")}"
    end
  end

  def name_from_url(url)
    uri = URI(url)
    uri.path.split('/').last.gsub(/\.template/,'').gsub(/-/,' ').gsub(/_/,' ').gsub(/\+/,' ')
    # name = name.humanize unless cat.name == "Application" # allow WordPress to stay the same but humanize application names
  end

  def fetch_page(url='http://aws.amazon.com/cloudformation/aws-cloudformation-templates/')
    open(url).read
  end

  def log(message)
    puts message unless ENV["RACK_ENV"] == "test"
  end
end
