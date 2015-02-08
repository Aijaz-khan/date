class SearchesController < ApplicationController
  

  def new
    @search = Search.new
    render layout: 'new_application'
  end

  def create
    @search = Search.new(params[:search])
    if @search.save
        redirect_to @search
    else
      render 'new'
    end
  end

  def show
    @user = current_user
    @search = Search.find(params[:id])
    @users = @search.users
    render 'users/index', layout: 'new_application'    
  end

  def update
    @search = Search.find(params[:id])
    if @search.update_attributes(params[:search])
        redirect_to @search
    else
      render 'new'
    end
  end
  
  def index
    @search = Search.new
    
    if params[:gender].present? and params[:search].nil?
        conditions = {}
        range_cond = {}
          if params["sexuality"].present?
            sexuality = {"Gay" => "Male", "Bisexual" => "Female"}
            straight = {"Male" => "Female", "Female" => "Male"}
            sexuality["Straight"] = straight[params["gender"].strip] 
			conditions[:sexuality] = sexuality[params["sexuality"]]
		  end
          conditions[:gender] = params["gender"].strip if params["gender"].present?
          conditions[:ethnicity] = params["ethnicity"] if params["ethnicity"].present?
          conditions[:zip_code] = params["zip_code"] if params["zip_code"].present?
          conditions[:religion] = params["religion"] if params["religion"].present?
          range_cond[:age] = if params["min_age"].present? and params["max_age"].present?
									params["min_age"].to_i..params["max_age"].to_i 
							 elsif params["min_age"].present?
									params["min_age"].to_i..65
							 elsif params["max_age"].present?
									18..params["max_age"].to_i
							 end
          conditions[:children] = params["children"] if params["children"].present?
		  @users = User.search(:conditions => conditions, :with => range_cond)
    else                    
          params[:search] = params[:search] || ''
           @users = User.search(params[:search].gsub(/\s+/, ' | '),
            :geo => [current_user.latitude * Math::PI / 180.0, current_user.longitude * Math::PI / 180.0],
            :with  => {:geodist => 0.0..100_000.0},
            :order => 'geodist ASC', :without => {:user_id => current_user.id})
                        
                   
        end      
        render 'users/index', layout: 'new_application'    
        
      end
  def min_age
    @min_age = params[:min_age].to_i.years
  end
  
  def max_age
    @max_age = params[:max_age].to_i.years
  end
  
  def youngest_age
  @youngest_age = params[:youngest_age].years
  end

  def oldest_age
  @oldest_age = params[:oldest_age].years
   end
   
end