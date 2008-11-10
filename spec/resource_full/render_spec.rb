require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Render", :type => :controller do
  controller_name "resource_full_mock_users"
  
  describe "XML" do
    controller_name "resource_full_mock_users"
    
    before :each do
      ResourceFullMockUser.skip_validation = true
      ResourceFullMockUser.delete_all
      ResourceFullMockUsersController.resource_identifier = :id
    end
  
    it "renders the model object" do
      user = ResourceFullMockUser.create!
      get :show, :id => user.id, :format => 'xml'
      response.body.should have_tag("resource-full-mock-user")
      response.code.should == '200'
    end
    
    it "renders the appropriate error message if it can't find the model object" do
      get :show, :id => 1, :format => 'xml'
      response.body.should have_tag("errors") { with_tag("error", "ActiveRecord::RecordNotFound: not found: 1") }
      response.code.should == '404'
    end
    
    it "renders all model objects" do
      2.times { ResourceFullMockUser.create! }
      get :index, :format => 'xml'
      Hash.from_xml(response.body)['resource_full_mock_users'].size.should == 2
      response.code.should == '200'
    end
    
    it "creates and renders a new model object with an empty body" do
      put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'xml'
      response.body.should == ResourceFullMockUser.find(:first).to_xml
      ResourceFullMockUser.find(:first).first_name.should == 'brian'
    end
    
    it "creates a new model object and returns a status code of 201 (created)" do
      put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'xml'
      response.code.should == '201'
    end
    
    it "creates a new model object and places the location of the new object in the Location header" do
      put :create, :resource_full_mock_user => {}, :format => 'xml'
      response.headers['Location'].should == resource_full_mock_user_url(ResourceFullMockUser.find(:first))
    end
    
    it "renders appropriate errors if a model validation fails" do
      ResourceFullMockUser.validates_presence_of :first_name, :unless => :skip_validation?
      ResourceFullMockUser.skip_validation = false
      put :create, :resource_full_mock_user => {}, :format => 'xml'
      response.should have_tag("errors") { with_tag("error", "First name can't be blank")}
    end
    
    it "renders the XML for a new model object" do
      get :new, :format => 'xml'
      response.body.should == ResourceFullMockUser.new.to_xml
    end
    
    class SomeNonsenseException < Exception; end
    
    it "rescues all unhandled exceptions with an XML response" do
      ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"
      get :index, :format => 'xml'
      response.should have_tag("errors") { with_tag("error", "SomeNonsenseException: sparrow farts") }
    end
    
    it "retains the generic error 500 when re-rendering unhandled exceptions" do
      ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"
      get :index, :format => 'xml'
      response.code.should == '500'
    end
    
  end
end

