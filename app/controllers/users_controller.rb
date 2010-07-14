require "RMagick"

class UsersController < BaseController
  include Viewable
  
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required, :only => [:new, :create, :activate]
    #before_filter :require_invitation, :only => [:new, :create]
    
    #def require_invitation
    #  redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
    #  redirect_to home_path and return false unless User.find(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
    #end
  end    
  
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:create, :update, :edit, :welcome_about])
  #uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])
  
  # Filters
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about, 
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate, 
                                          :crop_profile_photo, :upload_profile_photo]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics, :deactivate, 
                                      :crop_profile_photo, :upload_profile_photo ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :deactivate, 
                                                :crop_profile_photo, :upload_profile_photo]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_filter :admin_or_current_user_required, :only => [:statistics]  
  
  
#  def show_favorites
#    @favorites = Favorite.find(:conditions => ['favoritable_id = ?', current_user.id])
#    
#    @favorites.each do |favorite|
#      if favorite.favoritable_type == 'Course'
#        @courses_id << favorite.favoritable_id
#      else if favorite.favoritable_type == 'Exam'
#        @exams_id << favorite.favoritable_id
#      end
#    end
#    
#    @courses_id.each do |course_id|
#      @courses << Course.find(:conditions => ['id = ?', course_id])
#    end  
#    
#    
#    @exams_id.each do |exam_id|
#      @exams << Exam.find(:conditions => ['id = ?', exam_id])
#    end  
#    return @favorites
#  end
  
  def show_log_activity
    current_user.log_activity 
  end
  
  def show_favorites
    #current_user.get_favorites
  end
 
  
  ### Followship
  def can_follow
    user_id = params[:id]
    follow_id = params[:follow_id]
  end
  
  def follows
    @user = User.find(params[:id])
    @follows= @user.follows
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @follows }
    end
  end
  
  def followers
    @user = User.find(params[:id])
    @followers= @user.followers
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @followers }
    end
  end
  
  
  def follow # TODO evitar duplicata
    user = User.find(params[:id])
    #@follow_user = User.find(params[:follow_id])
    
    user.followers << current_user
    if user.save #@user.update_attributes(:follows)
    	UserNotifier.deliver_followship_notice(user, current_user)
      flash[:notice] = 'Você está seguindo esse usuário'
    else
      flash[:erro] = 'Não é possível seguir esse usuário'
    end
    redirect_to user_path(user)
    
  end 
  
  def unfollow
    user = User.find(params[:id])
    #@follow_user = User.find(params[:follow_id])
    
    user.followers.delete current_user
    if user.save #@user.update_attributes(:follows)
      flash[:notice] = 'Você não está mais seguindo esse usuário'
    else
      flash[:erro] = 'Não foi possível parar de seguir esse usuário'
    end
    redirect_to user_path(user)
    
  end
  
  
  def list_subjects
    @subjects = Subject.all
    @user = params[:id]
  end
  
  def logs
    
  end
  
  
  ##Associação com a disciplina
  #  def add_subject
  #    
  #    #@user = User.find(params[:id])
  #    @user = current_user
  #    
  #    @subject = Subject.find(params[:subject][:id])
  #    puts 'Teste'
  #    puts params[:user_key]
  #    
  #    @user_subject_association = UserSubjectAssociation.find(:first, :include => :access_key, :conditions => ["access_keys.key = ?", params[:user_key]])  
  #    
  #    if @user_subject_association
  #      if @user_subject_association.access_key.expiration_date.to_time < Time.now # verifica a data da validade da chave  
  #        if @subject &&  @user_subject_association.user == @user         
  #          if @user && !@user_subject_association.user # cada chave só poderá ser usada uma vez, sem troca de aluno                     
  #            @user_subject_association.user = @user        
  #            if @user_subject_association.save
  #              flash[:notice] = 'Usuário associado à disciplina!'
  #            else 
  #              flash[:notice] = 'Associação à disciplina falhou.'
  #            end
  #          else 
  #            flash[:notice] = 'Essa chave já está em uso.'
  #          end
  #      
  #        else
  #          flash[:notice] = 'Essa chave pertence à outra disciplina.'
  #        end
  #        
  #      else
  #        flash[:notice] = 'O prazo de validade desta chave ontate o administrador da sua escola.'
  #      end
  #      
  #      
  #    else
  #      flash[:notice] = 'Chave inválida'
  #    end
  #    
  #    
  #    respond_to do |format|
  #      format.html { redirect_to(@user) }
  #    end
  #    
  #  end
  
  
  ## User
  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id]) 
    if @user and @user.activate
      self.current_user = @user
      #current_user.track_activity(:joined_the_site)   Utilizaremos outro Activity    
      redirect_to welcome_photo_user_path(@user)
      flash[:notice] = :thanks_for_activating_your_account.l 
      return
    end
    flash[:error] = :account_activation_error.l_with_args(:email => AppConfig.support_email) 
    redirect_to signup_path     
  end
  
  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end
  
  def index
    cond, @search, @metro_areas, @states = User.paginated_users_conditions_with_search(params)    
    
    @users = User.recent.find(:all,
      :conditions => cond.to_sql, 
      :include => [:tags], 
      :page => {:current => params[:page], :size => 20}
    )
    
    @tags = User.tag_counts :limit => 10
    
    setup_metro_areas_for_cloud
  end
  
  def dashboard
    @user = current_user
    # @network_activity = @user.network_activity
    @recommended_posts = @user.recommended_posts
  end
  
  def show  
     if @user.removed
      redirect_to removed_page_path and return
    end
    
    @friend_count               = @user.accepted_friendships.count
    @accepted_friendships       = @user.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    @pending_friendships_count  = @user.pending_friendships.count()
    
    @comments       = @user.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    @photo_comments = Comment.find_photo_comments_for(@user)    
    @users_comments = Comment.find_comments_by_user(@user, :limit => 5)
    
    @recent_posts   = @user.posts.find(:all, :limit => 2, :order => "published_at DESC")
    @clippings      = @user.clippings.find(:all, :limit => 5)
    @photos         = @user.photos.find(:all, :limit => 5)
    @comment        = Comment.new(params[:comment])
    # @course         = Course.new(params[:])
    
    
    
    update_view_count(@user) unless current_user && current_user.eql?(@user)
  end
  
  def tos
    nil
  end
  
  def new
    @user         = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id   = params[:id]
    @inviter_code = params[:code]
    
    @beta_key = params[:beta_key]
    
    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode    
  end
  
  def create
    
    if AppConfig.closed_beta_mode
      if params[:beta_key]
        @key = BetaKey.find(:first, :conditions => ["beta_keys.key like ?", params[:beta_key]])
        if @key
          if @key.user
            flash[:error] = "Esta chave de acesso já está sendo usada por outro usuário."
            render :action => 'new' and return
          end
        else
          flash[:error] = "Chave de acesso inválida!"
          render :action => 'new' and return
        end
      else
        flash[:error] = "Chave de acesso inválida!"
        render :action => 'new' and return
      end
    end
    
    
    @user = User.new(params[:user])
   # @user.role  = Role[:member]
   
   user_id = @user.save
    
    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@user)) && user_id
      create_friendship_with_inviter(@user, params)
      
      if @key 
        @key.user = @user
        @key.save
      end
      
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email) 
      redirect_to signup_completed_user_path(@user)
    else
      render :action => 'new'
    end
    
  end
  
  def edit 
    @metro_areas, @states = setup_locations_for(@user)
    @skills               = Skill.find(:all)
    @offering             = Offering.new
    @avatar               = Photo.new
  end
  
  def update
    @user.attributes      = params[:user]
    @metro_areas, @states = setup_locations_for(@user)
    
    unless params[:metro_area_id].blank?
      @user.metro_area  = MetroArea.find(params[:metro_area_id])
      @user.state       = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country     = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = @user.state = @user.country = nil
    end
    
    @avatar       = Photo.new(params[:avatar])
    @avatar.user  = @user
    
    @user.avatar  = @avatar if @avatar.save
    
    @user.tag_list = params[:tag_list] || ''
    
    if @user.save!
      #@user.track_activity(:updated_profile) Utilizaremos outro Activity
      Log.log_activity(@user, 'update', nil)
      
      flash[:notice] = :your_changes_were_saved.l
      unless params[:welcome] 
        redirect_to user_path(@user)
      else
        redirect_to :action => "welcome_#{params[:welcome]}", :id => @user
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  def destroy
    unless @user.admin? || @user.featured_writer?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def change_profile_photo
    @user   = User.find(params[:id])
    @photo  = Photo.find(params[:photo_id])
    @user.avatar = @photo
    
    if @user.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    @metro_areas, @states = setup_locations_for(@user)
    render :action => 'edit'
  end
  
  def crop_profile_photo    
    unless @photo = @user.avatar   
      flash[:notice] = :no_profile_photo.l
      redirect_to upload_profile_photo_user_path(@user) and return
    end
    return unless request.put?
    
    if @photo
      if params[:x1]
        img = Magick::Image::read(@photo.path_or_s3_url_for_image).first.crop(params[:x1].to_i, params[:y1].to_i,params[:width].to_i, params[:height].to_i, true)
        img.format = @photo.content_type.split('/').last
        crop = {'tempfile' => StringIO.new(img.to_blob), 'content_type' => @photo.content_type, 'filename' => "custom_#{@photo.filename}"}
        @photo.uploaded_data = crop
        @photo.save!
      end
    end
    
    redirect_to user_path(@user)
  end
  
  def upload_profile_photo
    @avatar       = Photo.new(params[:avatar])
    return unless request.put?
    
    @avatar.user  = @user
    if @avatar.save
      @user.avatar  = @avatar 
      @user.save
      redirect_to crop_profile_photo_user_path(@user)
    end
  end
  
  def edit_account
    @user             = current_user
    @is_current_user  = true
  end
  
  def update_account
    @user             = current_user
    @user.attributes  = params[:user]
    
    if @user.save
      flash[:notice] = :your_changes_were_saved.l
      respond_to do |format|
        format.html {redirect_to user_path(@user)}
        format.js
      end      
    else
      respond_to do |format|
        format.html {render :action => 'edit_account'}
        format.js
      end
    end
  end
  
  def edit_pro_details
    @user = User.find(params[:id])
  end
  
  def update_pro_details
    @user = User.find(params[:id])
    @user.add_offerings(params[:offerings]) if params[:offerings]
    
    @user.attributes = params[:user]
    
    if @user.save!
      respond_to do |format|
        format.html { 
          flash[:notice] = :your_changes_were_saved.l
          redirect_to edit_pro_details_user_path(@user)   
        }
        format.js {
          render :text => 'success'
        }
      end
      
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_pro_details'
  end
  
  def create_friendship_with_inviter(user, options = {})
    unless options[:inviter_code].blank? or options[:inviter_id].blank?
      friend = User.find(options[:inviter_id])
      
      if friend && friend.valid_invite_code?(options[:inviter_code])
      	# add as follower and following
      	friend.followers << user
      	friend.save!
      	
      	user.followers << friend 
      	user.save!
