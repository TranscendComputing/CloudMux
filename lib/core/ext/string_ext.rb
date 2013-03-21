class String
  def to_permalink
    str = self
    str = str.gsub(/[^-_\s\w]/, ' ').downcase.squeeze(' ').tr(' ','-').gsub(/-+$/,'')
  end

  def underscore
    word = self.to_s.dup
    word.gsub!(/::/, '_')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.tr!(" ", "_")
    word.downcase!
    word
  end
end
