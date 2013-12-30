require 'active_ldap'

module LDAP
  def connect(bind_dn, password)
    ActiveLdap::Base.setup_connection( {
      :host => LDAP_HOST,
      :port => LDAP_PORT,
      :base => LDAP_BASE,
      :method => :ssl,
      :bind_dn => bind_dn,
      :password => password})
    begin
      raise ConnectionError, "Could not connect to the LDAP server at %s:%s " % [LDAP_HOST, LDAP_PORT] unless ActiveLdap::Base.search({:base=>LDAP_BASE, :filter=>"(cn=test connection)"}).is_a? Array
      return ActiveLdap::Base
    rescue => error
      return nil
    end
  end
end
