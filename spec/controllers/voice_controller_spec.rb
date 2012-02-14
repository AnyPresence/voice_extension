require 'spec_helper'

describe VoiceController do
  def generate_secure_parameters
    timestamp = Time.now.to_i
    app_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") } 
  end
  
  describe "setup" do
    before(:each) do
      @account = Factory.build(:account)
    end
    
    describe 'provision' do
      it "should update old account that exists already" do
        @account0 = Factory.create(:account)
        sign_in @account0
        Account.where(:application_id => @account0.application_id).size.should == 1
        
        secure_parameters = generate_secure_parameters
        
        post :provision, :application_id => @account0.application_id, :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true
        
        Account.all.size.should == 1
      end
      
      it "should login successfully" do
        secure_parameters = generate_secure_parameters
        
        post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true    
      end
      
      it "should login unsuccessfully with different application_id" do
        secure_parameters = generate_secure_parameters
        
        app_id = secure_parameters[:application_id].to_i + 1;
        app_id = app_id.to_s
        
        post :provision, :application_id => app_id, :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == false 
      end
      
      it "should know to save the current api version information" do
        secure_parameters = generate_secure_parameters
        
        request.env['X_AP_API_VERSION'] = "v1"
        post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true
        Account.first.api_version.should == "v1"
      end
    end
    

    describe "deprovision" do 
    end

    describe "consume voice" do
    end
  end


end
