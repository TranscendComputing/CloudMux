__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__)))

$LOAD_PATH.unshift __LIB_DIR__ unless
  $LOAD_PATH.include?(__LIB_DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__LIB_DIR__))

module Core
  unless const_defined?(:VERSION)
    VERSION = '1.0'
  end
end

# external gem dependencies

# internal libraries
require 'core/ext/string_ext'
