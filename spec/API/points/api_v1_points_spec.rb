require File.expand_path '../../../spec_helper.rb', __FILE__
require 'pry'

RSpec.describe 'CoffeeServer::API - points' do
  let(:version) { '1' }
  let(:request_headers) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'HTTP_CONTENT_TYPE' => 'application/vnd.api+json;charset=utf-8'
    }
  end

  describe 'GET /points/:id' do
    let(:request_path) { "/api/v#{version}/points/#{point._id}" }
    let(:point) do
      CoffeeServer::Point
        .create(coordinates: {lat: 1, lon: 2}, comment: 'test_comment')
    end

    let(:response) { get(request_path, nil, request_headers) }
    
    subject { response }

    context 'with valid :id' do
      its(:body) { should include('test_comment') }
      its(:header) { should include('Location') }
      its(:status) { should eq 200 }
    end

    context 'with invalid :id' do
      let(:request_path) { "/api/v#{version}/points/#{point._id}000" }

      its(:body) { should include('not found') }
      its(:status) { should eq 404 }
    end
  end

  describe 'GET /points' do
    let(:request_path) { "/api/v#{version}/points" }
    let!(:points) do
      CoffeeServer::Point
        .create([
          {coordinates: {lat: 1, lon: 2}, comment: 'test_comment_1'},
          {coordinates: {lat: 3, lon: 4}, comment: 'test_comment_2'}])
    end

    let(:response) { get(request_path, nil, request_headers) }
    
    subject { response }

    its(:body) { should include('test_comment_1', 'test_comment_2') }
    its(:header) { should_not include('Location') }
    its(:status) { should eq 200 }
  end

  describe 'POST /points' do
    let(:request_path) { "/api/v#{version}/points" }
    let(:point) { CoffeeServer::Point.new(coordinates: {lat: 1, lon: 2}) }
    let(:response) { post(request_path, point.to_json, request_headers) }

    subject { response }

    context 'with valid data' do
      before { point.comment = 'test_comment' }

      it 'increases CoffeeServer::Point count by 1' do
        expect{ response }
          .to change{ CoffeeServer::Point.count }
          .from(0)
          .to(1)
      end
      
      its(:body) { should_not include('error') }
      its(:body) { should include('test_comment') }
      its(:header) { should include('Location') }
      its(:status) { should eq 201 }
    end

    context 'with invalid data' do
      before { point.coordinates = {la: 1, lo: 2} }

      it 'does not change CoffeeServer::Point count' do
        expect{ response }.not_to change{ CoffeeServer::Point.count }
      end

      its(:body) { should include('error', 'coordinates') }
    end

    context 'with unpermitted data' do
      describe 'predefined: true' do
        before { point.predefined = true }

        it 'does not change CoffeeServer::Point count' do
          expect{ response }.not_to change{ CoffeeServer::Point.count }
        end

        its(:body) { should include('error', 'predefined') }
        its(:status) { should eq 403 }
      end

      describe 'votes: 10' do
        before { point.votes = 10 }

        it 'does not change CoffeeServer::Point count' do
          expect{ response }.not_to change{ CoffeeServer::Point.count }
        end

        its(:body) { should include('error', 'votes') }
        its(:status) { should eq 403 }
      end
    end
  end

  describe 'PATCH /points/:id' do
    let(:request_path) { "/api/v#{version}/points/#{point._id}" }
    let(:point) do
      CoffeeServer::Point
        .create(coordinates: {lat: 1, lon: 2}, comment: 'test_comment')
    end
    # let!(:point_new) { point.comment = 'test_comment_new' }

    let(:response) { patch(request_path, point.to_json, request_headers) }
    
    subject { response }

    context 'with valid :id' do
      context 'with valid attributes' do
        before { point.comment = 'test_comment_new' }

        its(:body) { should include('test_comment_new') }
        its(:header) { should include('Location' => "/#{point._id}") }
        its(:status) { should eq 200 }
      end
    end

    context 'with invalid :id' do
      let(:request_path) { "/api/v#{version}/points/#{point._id}000" }

      its(:body) { should include('not found') }
      its(:status) { should eq 404 }
    end
  end

  describe 'DELETE /points/:id' do
    let(:request_path) { "/api/v#{version}/points/#{point._id}" }
    let!(:point) do
      CoffeeServer::Point
        .create(coordinates: {lat: 1, lon: 2})
    end

    let(:response) { delete(request_path, {}, request_headers) }
    
    subject { response }

    context 'with valid :id' do
      it 'decreases CoffeeServer::Point count by 1' do
        expect{ response }
          .to change{ CoffeeServer::Point.count }
          .from(1)
          .to(0)
      end

      its(:status) { should eq 200 }
    end

    context 'with invalid :id' do
      let(:request_path) { "/api/v#{version}/points/#{point._id}000" }

      its(:body) { should include('not found') }
      its(:status) { should eq 404 }
    end
  end
end
