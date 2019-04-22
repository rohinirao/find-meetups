require 'rails_helper'
RSpec.describe MeetupsController, type: :controller do
  let!(:result) {[
    {"name"=>"Munich Coding Meetup", "location"=>"München, Germany", "status"=>"active", "category"=>"Tech", "photo"=>"defualt_photo.svg"}
  ]}
  describe '#index' do
    it 'renders index template' do
      get :index
      expect(response).to render_template('meetups/index', 'layouts/application')
    end
  end

  describe '#search' do
    it 'renders search template' do
      get :search, xhr: true, format: :js, params: { search_text: 'tech' }
      expect(response).to render_template('meetups/search', 'layouts/application')
    end
    context 'when result is not cached' do
      it 'queues MeetupsSearchJob' do
        MEETUP_REDIS.del('test')
        get :search, xhr: true, format: :js, params: { search_text: 'test' }
        expect(JSON.parse(MEETUP_REDIS.get('test'))).not_to be_empty
      end
    end
    context 'when result is cached' do
      it 'not queues MeetupsSearchJob' do
        MEETUP_REDIS.set('test', result.to_json)
        get :search, xhr: true, format: :js, params: { search_text: 'test' }
        expect(JSON.parse(MEETUP_REDIS.get('test')).first['name']).to eq(result.first['name'])
      end
    end
  end

  describe '#search_result' do
    it 'renders search_result template' do
      get :search_result, xhr: true, format: :js, params: { search_text: 'test' }
      expect(response).to render_template('meetups/search_result', 'layouts/application')
    end

    describe 'assigns @result' do
      context 'when meetups is nil' do
        it 'returns :not_ready' do
          MEETUP_REDIS.del('rails')
          get :search_result, xhr: true, format: :js, params: { search_text: 'rails' }
          expect(assigns[:result]).to eq(:not_ready)
        end
      end
      context 'when meetups is empty/blank' do
        it 'returns :no_result' do
          MEETUP_REDIS.set('sda', [].to_json)
          get :search_result, xhr: true, format: :js, params: { search_text: 'sda' }
          expect(assigns[:result]).to eq(:no_result)
        end
      end
      context 'when valid meetups' do
        it 'returns result' do
          MEETUP_REDIS.set('tech', result.to_json)
          get :search_result, xhr: true, format: :js, params: { search_text: 'tech' }
          expect(assigns[:result]).to eq(result)
        end
      end
    end
  end
end
