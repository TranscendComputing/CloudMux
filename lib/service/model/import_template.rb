#
# Transient class that enables templates to be
# imported into the system, source included
#
class ImportTemplate
  CLOUD_FORMATION = "cloud_formation"
  FROM_FILE = 'file'
  FROM_URL = 'url'

  attr_accessor :name, :import_source, :json

  # base64 encode the json payload. Used for over-the-wire transmission of JSON payloads when creating a new template
  def json_base64
    return Base64.encode64(self.json) unless self.json.nil? or self.json.empty?
  end

  # base64 decode the given encoded json payload. Used for over-the-wire transmission of JSON payloads when creating a new template
  def json_base64=(encoded)
    self.json = Base64.decode64(encoded) unless encoded.nil? or encoded.empty?
  end
end
