require 'app_spec_helper'

require File.join(File.dirname(__FILE__), '..', '..', 'app', 'category_api_app')

include HttpStatusCodes

describe CategoryApiApp do
  def app
    CategoryApiApp
  end

  after :each do
    # this test uses the db storage for uniqueness testing, so need to clean between runs
    DatabaseCleaner.clean
  end

  describe "GET /" do
    before :each do
      @account = FactoryGirl.create(:account)
      @category = FactoryGirl.create(:category)
      FactoryGirl.create_list(:category, 30)
      @total = Category.count
    end

    describe "defaults" do
      before :each do
        get "/"
      end

      it "should return a success response code" do
        last_response.status.should eq(OK)
      end

      it "should return all results by default" do
        @category_query = CategoryQuery.new
        @category_query.extend(CategoryQueryRepresenter)
        @category_query.from_json(last_response.body)
        @category_query.query.should_not eq(nil)
        @category_query.categories.length.should eq(@total)
        @category_query.query.offset.should eq(0)
        @category_query.query.total.should eq(@total)
        @category_query.query.page.should eq(1)
      end
    end
  end

  describe "GET /:id.json" do
    before :each do
      @category = FactoryGirl.create(:category)
      get "/#{@category.id}.json"
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid JSON payload" do
      category = Category.new.extend(CategoryRepresenter)
      category.from_json(last_response.body)
      category.id.should eq(@category.id)
      category.name.should eq(@category.name)
      category.description.should eq(@category.description)
    end

    it "should return 404 if not found" do
      get "/#{@category.id}notfound.json"
      last_response.status.should eq(NOT_FOUND)
    end
  end

  describe "POST /" do
    before :each do
      @create_category = FactoryGirl.build(:category).extend(UpdateCategoryRepresenter)
      post "/", @create_category.to_json
    end

    it "should return a success response code" do
      last_response.status.should eq(CREATED)
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid category payload" do
      new_category = Category.new.extend(CategoryRepresenter)
      new_category.from_json(last_response.body)
      new_category.id.should_not eq(nil)
      new_category.name.should eq(@create_category.name)
    end

    it "should return the proper content type if data is missing" do
      @create_category = FactoryGirl.build(:category, :name=>nil).extend(UpdateCategoryRepresenter)
      post "/", @create_category.to_json
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a bad request status if data is missing" do
      @create_category = FactoryGirl.build(:category, :name=>nil).extend(UpdateCategoryRepresenter)
      post "/", @create_category.to_json
      last_response.status.should eq(BAD_REQUEST)
    end

    it "should return a message if data is missing" do
      @create_category = FactoryGirl.build(:category, :name=>nil).extend(UpdateCategoryRepresenter)
      post "/", @create_category.to_json
      expected_json = "{\"error\":{\"message\":\"Name can't be blank\",\"validation_errors\":{\"name\":[\"can't be blank\"]}}}"
      last_response.body.should eq(expected_json)
    end
  end

  describe "PUT /:id" do
    before :each do
      @category = FactoryGirl.create(:category).extend(UpdateCategoryRepresenter)
      @category.name = "#{@category.name}_new"
      put "/#{@category.id}", @category.to_json
    end

    it "should return a success response code" do
      last_response.should be_ok
    end

    it "should return the proper content type" do
      last_response.headers["Content-Type"].should eq(JSON_CONTENT)
    end

    it "should return a valid payload with updated fields" do
      updated_category = Category.new.extend(CategoryRepresenter)
      updated_category.from_json(last_response.body)
      updated_category.name.should eq(@category.name)
      updated_category.description.should eq(@category.description)
    end
  end
end
