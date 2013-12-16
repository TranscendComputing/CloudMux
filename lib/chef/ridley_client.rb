require 'ridley'

module Chef
  class RidleyClient

    def initialize(url, client_name, key)
      @client = Ridley.new(server_url: url, client_name: client_name, client_key: key)
    end

    def download_cookbook(name, version='latest', dir=Dir.mktmpdir)
      @client.cookbook.download(name, version, dir)
    end

    def download_all_cookbooks(dir=Dir.mktmpdir)
      @client.cookbook.all.each do |name, versions|
        cookbook_dir = "#{dir}/#{name}"
        Dir.mkdir(cookbook_dir)
        download_cookbook(name, 'latest', cookbook_dir)
      end
    end

  end
end