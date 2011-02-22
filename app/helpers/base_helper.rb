require 'md5'

# Methods added to this helper will be available to all templates in the application.
module BaseHelper

  # Adiciona a classe ui-state-active se o path for o atual
  def selected_if_current_is(path)
    current_page?(path) ? "ui-state-active" : ""
  end

  # Cria lista não ordenada no formato da navegação do widget de abas (jquery UI)
  def tabs_navigation(*paths)
    lis = paths.collect do |item|
      name, path, options = item
      class_name = "ui-state-active" if current_page?(path)

      content_tag :li, :class => class_name do
        link_to name, path, options
      end
    end

    lis.join("\n")
  end

  # Cria markup das abas fake a partir de uma ou mais listas do tipo
  # [nome, path, options] (mesmo parâmetros passados para o link_to)
  def fake_tabs(*paths, &block)
    locals = {
      :navigation => tabs_navigation(*paths),
      :body => capture(&block)
    }

    concat(render(:partial => 'shared/new/fake_tabs', :locals => locals), block.binding)
  end

  def error_for(object, method = nil, options={})
    if method
      err = instance_variable_get("@#{object}").errors.on(method).to_sentence rescue instance_variable_get("@#{object}").errors.on(method)
    else
      err = @errors["#{object}"] rescue nil
    end
    options.merge!(:class=>'errorMessageField',:id=>"#{[object,method].compact.join('_')}-error",
    :style=> (err ? "#{options[:style]}":"#{options[:style]};display: none;"))
    content_tag("p", err || "", options )
  end

  # Inclui JS e CSS e aplica colopicker a tag com o ID especificado
  def apply_color_picker_to(target)
    render :partial => "base/color_picker", :locals => { :target => target }
  end

  # Opções de cores do colorpicker
  def color_picker_colors
    colors = [["#ffffff", "ffffff"],
              ["#ffccc9", "ffccc9"],
              ["#ffce93", "ffce93"],
              ["#fffc9e", "fffc9e"],
              ["#ffffc7", "ffffc7"],
              ["#9aff99", "9aff99"],
              ["#96fffb", "96fffb"],
              ["#cdffff", "cdffff"],
              ["#cbcefb", "cbcefb"],
              ["#cfcfcf", "cfcfcf"],
              ["#fd6864", "fd6864"],
              ["#fe996b", "fe996b"],
              ["#fffe65", "fffe65"],
              ["#fcff2f", "fcff2f"],
              ["#67fd9a", "67fd9a"],
              ["#38fff8", "38fff8"],
              ["#68fdff", "68fdff"],
              ["#9698ed", "9698ed"],
              ["#c0c0c0", "c0c0c0"],
              ["#fe0000", "fe0000"],
              ["#f8a102", "f8a102"],
              ["#ffcc67", "ffcc67"],
              ["#f8ff00", "f8ff00"],
              ["#34ff34", "34ff34"],
              ["#68cbd0", "68cbd0"],
              ["#34cdf9", "34cdf9"],
              ["#6665cd", "6665cd"],
              ["#9b9b9b", "9b9b9b"],
              ["#cb0000", "cb0000"],
              ["#f56b00", "f56b00"],
              ["#ffcb2f", "ffcb2f"],
              ["#ffc702", "ffc702"],
              ["#32cb00", "32cb00"],
              ["#00d2cb", "00d2cb"],
              ["#3166ff", "3166ff"],
              ["#6434fc", "6434fc"],
              ["#656565", "656565"],
              ["#9a0000", "9a0000"],
              ["#ce6301", "ce6301"],
              ["#cd9934", "cd9934"],
              ["#999903", "999903"],
              ["#009901", "009901"],
              ["#329a9d", "329a9d"],
              ["#3531ff", "3531ff"],
              ["#6200c9", "6200c9"],
              ["#343434", "343434"],
              ["#680100", "680100"],
              ["#963400", "963400"],
              ["#986536", "electe"],
              ["#646809", "646809"],
              ["#036400", "036400"],
              ["#34696d", "34696d"],
              ["#00009b", "00009b"],
              ["#303498", "303498"],
              ["#000000", "000000"],
              ["#330001", "330001"],
              ["#643403", "643403"],
              ["#663234", "663234"],
              ["#343300", "343300"],
              ["#013300", "013300"],
              ["#003532", "003532"],
              ["#010066", "010066"],
              ["#340096", "340096"]]
  end


    def simple_categories_i18n(f)
   # collection_select(:lecture, :simple_category, SimpleCategory.all, :id, :name)
	  categories_array = SimpleCategory.all.map { |cat| [category_i18n(cat.name), cat.id] }
		if params[:lecture]
			# To put a value in categories_array I have to subtract for 1 the params[:lecture][:simple_category_id],
			# because the include_blank add a extra field
			if params[:lecture][:simple_category_id]

				if params[:lecture][:simple_category_id].to_i > 0
					i = params[:lecture][:simple_category_id].to_i - 1
					f.select(:simple_category_id, options_for_select(categories_array, categories_array[i]), :include_blank => true)
				else
					f.select(:simple_category_id, options_for_select(categories_array), :include_blank => true)
				end
			else
				f.select(:simple_category_id, options_for_select(categories_array), :include_blank => true)
			end
		elsif params[:exam]
			if params[:exam][:simple_category_id]
				if params[:exam][:simple_category_id].to_i > 0
					i = params[:exam][:simple_category_id].to_i - 1
					f.select(:simple_category_id, options_for_select(categories_array, categories_array[i]), :include_blank => true)
				else
					f.select(:simple_category_id, options_for_select(categories_array), :include_blank => true)
				end
			else
				f.select(:simple_category_id, options_for_select(categories_array), :include_blank => true)
			end
		else
			f.select(:simple_category_id, options_for_select(categories_array), :include_blank => true)
		end

  end

  def category_i18n(category)
    category.downcase.gsub(' ','').gsub('/','_').to_sym.l
  end


  def type_class(resource)
