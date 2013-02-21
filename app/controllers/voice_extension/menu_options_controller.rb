require_dependency "voice_extension/application_controller"

module VoiceExtension
  class MenuOptionsController < ApplicationController
    before_filter :authenticate_admin!
    before_filter :get_page, only: [:edit, :update, :new, :create]
    before_filter :get_main_app_models, only: [:edit, :new]
    
    def index
      @menu_options = VoiceExtension::MenuOption.all
      
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @menu_options }
      end
    end
    
    def edit
      @menu_option = VoiceExtension::MenuOption.find(params[:id])
      @pages = VoiceExtension::Page.all
    end
    
    def update
      @menu_option = VoiceExtension::MenuOption.find(params[:id])
      @pages = VoiceExtension::Page.all
      
      respond_to do |format|
        if @menu_option.update_attributes(params[:menu_option])
          if !params[:forward_page_transition].blank?
            forward_page_transition = VoiceExtension::Page.find(params[:forward_page_transition])
            @menu_option.update_attributes(forward_page: forward_page_transition) if !forward_page_transition.blank? && @menu_option.forward_page != forward_page_transition
          end
          format.html { redirect_to page_path(@page), notice: 'Menu Option was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @menu_option.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def show
      @menu_option = VoiceExtension::MenuOption.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @menu_option }
      end
    end
    
    def new
      @menu_option = VoiceExtension::MenuOption.new
      @pages = VoiceExtension::Page.all
      
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @menu_option }
      end
    end
    
    def create
      @menu_option = VoiceExtension::MenuOption.new(params[:menu_option])      
      @page.menu_options << @menu_option
      
      respond_to do |format|
        if @menu_option.save
          format.html { redirect_to page_path(@page), notice: 'Menu Option was successfully created.' }
          format.json { render json: @menu_option, status: :created, location: @menu_option }
        else
          format.html { render action: "new" }
          format.json { render json: @menu_option.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def destroy
      @menu_option = VoiceExtension::MenuOption.find(params[:id])
      @menu_option.destroy

      respond_to do |format|
        format.html { redirect_to menu_options_url }
        format.json { head :no_content }
      end
    end
    
  protected
    def get_page
      @page = VoiceExtension::Page.find(params[:page_id])
    end
    
    def get_main_app_models
      @available_object_definitions = "#{::AP::VoiceExtension::Voice::Config.instance.latest_version.upcase}".constantize.constants
      if @available_object_definitions.blank?
        version = ::AP::VoiceExtension::Voice::Config.instance.latest_version
        Dir.glob(Rails.root.join("app", "models", version, "*.rb")).each do |f|
          "::#{version.upcase}::#{File.basename(f, '.*').camelize}".constantize.name 
        end

        @available_object_definitions = "#{::AP::VoiceExtension::Voice::Config.instance.latest_version.upcase}".constantize.constants
      end
      @available_object_definitions.delete(:Custom)
    end
  end
end
