require File.dirname(__FILE__) + '/helper'

describe 'Static' do
  F = ::File

  before do
    mock_app {
      set :static, true
      set :public, F.dirname(__FILE__)
    }
  end

  it 'serves GET requests for files in the public directory' do
    get "/#{F.basename(__FILE__)}"
    assert ok?
    assert_equal File.read(__FILE__), body
    assert_equal File.size(__FILE__).to_s, response['Content-Length']
    assert response.headers.include?('Last-Modified')
  end

  it 'serves HEAD requests for files in the public directory' do
    head "/#{F.basename(__FILE__)}"
    assert ok?
    assert_equal '', body
    assert_equal File.size(__FILE__).to_s, response['Content-Length']
    assert response.headers.include?('Last-Modified')
  end

  it 'serves files in preference to custom routes' do
    @app.get("/#{F.basename(__FILE__)}") { 'Hello World' }
    get "/#{F.basename(__FILE__)}"
    assert ok?
    assert body != 'Hello World'
  end

  it 'does not serve directories' do
    get "/"
    assert not_found?
  end

  it 'passes to the next handler when the static option is disabled' do
    @app.set :static, false
    get "/#{F.basename(__FILE__)}"
    assert not_found?
  end

  it 'passes to the next handler when the public option is nil' do
    @app.set :public, nil
    get "/#{F.basename(__FILE__)}"
    assert not_found?
  end

  it '404s when a file is not found' do
    get "/foobarbaz.txt"
    assert not_found?
  end
end
