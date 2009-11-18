PADRINO_ENV = RACK_ENV = 'test' unless defined?(PADRINO_ENV)
require File.dirname(__FILE__) + '/helper'

class TestPadrinoAdvRouting < Test::Unit::TestCase
  silence_logger { require File.dirname(__FILE__) + '/fixtures/adv_routing_app/config/boot' }
  require File.dirname(__FILE__) + '/fixtures/adv_routing_app/app'
  
  def app
    AdvRoutingDemo.tap { |app| app.set :environment, :test }
  end

  def setup
    @demo = app.new
  end

  context 'controller direct namespacing' do
    should "support creating route for namespaced url" do
      visit '/admin/32/the/dashboard'
      assert_have_selector :h1, :content => "This is the admin dashboard, id: 32"
    end

    should "support namespaced autogenerated route" do
      visit '/admin/panel/john/thing'
      assert_have_selector :h1, :content => "This is the admin panel, name: john"
    end

    should "support simple namespaced mapping in urls" do
      visit '/admin/settings/action'
      assert_have_selector :h1, :content => "This is the settings"
    end

    should "support regular namespacing as well" do
      visit '/blog/index/action'
      assert_have_selector :h1, :content => "Here is the blog"
    end
  end

  context 'controller url autogeneration' do
    should "support creating url 'hello' route in definition" do
      visit '/some/hello/action/5/param'
      assert_have_selector :h1, :content => "hello params id is 5"
    end

    should "support simple url map in route" do
      visit '/some/simple/action'
      assert_have_selector :h1, :content => "simple action welcomes you"
    end

    should "support urls with multiple paramaters defined in route" do
      visit '/some/dean/and/56'
      assert_have_selector :h1, :content => "id is 56, name is dean"
    end

    should "support referencing existing urls" do
      visit '/test/20/action'
      assert_have_selector :h1, :content => "This is a test action, id: 20"
    end
  end

  context 'controller url_for management' do
    should 'recognize namespaced routes' do
      @demo = @demo.instance_variable_get(:@app) until @demo.is_a?(AdvRoutingDemo)
      assert_equal '/admin/18/the/dashboard', @demo.url_for(:admin, :dashboard, :id => 18)
      assert_equal '/admin/panel/joe/thing', @demo.url_for(:admin, :panel, :name => 'joe')
      assert_equal '/admin/simple', @demo.url_for(:admin, :simple)
      assert_equal '/admin/settings/action', @demo.url_for(:admin, :settings)
    end

    should 'recognize for autogenerated routes' do
      @demo = @demo.instance_variable_get(:@app) until @demo.is_a?(AdvRoutingDemo)
      assert_equal '/some/simple/action', @demo.url_for(:simple)
      assert_equal '/some/hello/action/27/param', @demo.url_for(:hello, :id => 27)
      assert_equal '/test/50/action', @demo.url_for(:test, :id => 50)
    end
  end
end
