require 'rubygems'
require 'net/ldap'

LDAP_YAML = File.join(File.dirname(__FILE__),'..','..','ldap.yaml')
LDAP_ENABLED = File.exist? LDAP_YAML

#
# Implementing as a single method for simplicity
#
def ldap_auth(username, pass)
  confs = YAML.load(File.open(LDAP_YAML))
  conf = confs[ENV['RAILS_ENV']].symbolize_keys
  #strip old email
  username = username[/[^@]+/] + "@" + conf[:base_domain]
  ldap = Net::LDAP.new :host => conf[:host],
    :auth => {
      :method => conf[:method]
    }
  ldap.auth username, pass
  ldap.bind
end
