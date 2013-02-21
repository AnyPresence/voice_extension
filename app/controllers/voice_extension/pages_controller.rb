require_dependency "voice_extension/application_controller"

module VoiceExtension
  class PagesController < ApplicationController
    before_filter :authenticate_admin!
    
    def index
      @pages = VoiceExtension::Page.order_by("root DESC").all
    end
    
    def new
      @page = VoiceExtension::Page.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @page }
      end
    end
    
    def show
      @page = VoiceExtension::Page.find(params[:id])
      @menu_options = @page.menu_options.order_by("keyed_value ASC")
      
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @page }
      end
    end
    
    def edit
      @page = VoiceExtension::Page.find(params[:id])
      respond_to do |format|
        format.html # edit.html.erb
        format.json { render json: @page }
      end
    end
    
    def update
      @page = VoiceExtension::Page.find(params[:id])
      @page.root = params[:page][:root]
      if @page.root_changed? && @page.root
        # Only one page should be marked as root if this one is now root.
        VoiceExtension::Page.update_all(root: false)
      end
      
      respond_to do |format|
        if @page.update_attributes(params[:page])
          format.html { redirect_to pages_path, notice: 'Page was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def create
      @page = VoiceExtension::Page.new(params[:page])

      respond_to do |format|
        if @page.save
          format.html { redirect_to @page, notice: 'Page was successfully created.' }
          format.json { render json: @page, status: :created, location: @page }
        else
          format.html { render action: "new" }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def destroy
      @page = VoiceExtension::Page.find(params[:id])
      @page.destroy

      respond_to do |format|
        format.html { redirect_to pages_url }
        format.json { head :no_content }
      end
    end
    
  end
end
