require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Retrieve", :type => :controller do
  controller_name "resource_full_mock_users"
  
  before :each do
    ResourceFullMockUser.delete_all
    ResourceFullMockUsersController.resource_identifier = :id
    ResourceFullMockUsersController.queryable_params = []
  end
  
  it "defines custom methods based on the class name" do
    controller.should respond_to(
      :find_resource_full_mock_user, 
      :find_all_resource_full_mock_users, 
      :update_resource_full_mock_user, 
      :destroy_resource_full_mock_user, 
      :new_resource_full_mock_user
    )
  end
  
  it "changes the custom methods if the model name is changed" do
    controller.class.exposes ResourceFullMock
    controller.should respond_to(:find_resource_full_mock)
    controller.should_not respond_to(:find_resource_full_mock_user)
    controller.class.exposes ResourceFullMockUser # cleanup
  end
  
  def params; @params ||= {}; end
  
  it "finds the requested model object" do
    user = ResourceFullMockUser.create!
    get :show, :id => user.id
    assigns(:resource_full_mock_user).should == user
  end
  
  it "finds the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    ResourceFullMockUsersController.resource_identifier = :first_name
    ResourceFullMockUser.create! :first_name => "eustace"
    get :show, :id => "eustace"
    assigns(:resource_full_mock_user).first_name.should == "eustace"
  end
  
  it "updates the requested model object based on the given parameters" do
    user = ResourceFullMockUser.create! :last_name => "threepwood"
    post :update, :id => user.id, :resource_full_mock_user => { :last_name => "guybrush" }
    user.reload.last_name.should == "guybrush"
  end
  
  it "updates the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    ResourceFullMockUsersController.resource_identifier = :first_name
    user = ResourceFullMockUser.create! :first_name => "guybrush"
    post :update, :id => "guybrush", :resource_full_mock_user => { :last_name => "threepwood" }
    user.reload.last_name.should == "threepwood"
  end
  
  it "creates a new model object based on the given parameters" do
    put :create, :resource_full_mock_user => { :first_name => "guybrush", :last_name => "threepwood" }
    ResourceFullMockUser.count.should == 1
    ResourceFullMockUser.find(:first).first_name.should == "guybrush"
  end
  
  it "creates a new model object appropriately if a creational parameter is queryable but not placed in the model object params, as with a nested route" do
    ResourceFullMockUsersController.queryable_with :first_name
    put :create, :first_name => "guybrush", :resource_full_mock_user => { :last_name => "threepwood" }
    ResourceFullMockUser.count.should == 1
    user = ResourceFullMockUser.find :first
    user.first_name.should == "guybrush"
    user.last_name.should == "threepwood"
  end
  
  it "deletes the requested model object" do
    user = ResourceFullMockUser.create!
    delete :destroy, :id => user.id
    ResourceFullMockUser.exists?(user.id).should be_false
  end
  
  it "deletes the requested model object using the correct column if the resource_identifier attribute has been overridden" do
    ResourceFullMockUsersController.resource_identifier = :first_name
    user = ResourceFullMockUser.create! :first_name => "guybrush"
    delete :destroy, :id => "guybrush"
    ResourceFullMockUser.exists?(user.id).should be_false
  end
  
  describe "with pagination" do
    controller_name "resource_full_mock_users"
    
    before :each do
      ResourceFullMockUser.delete_all
      @users = (1..6).collect { ResourceFullMockUser.create! }
    end
    
    after :all do
      ResourceFullMockUser.delete_all
    end
    
    it "limits the query to the correct number of records given that parameter" do
      get :index, :limit => 2
      assigns(:resource_full_mock_users).should == @users[0..1]
    end
    
    it "offsets the query by the correct number of records" do
      get :index, :offset => 4, :limit => 2
      assigns(:resource_full_mock_users).should == @users[4..5]
    end
    
    it "doesn't attempt to paginate if pagination is disabled" do
      ResourceFullMockUsersController.paginatable = false
      get :index, :offset => 4, :limit => 2
      assigns(:resource_full_mock_users).should == @users
      ResourceFullMockUsersController.paginatable = true # cleanup
    end
  end
  
end