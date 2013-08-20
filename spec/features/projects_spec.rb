# coding: utf-8

require 'spec_helper'

describe "Projects" do
  let(:project){ build(:project) }

  before {
    #NOTE: Weird bug on edit project test
    RoutingFilter.active = true
    ProjectsController.any_instance.stub(:last_tweets).and_return([])
  }
  before {
    ::Configuration[:base_url] = 'http://catarse.me'
    ::Configuration[:company_name] = 'Catarse'
  }


  describe "home" do
    before do
      create(:project, state: 'online', recommended: true, online_days: 30, online_date: Time.now)
      create(:project, state: 'soon', online_days: 30, online_date: 7.days.ago)
      visit root_path(locale: :pt)
    end

    it "should show recommended projects" do
      recent = all(".selected_projects.list .project")
      recent.should have(1).items
    end

    it "should show coming soon projects" do
      recent = all(".coming_soon_projects.list .project")
      recent.should have(1).items
    end
  end

  describe "explore" do
    before do
      create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(locale: :pt)
      sleep 3
    end
    it "should show recommended projects" do
      recommended = all(".results .project")
      recommended.should have(1).items
    end
  end

  describe "search" do
    before do
      create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(anchor: :search) + '/Lorem'
      sleep 4
    end
    it "should show recommended projects" do
      recommended = all(".results .project")
      recommended.should have(1).items
    end
  end


  describe "new and create" do
    before do
      login
      visit new_project_path(locale: :pt)
    end

    it "should present the form and save the data" do
      all("form#project_form").should have(1).items
      [
        'permalink', 'name', 'video_url',
        'headline', 'goal', 'online_days',
        'about', 'first_backers', 'how_know', 'more_links'
      ].each do |a|
        fill_in "project_#{a}", with: project.attributes[a]
      end
      check 'project_accepted_terms'
      find('#project_submit').click
      #Project.first.name.should == project.name
    end
  end

  describe "edit" do
    let(:project) { create(:project, online_days: 10, state: 'online', user: current_user) }

    before do
      login
      visit project_path(project, locale: :pt)
    end

    it 'edit tab should be present' do
      page.should have_selector('a#edit_link')
    end
  end

  describe "budget" do
    let(:project) { create(:project, online_days: 10, state: 'online', user: current_user, budget: 'some budget') }

    before do
      login
      visit project_path(project, locale: :pt)
    end

    it 'budget tab should be present' do
      page.should have_selector('a#budget_link')
    end
  end
end
