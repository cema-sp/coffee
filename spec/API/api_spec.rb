require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe CoffeeServer::API do
  let(:version) { '1' }
  let(:request_path) { "/api/v#{version}/points" }
  let(:request_headers) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'HTTP_CONTENT_TYPE' => 'application/vnd.api+json;charset=utf-8'
    }
  end
  let(:response) { get(request_path, nil, request_headers) }
  subject { response }

  describe 'valid response' do
    its(:body) { should include('points') }
    its(:status) { should eq 200 }

    describe 'headers' do
      describe 'Content-Type' do
        its(:header) do
          should include(
            "Content-Type"=>"application/vnd.api+json;charset=utf-8")
        end
      end
    end
  end

  describe 'invalid' do
    describe 'API' do
      describe 'version' do
        let(:version) { '1000' }

        its(:body) { should include('error','version') }
        its(:status) { should eq 404 }
      end

      describe 'path' do
        let(:request_path) { "/api/points" }

        its(:body) { should include('error','path') }
        its(:status) { should eq 404 }
      end

      describe 'object' do
        let(:request_path) { "/api/v#{version}/invalid" }

        its(:body) { should include('error','object','invalid') }
        its(:status) { should eq 404 }
      end
    end

    describe 'request' do
      describe 'header' do
        describe 'Content-Type' do
          let(:request_headers) do
            {
              'HTTP_ACCEPT' => 'application/vnd.api+json',
              'HTTP_CONTENT_TYPE' => 'application/xml'
            }
          end
          
          its(:body) { should include('error','Content-Type') }
          its(:status) { should eq 415 }
        end

        describe 'Accept' do
          let(:request_headers) do
            {
              'HTTP_ACCEPT' => 'application/xml',
              'HTTP_CONTENT_TYPE' => 'application/vnd.api+json;charset=utf-8'
            }
          end
          
          its(:body) { should include('error','Accept') }
          its(:status) { should eq 406 }
        end
      end
    end
  end
end
