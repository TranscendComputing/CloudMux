class CreateStack
  include ActiveModel::Validations

  attr_accessor :name, :description, :support_details, :license_agreement, :image_name, :image_data, :public, :account_id, :template_id, :category_id

  validates_presence_of :name
  validates_presence_of :account_id
  validates_presence_of :category_id
  validate :account_must_exist, :if=> :account_id
  validate :template_must_exist, :if=> :template_id
  validate :template_must_be_unpublished, :if=> :template_id
  validate :category_must_exist, :if=> :category_id

  def to_stack
    stack = Stack.new
    stack.name = self.name
    stack.description = self.description
    stack.public = self.public || true # FIX-ME and TEST-ME
    stack.account = Account.find(self.account_id)
    stack.category = Category.find(self.category_id)
    stack
  end

  def account_must_exist
    begin
      account = Account.find(account_id)
      return true
    rescue Mongoid::Errors::DocumentNotFound
      errors.add(:account_id, "not found")
    rescue Moped::BSON::InvalidObjectId
      errors.add(:account_id, "invalid")
    end
    return false
  end

  def template_must_exist
    begin
      template = Template.find(template_id)
      return true
    rescue Mongoid::Errors::DocumentNotFound
      errors.add(:template_id, "not found")
    rescue Moped::BSON::InvalidObjectId
      errors.add(:template_id, "invalid")
    end
    return false
  end

  def template_must_be_unpublished
    begin
      template = Template.find(template_id)
      if template.published?
        errors.add(:template_id, "already associated to another stack")
        return false
      end
      return true
    rescue Mongoid::Errors::DocumentNotFound
    rescue Moped::BSON::InvalidObjectId
    end
    return false
  end

  def category_must_exist
    begin
      category = Category.find(category_id)
      return true
    rescue Mongoid::Errors::DocumentNotFound
      errors.add(:category_id, "not found")
    rescue Moped::BSON::InvalidObjectId
      errors.add(:category_id, "invalid")
    end
    return false
  end
end
