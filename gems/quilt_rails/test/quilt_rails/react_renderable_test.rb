# frozen_string_literal: true
module Quilt
  class ReactRenderableTest < Minitest::Test
    include Quilt::ReactRenderable

    def setup
      @request_id = '06a2f67e-b080-446f-bffa-7851ddad3a45'
      @request = ActionDispatch::TestRequest.create
      @request.request_id = @request_id
    end

    def test_render_react_calls_reverse_proxy_with_server_uri_and_csrf
      Rails.env.stubs(:test?).returns(false)
      url = "#{Quilt.configuration.react_server_protocol}://#{Quilt.configuration.react_server_host}"

      assert_equal(
        render_react,
        reverse_proxy(
          url,
          headers: { 'X-Request-ID': @request_id, 'X-Quilt-Data': {}.to_json }
        )
      )
    end

    def test_render_react_calls_with_custom_headers
      Rails.env.stubs(:test?).returns(false)
      url = "#{Quilt.configuration.react_server_protocol}://#{Quilt.configuration.react_server_host}"

      render_result = render_react(headers: { 'x-custom-header': 'test' })
      headers = {
        'x-custom-header': 'test',
        'X-Request-ID': @request_id,
        'X-Quilt-Data': {}.to_json,
      }
      proxy_result = reverse_proxy(url, headers: headers)

      assert_equal(render_result, proxy_result)
    end

    def test_render_react_calls_reverse_proxy_with_header_data
      Rails.env.stubs(:test?).returns(false)
      url = "#{Quilt.configuration.react_server_protocol}://#{Quilt.configuration.react_server_host}"

      headers = { 'X-Request-ID': @request_id, 'X-Quilt-Data': { 'X-Foo': 'bar' }.to_json }
      assert_equal(
        render_react(data: { 'X-Foo': 'bar' }),
        reverse_proxy(url, headers: headers)
      )
    end

    def test_render_react_errors_in_tests
      Rails.env.stubs(:test?).returns(true)
      assert_raises Quilt::ReactRenderable::DoNotIntegrationTestError do
        render_react
      end
    end

    private

    # Stubbing this method the mixin calls
    def reverse_proxy(url, headers: {})
      "called with #{url} and #{headers}"
    end

    # Stubbing this method the mixin calls
    def form_authenticity_token
      'foo'
    end

    # Stubbing request that exist in a controller
    attr_reader :request
  end
end
