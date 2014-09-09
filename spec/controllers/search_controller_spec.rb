require 'spec_helper'
describe SearchController, :type => :controller do

  describe 'GET search' do
    let :search do
      search = instance_double('Search', :results => [])
      allow(search).to receive(:created_by).and_return(search)
      allow(search).to receive(:fulltext_by).and_return(search)
      allow(search).to receive(:results).and_return([])
      allow(Search).to receive(:for).with(Child).and_return(search)
      search
    end

    before :all do
      create :form, :name => Child::FORM_NAME
    end

    before :each do
      fake_field_worker_login
    end

    it 'should render error if search is invalid' do
      get :search, :query => nil
      expect(request.flash[:error]).to eq('Please enter at least one search criteria')
    end

    it 'should search against specified model' do
      expect(Search).to receive(:for).with(Child).and_return(search)

      get :search, :query => 'test', :search_type => 'Child'
      expect(response).to be_ok
    end

    it 'should only return children for current user' do
      expect(search).to receive(:created_by).with(@controller.current_user.user_name)

      get :search, :query => 'some query', :search_type => 'Child'
      expect(response).to be_ok
    end

    it 'should return all children if user can view all' do
      fake_admin_login
      expect(search).to_not receive(:created_by)

      get :search, :query => 'some query', :search_type => 'Child'
      expect(response).to be_ok
    end

    it 'should use fulltext search with the query' do
      expect(search).to receive(:fulltext_by).with(kind_of(Array), 'some query')

      get :search, :query => 'some query', :search_type => 'Child'
      expect(response).to be_ok
    end

    it 'should authorize the user' do
      expect(@controller).to receive(:authorize!).with(:index, Child)

      get :search, :query => 'some query', :search_type => 'Child'
      expect(response).to be_ok
    end
  end
end