=begin
        accepted    = FriendshipStatus[:accepted]
        @friendship = Friendship.new(:user_id => friend.id, 
          :friend_id => user.id,
          :friendship_status => accepted, 
          :initiator => true)
        
        reverse_friendship = Friendship.new(:user_id => user.id, 
          :friend_id => friend.id, 
          :friendship_status => accepted ) 
        
        @friendship.save
        reverse_friendship.save
=end
      end
    end
  end
  
  def signup_completed
    
    @user = User.find(params[:id])
    redirect_to home_path and return unless @user
    render :action => 'signup_completed', :layout => 'beta' if AppConfig.closed_beta_mode    
  
  end
  
  def welcome_photo
    @user = User.find(params[:id])
  end
  
  def welcome_about
    @user = User.find(params[:id])
    @metro_areas, @states = setup_locations_for(@user)
  end
  
  def welcome_invite
    @user = User.find(params[:id])    
  end
  
  def invite
    @user = User.find(params[:id])    
  end
  
  def welcome_complete
    flash[:notice] = :walkthrough_complete.l_with_args(:site => AppConfig.community_name) 
    redirect_to user_path
  end
  
  def forgot_password  
    return unless request.post?   
    
    @user = User.active.find_by_email(params[:email])  
    if @user && @user.reset_password
      UserNotifier.deliver_reset_password(@user)
      @user.save
      redirect_to login_url
      flash[:info] = :your_password_has_been_reset_and_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end
  
  def forgot_username  
    return unless request.post?   
    
    if @user = User.active.find_by_email(params[:email])
      UserNotifier.deliver_forgot_username(@user)
      redirect_to login_url
      flash[:info] = :your_username_was_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end
  
  def resend_activation
    return unless request.post?       
    
    if params[:email]
      @user = User.find_by_email(params[:email])    
    else
      @user = User.find(params[:id])
    end
    
    if @user && !@user.active?
      flash[:notice] = :activation_email_resent_message.l
      UserNotifier.deliver_signup_notification(@user)    
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
      if AppConfig.closed_beta_mode
        render :layout => 'beta'
      end  
      
    end
  end
  
  def assume
    self.current_user = User.find(params[:id])
    redirect_to user_path(current_user)
  end
  
  def return_admin
    unless session[:admin_id].nil? or current_user.admin?
      admin = User.find(session[:admin_id])
      if admin.admin?
        self.current_user = admin
        redirect_to user_path(admin)
      end
    else
      redirect_to login_path
    end
  end
  
  def metro_area_update
    
    country = Country.find(params[:country_id]) unless params[:country_id].blank?
    state   = State.find(params[:state_id]) unless params[:state_id].blank?
    states  = country ? country.states.sort_by{|s| s.name} : []
    
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end
    
    respond_to do |format|
      format.js {
        render :partial => 'shared/location_chooser', :locals => {
          :states => states, 
          :metro_areas => metro_areas, 
          :selected_country => params[:country_id].to_i, 
          :selected_state => params[:state_id].to_i, 
          :selected_metro_area => nil }        
      }
    end
  end
  
  def toggle_featured
    @user = User.find(params[:id])
    @user.toggle!(:featured_writer)
    redirect_to user_path(@user)
  end
  
  def toggle_moderator
    @user = User.find(params[:id])
    @user.role = @user.moderator? ? Role[:member] : Role[:moderator]
    @user.save!
    redirect_to user_path(@user)
  end
  
  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Date.today    
    end
    
    start_date  = @month.beginning_of_month
    end_date    = @month.end_of_month + 1.day
    
    @posts = @user.posts.find(:all, 
      :conditions => ['? <= published_at AND published_at <= ?', start_date, end_date])    
    
    @estimated_payment = @posts.sum do |p| 
      7
    end
  end
  
  def activity_xml
    
    # talvez seja necessario setar o atributo depth nos nós para que funcione corretamente.
    # ver: http://asterisq.com/products/constellation/roamer/integration#data_rest_tree
    
    puts "id: " + params[:id]
    puts "node_id: " + params[:node_id] if params[:node_id]
    
    #@logs = Log.find(:all, 
    #:conditions => ["user_id != logeable_id AND logeable_type NOT LIKE 'User'"])
    @user = User.find((params[:node_id]) ?  params[:node_id] :  params[:id] )
    @logs = @user.log_activity
    
    respond_to do |format|
      format.xml
    end
  end
  
  
  
  protected  
  def setup_metro_areas_for_cloud
    @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
    @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  end  
  
  def setup_locations_for(user)
    metro_areas = states = []
    
    states = user.country.states if user.country
    
    metro_areas = user.state.metro_areas.all(:order => "name") if user.state
    
    return metro_areas, states
  end
  
  def admin_or_current_user_required
    current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
  end
  
end
