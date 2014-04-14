require 'rubygems'
require 'net/ldap'

LDAP_YAML = File.join(File.dirname(__FILE__),'..','..','ldap.yaml')
LDAP_ENABLED = File.exist? LDAP_YAML

class LdapGateway
  def initialize
    confs = YAML.load(File.open(LDAP_YAML))
    conf = confs[ENV['RAILS_ENV']].symbolize_keys
    @base_domain = conf[:base_domain]
    @method = conf[:method]
    @host = conf[:host]
    @ldap = Net::LDAP.new :host => @host,
      :auth => {
        :method => @method
      }
  end

  def auth(username, pass)
    #strip old email
    username = username[/[^@]+/] + "@" + @base_domain
    @ldap.auth username, pass
    @ldap.bind
  end
end
