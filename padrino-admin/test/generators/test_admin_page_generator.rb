require File.expand_path(File.dirname(__FILE__) + '/../helper')

class Person
  def self.properties
    [:id, :name, :age, :email].map { |c| OpenStruct.new(:name => c) }
  end
end

class Page
  def self.properties
    [:id, :name, :body].map { |c| OpenStruct.new(:name => c) }
  end
end

class TestAdminPageGenerator < Test::Unit::TestCase

  def setup
    @apptmp = "#{Dir.tmpdir}/padrino-tests/#{UUID.new.generate}"
    `mkdir -p #{@apptmp}`
  end

  def teardown
    `rm -rf #{@apptmp}`
  end

  context 'the admin page generator' do

    should 'fail outside app root' do
      output = silence_logger { generate(:admin_page, 'foo', "-r=#{@apptmp}/sample_project") }
      assert_match(/not at the root/, output)
      assert_no_file_exists('/tmp/admin')
    end

    should 'fail without argument and model' do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=activerecord') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      assert_raise(Padrino::Admin::Generators::OrmError) { generate(:admin_page, 'foo', "-r=#{@apptmp}/sample_project") }
    end

    should 'correctly generate a new padrino admin application default renderer' do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=datamapper','-e=haml') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      silence_logger { generate(:model, 'person', "name:string", "age:integer", "email:string", "--root=#{@apptmp}/sample_project") }
      silence_logger { generate(:admin_page, 'person', "--root=#{@apptmp}/sample_project") }
      assert_file_exists "#{@apptmp}/sample_project/admin/controllers/people.rb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/_form.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/edit.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/index.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/new.haml"
      %w(name age email).each do |field|
        assert_match_in_file "label :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.haml"
        assert_match_in_file "text_field :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.haml"
      end
      assert_match_in_file 'role.project_module :people, "/people"', "#{@apptmp}/sample_project/admin/app.rb"
      assert_match_in_file "elsif Padrino.env == :development && params[:bypass]", "#{@apptmp}/sample_project/admin/controllers/sessions.rb"
      assert_match_in_file "check_box_tag :bypass", "#{@apptmp}/sample_project/admin/views/sessions/new.haml"
    end

    should "store and apply session_secret" do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=datamapper','-e=haml') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      assert_match_in_file(/session_secret:.+/, "#{@apptmp}/sample_project/.components")
      session_secret = YAML.load_file("#{@apptmp}/sample_project/.components")[:session_secret]
      assert_not_equal "", session_secret
      assert_match_in_file(/#{session_secret}/, "#{@apptmp}/sample_project/app/app.rb")
      assert_match_in_file(/#{session_secret}/, "#{@apptmp}/sample_project/admin/app.rb")
    end

    should 'correctly generate a new padrino admin application with erb renderer' do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=datamapper', '-e=erb') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      silence_logger { generate(:model, 'person', "name:string", "age:integer", "email:string", "-root=#{@apptmp}/sample_project") }
      silence_logger { generate(:admin_page, 'person', "--root=#{@apptmp}/sample_project") }
      assert_file_exists "#{@apptmp}/sample_project/admin/controllers/people.rb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/_form.erb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/edit.erb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/index.erb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/new.erb"
      %w(name age email).each do |field|
        assert_match_in_file "label :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.erb"
        assert_match_in_file "text_field :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.erb"
      end
      assert_match_in_file 'role.project_module :people, "/people"', "#{@apptmp}/sample_project/admin/app.rb"
      assert_match_in_file "elsif Padrino.env == :development && params[:bypass]", "#{@apptmp}/sample_project/admin/controllers/sessions.rb"
      assert_match_in_file "check_box_tag :bypass", "#{@apptmp}/sample_project/admin/views/sessions/new.erb"
    end

    should 'correctly generate a new padrino admin application with slim renderer' do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=datamapper', '-e=slim') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      silence_logger { generate(:model, 'person', "name:string", "age:integer", "email:string", "-root=#{@apptmp}/sample_project") }
      silence_logger { generate(:admin_page, 'person', "--root=#{@apptmp}/sample_project") }
      assert_file_exists "#{@apptmp}/sample_project/admin/controllers/people.rb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/_form.slim"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/edit.slim"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/index.slim"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/new.slim"
      %w(name age email).each do |field|
        assert_match_in_file "label :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.slim"
        assert_match_in_file "text_field :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.slim"
      end
      assert_match_in_file 'role.project_module :people, "/people"', "#{@apptmp}/sample_project/admin/app.rb"
      assert_match_in_file "elsif Padrino.env == :development && params[:bypass]", "#{@apptmp}/sample_project/admin/controllers/sessions.rb"
      assert_match_in_file "check_box_tag :bypass", "#{@apptmp}/sample_project/admin/views/sessions/new.slim"
    end

    should 'correctly generate a new padrino admin application with multiple models' do
      silence_logger { generate(:project, 'sample_project', "--root=#{@apptmp}", '-d=datamapper','-e=haml') }
      silence_logger { generate(:admin_app, "--root=#{@apptmp}/sample_project") }
      silence_logger { generate(:model, 'person', "name:string", "age:integer", "email:string", "-root=#{@apptmp}/sample_project") }
      silence_logger { generate(:model, 'page', "name:string", "body:string", "-root=#{@apptmp}/sample_project") }
      silence_logger { generate(:admin_page, 'person', 'page', "--root=#{@apptmp}/sample_project") }
      # For Person
      assert_file_exists "#{@apptmp}/sample_project/admin/controllers/people.rb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/_form.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/edit.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/index.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/people/new.haml"
      %w(name age email).each do |field|
        assert_match_in_file "label :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.haml"
        assert_match_in_file "text_field :#{field}", "#{@apptmp}/sample_project/admin/views/people/_form.haml"
      end
      assert_match_in_file 'role.project_module :people, "/people"', "#{@apptmp}/sample_project/admin/app.rb"
      # For Page
      assert_file_exists "#{@apptmp}/sample_project/admin/controllers/pages.rb"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/pages/_form.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/pages/edit.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/pages/index.haml"
      assert_file_exists "#{@apptmp}/sample_project/admin/views/pages/new.haml"
      %w(name body).each do |field|
        assert_match_in_file "label :#{field}", "#{@apptmp}/sample_project/admin/views/pages/_form.haml"
        assert_match_in_file "text_field :#{field}", "#{@apptmp}/sample_project/admin/views/pages/_form.haml"
      end
      assert_match_in_file 'role.project_module :pages, "/pages"', "#{@apptmp}/sample_project/admin/app.rb"
    end
  end
end