#      case resource.attachment_content_type
#      when "application/vnd.ms-powerpoint" then 'ppt'
#      when "application/msword" then 'word'
#      when "application/vnd.openxmlformats-officedocument.wordprocessingml.document" then 'word'
#      when "application/rtf" then 'word'
#      when "text/plain" then 'text'
#      when "application/pdf" then 'pdf'
#      else ''
#      end
        icons = ['3gp', 'bat', 'bmp', 'doc', 'css', 'exe', 'gif', 'jpg', 'jpeg', 'jar','zip',
        'mp3', 'mp4', 'avi', 'mpeg', 'mov', 'm4p', 'ogg', 'png', 'psd', 'ppt', 'txt', 'swf', 'wmv', 'xls', 'xml', 'zip']

        file_ext = resource.attachment_file_name.split('.')[1] if resource.attachment_file_name.split('.').length > 0
        if file_ext and icons.include? file_ext
        'ext_'+ file_ext
        else
         'ext_txt'
      end
  end


  def activity_name(item)
    link_user = link_to item.user.display_name, user_path(item.user)
    type = item.logeable_type.underscore
      case type
        when 'user'
         @activity = "acabou de entrar no redu" if item.log_action == "login"
         @activity = "atualizou seu status para: <span style='font-weight: bold;'>\"" + item.logeable_name + "\"</span>" if item.log_action == "update"

        when 'lecture'
          lecture = item.logeable
          link_obj = link_to(item.logeable_name, space_subject_lecture_path(lecture.subject.space, lecture.subject, lecture))

          @activity = "está visualizando a aula " + link_obj if item.log_action == "show"
          @activity = "criou a aula " + link_obj if item.log_action == "create"
          @activity =  "adicionou a aula " + link_obj + " ao seus favoritos" if item.log_action == "favorite"

      when 'exam'
          exam = item.logeable
          link_obj = link_to(item.logeable_name, space_subject_exam_path(exam.subject.space, exam.subject, exam))

          @activity = "acabou de responder o exame " + link_obj if item.log_action == "results"
          @activity = "está respondendo ao exame " + link_obj if item.log_action == "answer"
          @activity =  "criou o exame " + link_obj if item.log_action == "create"
          @activity =  "adicionou o exame " + link_obj + " ao seus favoritos" if item.log_action == "favorite"
      when 'space'
          link_obj = link_to(item.logeable_name, space_path(item.logeable_id))

          @activity =  "criou a disciplina " + link_obj if item.log_action == "create"
          @activity =  "adicionou a disciplina " + link_obj + " ao seus favoritos" if item.log_action == "favorite"
      when 'subject'
          link_obj = link_to(item.logeable_name, space_subject_path(item.logeable.space, item.logeable))

          @activity =  "criou o módulo " + link_obj if item.log_action == "create"
      when 'topic'
          @topic = Topic.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, space_forum_topic_path(@topic.forum.space, @topic))

          @activity = "criou o tópico " + link_obj if item.log_action == 'create'
      when 'sb_post'
          @post = SbPost.find(item.logeable_id)
          link_obj = link_to(@post.topic.title, space_forum_topic_path(@post.topic.forum.space, @post.topic))

          @activity = "respondeu ao tópico " + link_obj if item.log_action == 'create'
      when 'event'
          @event = Event.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, polymorphic_path([@event.eventable, @event]))

          @activity =  "criou o evento " + link_obj if item.log_action == "create"
      when 'bulletin'
          @bulletin = Bulletin.find(item.logeable_id)
          link_obj = link_to(item.logeable_name, polymorphic_path([@bulletin.bulletinable, @bulletin]))

          @activity =  "criou a notícia " + link_obj if item.log_action == "create"
      when 'myfile'
        @space = item.statusable
        @myfile = item.logeable
        link_obj = link_to @myfile.attachment_file_name, download_space_folder_url(@space, @myfile)
        @activity =  "adicionou o arquivo #{link_obj} a disciplina #{link_to @space.name, @space}"
      else
          @activity = " atividade? "
      end
      @activity
  end

  def reload_flash
    #page.replace_html "flash_messages", :partial => "shared/messages"
    #page.replace_html :notice, flash[:notice]
    #flash.discard
  end

  def commentable_url(comment)
    if comment.commentable_type != "User"
      polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
    else
      user_url(comment.recipient)+"#comment_#{comment.id}"
    end
  end



  def forum_page?
    %w(forums topics sb_posts spaces).include?(@controller.controller_name)
  end

  def is_current_user_and_featured?(u)
     u && u.eql?(current_user) && u.featured_writer?
  end

  def resize_img(classname, width=90, height=135)
    "<style>
      .#{classname} {
        max-width: #{width}px;
      }
    </style>
    <script type=\"text/javascript\">
      //<![CDATA[
        Event.observe(window, 'load', function(){
          $$('img.#{classname}').each(function(image){
            CommunityEngine.resize_image(image, {max_width: #{width}, max_height:#{height}});
          });
        }, false);
      //]]>
    </script>"
  end

  def rounded(options={}, &content)
    options = {:class=>"box"}.merge(options)
    options[:class] = "box " << options[:class] if options[:class]!="box"

    str = '<div'
    options.collect {|key,val| str << " #{key}=\"#{val}\"" }
    str << '><div class="box_top"></div>'
    str << "\n"

    concat(str)
    yield(content)
    concat('<br class="clear" /><div class="box_bottom"></div></div>')
  end

  def block_to_partial(partial_name, html_options = {}, &block)
    concat(render(:partial => partial_name, :locals => {:body => capture(&block), :html_options => html_options}))
  end

  def box(html_options = {}, &block)
    block_to_partial('shared/box', html_options, &block)
  end

  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.count.to_i if t.count.to_i > max
      min = t.count.to_i if t.count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t.name, classes[(t.count.to_i - min) / divisor]
    }
  end

  def city_cloud(cities, classes)
    max, min = 0, 0
    cities.each { |c|
      max = c.users.size.to_i if c.users.size.to_i > max
      min = c.users.size.to_i if c.users.size.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    cities.each { |c|
      yield c, classes[(c.users.size.to_i - min) / divisor]
    }
  end

  def truncate_chars(text, length = 30, end_string = '...')
     return if text.blank?
     (text.length > length) ? text[0..length] + end_string  : text
  end

  def truncate_words(text, length = 30, end_string = '...')
    return if text.blank?
    words = strip_tags(text).split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def truncate_words_with_highlight(text, phrase)
    t = excerpt(text, phrase)
    highlight truncate_words(t, 18), phrase
  end

  def excerpt_with_jump(text, end_string = ' ...')
    return if text.blank?
    doc = Hpricot( text )
    paragraph = doc.at("p")
    if paragraph
      paragraph.to_html + end_string
    else
      truncate_words(text, 150, end_string)
    end
  end

  def page_title
    app_base = AppConfig.community_name
    tagline = " | #{AppConfig.community_tagline}"

    title = app_base
    case @controller.controller_name
      when 'base'
          title += tagline
                        when 'pages'
                          if @page and @page.title
                            title = @page.title + ' - ' + app_base + tagline
                          end
      when 'posts'
        if @post and @post.title
          title = @post.title + ' - ' + app_base + tagline
          title += (@post.tags.empty? ? '' : " - "+:keywords.l+": " + @post.tags[0...4].join(', ') )
          @canonical_url = user_post_url(@post.user, @post)
        end
      when 'users'
        if @user && !@user.new_record? && @user.login
          title = @user.login
          title += ' - ' + app_base + tagline
          @canonical_url = user_url(@user)
        else
          title = :showing_users.l+' - ' + app_base + tagline
        end
      when 'photos'
        if @user and @user.login
          title = @user.login + '\'s '+:photos.l+' - ' + app_base + tagline
        end
     # when 'clippings'
     #   if @user and @user.login
     #     title = @user.login + '\'s '+:clippings.l+' &raquo; ' + app_base + tagline
     #   end
      when 'tags'
        case @controller.action_name
          when 'show'
            title = @tags.map(&:name).join(', ') + ' '
            title += params[:type] ? params[:type].pluralize : :posts_photos_and_bookmarks.l
            title += ' (Related: ' + @related_tags.join(', ') + ')' if @related_tags
            title += ' | ' + app_base
            @canonical_url = tag_url(URI.escape(@tags_raw, /[\/.?#]/)) if @tags_raw
          else
          title = 'Showing tags - ' + app_base + tagline
        end
      when 'categories'
        if @category and @category.name
          title = @category.name + ' '+:posts_photos_and_bookmarks.l+' - ' + app_base + tagline
        else
          title = :showing_categories.l+' - ' + app_base + tagline
        end
      when 'lectures'
      if @lecture and @lecture.name
        title = 'Aula: ' + @lecture.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Aulas' +' - ' + app_base + tagline
      end
      when 'exams'
      if @exam and @exam.name
        title = 'Exame: ' + @exam.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Exames' +' - ' + app_base + tagline
      end
      when 'spaces'
      if @space and @space.name
        title = @space.name + ' - ' + app_base + tagline
      else
        title = 'Mostrando Disciplinas' +' - ' + app_base + tagline
      end
      when 'skills'
        if @skill and @skill.name
          title = :find_an_expert_in.l+' ' + @skill.name + ' - ' + app_base + tagline
        else
          title = :find_experts.l+' - ' + app_base + tagline
        end
      when 'sessions'
        title = :login.l+' - ' + app_base + tagline
    end

    if @page_title
      title = @page_title + ' - ' + app_base + tagline
    elsif title == app_base
      title = :showing.l+' ' + @controller.controller_name.capitalize + ' - ' + app_base + tagline
    end
    title.html_safe
  end

  def add_friend_link(user = nil)
    html = "<span class='friend_request' id='friend_request_#{user.id}'>"
    html += link_to_remote :request_friendship.l,
        {:update => "friend_request_#{user.id}",
          :loading => "$$('span#friend_request_#{user.id} span.spinner')[0].show(); $$('span#friend_request_#{user.id} a.add_friend_btn')[0].hide()",
          :complete => visual_effect(:highlight, "friend_request_#{user.id}", :duration => 1),
          500 => "alert('"+:sorry_there_was_an_error_requesting_friendship.l+"')",
          :url => hash_for_user_friendships_url(:user_id => current_user.id, :friend_id => user.id),
          :method => :post }, {:class => "add_friend button"}
    html += "<span style='display:none;' class='spinner'>"
    html += image_tag 'spinner.gif'
    html += :requesting_friendship.l+" ...</span></span>"
    html
  end

  def topnav_tab(name, options)
    classes = [options.delete(:class)]
    classes << 'current' if options[:section] && (options.delete(:section).to_a.include?(@section))

    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url), options) + "</li>"
  end

  # def format_post_totals(posts)
  #   "#{posts.size} posts, How to: #{posts.select{ |p| p.category.eql?(Category.get(:how_to))}.size}, Non How To: #{posts.select{ |p| !p.category.eql?(Category.get(:how_to))}.size}"
  # end

  def more_comments_links(commentable)
    html = link_to "&raquo; " + :all_comments.l, comments_url(commentable.class.to_s.underscore, commentable.to_param)
    html += "<br />"
    html += link_to "&raquo; " + :comments_rss.l, comments_url(commentable.class.to_s.underscore, commentable.to_param, :format => :rss)
    html
  end

  def more_user_comments_links(user = @user)
    html = link_to "&raquo; " + :all_comments.l, user_comments_url(user)
    html += "<br />"
    html += link_to "&raquo; " + :comments_rss.l, user_comments_url(user.to_param, :format => :rss)
    html
  end

  def activities_line_graph(options = {})
    line_color = "0x628F6C"
    prefix  = ''
    postfix = ''
    start_at_zero = false
    swf = "/images/swf/line_grapher.swf?file_name=/statistics.xml;activities&line_color=#{line_color}&prefix=#{prefix}&postfix=#{postfix}&start_at_zero=#{start_at_zero}"

    code = <<-EOF
    <object width="100%" height="400">
    <param name="movie" value="#{swf}">
    <embed src="#{swf}" width="100%" height="400">
    </embed>
    </object>
    EOF
    code
  end

  def feature_enabled?(feature)
    AppConfig.sections_enabled.include?(feature)
  end

  def show_footer_content?
    return true if (
      current_page?(:controller => 'base', :action => 'site_index') ||
      current_page?(:controller => 'posts', :action => 'show')  ||
      current_page?(:controller => 'categories', :action => 'show')  ||
      current_page?(:controller => 'users', :action => 'show')
    )

    return false
  end

 # def clippings_link
 #   "javascript:(function() {d=document, w=window, e=w.getSelection, k=d.getSelection, x=d.selection, s=(e?e():(k)?k():(x?x.createRange().text:0)), e=encodeURIComponent, document.location='#{application_url}new_clipping?uri='+e(document.location)+'&title='+e(document.title)+'&selection='+e(s);} )();"
 # end

  def paginating_links(paginator, options = {}, html_options = {})
    if paginator.size >= 1
      name = options[:name] || PaginatingFind::Helpers::DEFAULT_OPTIONS[:name]

      our_params = (options[:params] || params).clone

      our_params.delete("authenticity_token")
      our_params.delete("commit")

      links = paginating_links_each(paginator, options) do |n|
        our_params[name] = n
        link_to(n, our_params, html_options.merge(:class => (paginator.page.eql?(n) ? 'active' : '')))
      end
    end

    if options[:show_info].eql?(false)
      (links || '')
    else
      content_tag(:div, pagination_info_for(paginator), :class => 'pagination_info') + (links || '')
    end
  end

  def pagination_info_for(paginator, options = {})
    options = {:prefix => :showing.l, :connector => '-', :suffix => ""}.merge(options)
    window = paginator.first_item.to_s + options[:connector] + paginator.last_item.to_s
    options[:prefix] + " <strong>#{window}</strong> " + 'of'.l + " #{paginator.size} " + options[:suffix]
  end


  def last_active
    session[:last_active] ||= Time.now.utc
  end

  def submit_tag(value = :save_changes.l, options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>or " + or_option + "</span>" if or_option
    super
  end

  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def avatar_for(user, size=32)
    image_tag user.avatar.url(:medium), :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed.png', :size => '14x14', :alt => :subscribe_to.l+" #{title}"), url
  end

  def search_posts_title
    returning(params[:q].blank? ? :recent_posts.l : :searching_for.l+" '#{h params[:q]}'") do |title|
      title << " by #{h User.find(params[:user_id]).display_name}" if params[:user_id]
      title << " in #{h Forum.find(params[:forum_id]).name}"       if params[:forum_id]
    end
  end

  def search_user_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    options[:format] = :rss if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{route_key}_sb_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? search_all_sb_posts_path(options) : send("all_#{prefix}sb_posts_path", options)
  end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
      when 0..1           then (distance_in_minutes==0) ? :a_few_seconds_ago.l : :one_minute_ago.l
      when 2..59          then "#{distance_in_minutes} "+:minutes_ago.l
      when 60..90         then :one_hour_ago.l
      when 90..1440       then "#{(distance_in_minutes.to_f / 60.0).round} "+:hours_ago.l
      when 1440..2160     then :one_day_ago.l # 1 day to 1.5 days
      when 2160..2880     then "#{(distance_in_minutes.to_f / 1440.0).round} "+:days_ago.l # 1.5 days to 2 days
      else from_time.strftime("%b %e, %Y  %l:%M%p").gsub(/([AP]M)/) { |x| x.downcase }
    end
  end

  def time_ago_in_words_or_date(date)
    if date.to_date.eql?(Time.now.to_date)
      display = I18n.l(date.to_time, :format => :time_ago)
    elsif date.to_date.eql?(Time.now.to_date - 1)
      display = :yesterday.l
    else
      display = I18n.l(date.to_date, :format => :date_ago)
    end
  end

  def profile_completeness(user)
    segments = [
      {:val => 2, :action => link_to('Add a profile photo', edit_user_path(user, :anchor => 'profile_details')), :test => !user.avatar.nil? },
      {:val => 1, :action => link_to('Fill in your about me', edit_user_path(user, :anchor => 'user_description')), :test => !user.description.blank?},
      {:val => 2, :action => link_to('Select your city', edit_user_path(user, :anchor => 'location_chooser')), :test => !user.metro_area.nil? },
      {:val => 1, :action => link_to('Tag yourself', edit_user_path(user, :anchor => "user_tags")), :test => user.tags.any?},
      {:val => 1, :action => link_to('Invite some friends', new_invitation_path), :test => user.invitations.any?}
    ]

    completed_score = segments.select{|s| s[:test].eql?(true)}.sum{|s| s[:val]}
    incomplete = segments.select{|s| !s[:test] }

    total = segments.sum{|s| s[:val] }
    score = (completed_score.to_f/total.to_f)*100

    {:score => score, :incomplete => incomplete, :total => total}
  end


  def possesive(user)
    user.gender ? (user.male? ? :his.l : :her.l)  : :their.l
  end

  def owner_link
    if @space.owner
      link_to @space.owner.display_name, @space.owner
    else
      if current_user.can_be_owner? @space
        'Sem dono ' + link_to("(pegar)", take_ownership_space_path)
      else
        'Sem dono'
      end
      #TODO e se ninguem estiver apto a pegar ownership?
    end

  end

  def teachers_preview(space, size = nil)
    size ||= 12
    space.teachers.find(:all, :limit => size)
  end


  def month_events(space_id, month)
    start_month = Time.utc(Time.now.year, month, 1)
    end_month = Time.utc(Time.now.year, month, 31)
    Event.all(:select => "id, start_time, end_time",
              :conditions => ["eventable_id = ? AND eventable_type = 'Space' AND state LIKE 'approved' AND (start_time BETWEEN ? AND ? OR end_time BETWEEN ? AND ?)", space_id, start_month, end_month, start_month, end_month])
  end

  # Indica se há evento no dia informado
  def has_event_in?(events, day)
    d = Time.utc(Time.now.year, Time.now.month, day)
    day_events = events.select {|e| e.start_time <= d and d  <= e.end_time}
    day_events.size > 0
  end

def get_random_number
  SecureRandom.hex(4)
end

  # Gera o nome do recurso (class_name) devidamente pluralizado de acordo com
  # a quantidade (qty)
  def resource_name(class_name, qty)
    case class_name
    when :myfile
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'arquivo').split(' ')[1]}"
    when :bulletin
        "#{qty > 1 ? "novas" : "nova"} #{pluralize(qty, 'notícia').split(' ')[1]}"
    when :event
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'evento').split(' ')[1]}"
    when :topic
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'tópico').split(' ')[1]} "
    when :subject
        "#{qty > 1 ? "novos" : "novo"} #{pluralize(qty, 'módulo').split(' ')[1]} "
    end
  end

  # Mostra tabela de preço de planos
  def pricing_table(plans=nil)
    plans ||= Plan::PLANS

    render :partial => "plans/plans", :locals => { :plans => plans }
  end

end

# Renderer do WillPaginate responsável por renderizar
# a paginação no formato de Endless.
class EndlessRenderer < WillPaginate::LinkRenderer
  def to_html
    if @options[:class].eql? "pagination"
      @options[:class] = "endless"
    else
      @options[:class] += " endless"
    end

    unless @collection.next_page.nil?
      html = @template.link_to_remote "Mostrar mais resultados",
        :url => url_for(@collection.next_page), :method =>:get,
        :loading => "$('.#{@options[:class]}').html('" \
        + @template.escape_javascript(@template.image_tag('spinner.gif')) + "')"

      html = html.html_safe if html.respond_to? :html_safe
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end
  end
end

