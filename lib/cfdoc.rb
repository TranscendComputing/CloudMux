__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), '..'))

$LOAD_PATH.unshift __LIB_DIR__ unless
  $LOAD_PATH.include?(__LIB_DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__LIB_DIR__))

module CFDoc

  unless const_defined?(:VERSION)
    VERSION = '1.0'
  end

end

# external core dependencies
require 'json'
require 'uri'
require 'erubis'

# internal core dependencies
require 'core'
require 'cfdoc/model/stack_template'
require 'cfdoc/model/element'
require 'cfdoc/model/list'
require 'cfdoc/model/function'
require 'cfdoc/model/mapping_set'
require 'cfdoc/model/mapping'
require 'cfdoc/model/property'
require 'cfdoc/model/property_support'
require 'cfdoc/model/description_support'
require 'cfdoc/model/vendor_support'
require 'cfdoc/model/stack'
require 'cfdoc/model/parameter'
require 'cfdoc/model/resource_support'
require 'cfdoc/model/resource'
require 'cfdoc/model/output'
require 'cfdoc/model/ref'
require 'cfdoc/model/code_block'
require 'cfdoc/model/user_data'
require 'cfdoc/model/metadata'
require 'cfdoc/model/description'
require 'cfdoc/model/vendor'
require 'cfdoc/model/platform'
require 'cfdoc/parser/cf_parser'
require 'cfdoc/presenter/base'
require 'cfdoc/presenter/stack_template_presenter'

