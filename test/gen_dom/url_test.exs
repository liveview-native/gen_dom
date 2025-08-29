defmodule GenDOM.URLTest do
  use ExUnit.Case, async: true

  alias GenDOM.URL

  describe "new/2 constructor" do
    test "creates URL with absolute URL string" do
      url = URL.new("https://example.com/path?query=value#fragment")
      
      assert url.protocol == "https:"
      assert url.hostname == "example.com"
      assert url.pathname == "/path"
      assert url.search == "?query=value"
      assert url.hash == "#fragment"
      assert url.href == "https://example.com/path?query=value#fragment"
      assert url.origin == "https://example.com"
    end

    # test "creates URL with relative URL and base" do
    #   base_url = "https://example.com/directory/"
    #   url = URL.new("../other/path", base_url)
    #
    #   assert url.protocol == "https:"
    #   assert url.hostname == "example.com"
    #   assert url.pathname == "/other/path"
    #   assert url.href == "https://example.com/other/path"
    # end

    test "creates URL with relative path and base" do
      base_url = "https://example.com/api/v1/"
      url = URL.new("users", base_url)
      
      assert url.pathname == "/api/v1/users"
      assert url.href == "https://example.com/api/v1/users"
    end

    test "creates URL with query-only relative URL" do
      base_url = "https://example.com/search"
      url = URL.new("?q=test", base_url)
      
      assert url.pathname == "/search"
      assert url.search == "?q=test"
      assert url.href == "https://example.com/search?q=test"
    end

    test "creates URL with fragment-only relative URL" do
      base_url = "https://example.com/page"
      url = URL.new("#section1", base_url)
      
      assert url.pathname == "/page"
      assert url.hash == "#section1"
      assert url.href == "https://example.com/page#section1"
    end

    test "handles URLs with authentication credentials" do
      url = URL.new("https://user:pass@example.com/secure")
      
      assert url.username == "user"
      assert url.password == "pass"
      assert url.hostname == "example.com"
      assert url.href == "https://user:pass@example.com/secure"
    end

    test "handles URLs with non-standard ports" do
      url = URL.new("https://example.com:8443/api")
      
      assert url.hostname == "example.com"
      assert url.port == "8443"
      assert url.host == "example.com:8443"
      assert url.origin == "https://example.com:8443"
    end

    test "handles file:// protocol URLs" do
      url = URL.new("file:///Users/username/document.txt")
      
      assert url.protocol == "file:"
      assert url.hostname == ""
      assert url.pathname == "/Users/username/document.txt"
      assert url.origin == "file://"
    end

    test "raises error for invalid URL without base" do
      assert_raise ArgumentError, fn ->
        URL.new("not a valid url")
      end
    end

    test "raises error for invalid relative URL without base" do
      assert_raise ArgumentError, fn ->
        URL.new("/relative/path")
      end
    end

    test "raises error for invalid base URL" do
      assert_raise ArgumentError, fn ->
        URL.new("path", "invalid base")
      end
    end
  end

  describe "property access" do
    setup do
      url = URL.new("https://user:pass@example.com:8080/path/to/resource?query=value&other=data#section1")
      {:ok, url: url}
    end

    test "href returns complete URL string", %{url: url} do
      assert url.href == "https://user:pass@example.com:8080/path/to/resource?query=value&other=data#section1"
    end

    test "origin returns scheme + host + port", %{url: url} do
      assert url.origin == "https://example.com:8080"
    end

    test "protocol returns scheme with colon", %{url: url} do
      assert url.protocol == "https:"
    end

    test "hostname returns domain name only", %{url: url} do
      assert url.hostname == "example.com"
    end

    test "host returns hostname + port", %{url: url} do
      assert url.host == "example.com:8080"
    end

    test "port returns port number as string", %{url: url} do
      assert url.port == "8080"
    end

    test "pathname returns path component", %{url: url} do
      assert url.pathname == "/path/to/resource"
    end

    test "search returns query string with question mark", %{url: url} do
      assert url.search == "?query=value&other=data"
    end

    test "hash returns fragment with hash symbol", %{url: url} do
      assert url.hash == "#section1"
    end

    test "username returns authentication username", %{url: url} do
      assert url.username == "user"
    end

    test "password returns authentication password", %{url: url} do
      assert url.password == "pass"
    end
  end

  describe "edge cases and normalization" do
    test "handles empty components" do
      url = URL.new("https://example.com")
      
      assert url.pathname == "/"
      assert url.search == ""
      assert url.hash == ""
      assert url.username == ""
      assert url.password == ""
      assert url.port == ""
    end

    test "normalizes path components" do
      url = URL.new("https://example.com/./path/../other/./file")
      
      assert url.pathname == "/other/file"
    end

    test "handles Unicode characters" do
      url = URL.new("https://例え.テスト/パス")
      
      assert url.hostname == "例え.テスト"
      assert url.pathname == "/パス"
    end

    test "handles percent-encoded characters" do
      url = URL.new("https://example.com/path%20with%20spaces")
      
      assert url.pathname == "/path with spaces"
    end

    test "handles international domain names (IDN)" do
      url = URL.new("https://xn--fsq.xn--0zwm56d")
      
      assert url.hostname == "xn--fsq.xn--0zwm56d"
    end

    test "handles default ports" do
      https_url = URL.new("https://example.com:443/path")
      http_url = URL.new("http://example.com:80/path")
      
      assert https_url.port == ""
      assert http_url.port == ""
    end
  end

  # describe "can_parse/2 static method" do
  #   test "returns true for valid absolute URL" do
  #     assert URL.can_parse("https://example.com/path") == true
  #   end
  #
  #   test "returns true for valid relative URL with base" do
  #     assert URL.can_parse("../path", "https://example.com/dir/") == true
  #   end
  #
  #   test "returns false for invalid URL without base" do
  #     assert URL.can_parse("not a url") == false
  #   end
  #
  #   test "returns false for relative URL without base" do
  #     assert URL.can_parse("/relative/path") == false
  #   end
  #
  #   test "returns false for invalid URL with valid base" do
  #     assert URL.can_parse("ht!tp://invalid", "https://example.com") == false
  #   end
  #
  #   test "returns false when base URL is invalid" do
  #     assert URL.can_parse("path", "invalid base") == false
  #   end
  # end

  describe "to_string/1" do
    test "returns complete URL as string" do
      url = URL.new("https://example.com/path?query=value#fragment")
      
      assert URL.to_string(url) == "https://example.com/path?query=value#fragment"
    end

    test "handles URLs with authentication" do
      url = URL.new("https://user:pass@example.com/secure")
      
      assert URL.to_string(url) == "https://user:pass@example.com/secure"
    end

    test "handles URLs with custom ports" do
      url = URL.new("https://example.com:8443/api")
      
      assert URL.to_string(url) == "https://example.com:8443/api"
    end
  end

  describe "to_json/1" do
    test "returns URL as JSON-serializable string" do
      url = URL.new("https://example.com/path?query=value#fragment")
      
      assert URL.to_json(url) == "https://example.com/path?query=value#fragment"
    end

    test "matches to_string output" do
      url = URL.new("https://user:pass@example.com:8080/path?query=value")
      
      assert URL.to_json(url) == URL.to_string(url)
    end
  end

  # describe "object URL methods" do
  #   test "create_object_url/1 returns blob URL" do
  #     mock_blob = %{type: "text/plain", size: 100}
  #     object_url = URL.create_object_url(mock_blob)
  #
  #     assert String.starts_with?(object_url, "blob:")
  #     assert String.contains?(object_url, "://")
  #   end
  #
  #   test "revoke_object_url/1 accepts blob URL" do
  #     object_url = "blob:https://example.com/550e8400-e29b-41d4-a716-446655440000"
  #
  #     # Should not raise an error
  #     assert :ok = URL.revoke_object_url(object_url)
  #   end
  # end

  describe "spec compliance" do
    test "follows RFC 3986 URL syntax" do
      url = URL.new("foo://example.com:8042/over/there?name=ferret#nose")
      
      assert url.protocol == "foo:"
      assert url.hostname == "example.com"
      assert url.port == "8042"
      assert url.pathname == "/over/there"
      assert url.search == "?name=ferret"
      assert url.hash == "#nose"
    end

    test "handles scheme-relative URLs" do
      base_url = "https://example.com/path"
      url = URL.new("//other.com/resource", base_url)
      
      assert url.protocol == "https:"
      assert url.hostname == "other.com"
      assert url.pathname == "/resource"
    end

    test "handles root-relative URLs" do
      base_url = "https://example.com/deep/path/file"
      url = URL.new("/root/resource", base_url)
      
      assert url.hostname == "example.com"
      assert url.pathname == "/root/resource"
    end

    test "resolves dot segments correctly" do
      base_url = "https://example.com/a/b/c/"
      
      # Test various relative path scenarios
      scenarios = [
        {"../d", "/a/b/d"},
        {"./d", "/a/b/c/d"},
        {"../../../d", "/d"},
        {"../../../../d", "/d"},
        {"./../d", "/a/b/d"},
        {"./d/./e", "/a/b/c/d/e"}
      ]
      
      for {relative_path, expected_pathname} <- scenarios do
        url = URL.new(relative_path, base_url)
        assert url.pathname == expected_pathname, 
               "Expected #{relative_path} to resolve to #{expected_pathname}, got #{url.pathname}"
      end
    end

    test "preserves trailing slashes appropriately" do
      # Directory-like URLs should preserve trailing slashes
      dir_url = URL.new("https://example.com/directory/")
      assert String.ends_with?(dir_url.pathname, "/")
      
      # File-like URLs should not have trailing slashes
      file_url = URL.new("https://example.com/file")
      refute String.ends_with?(file_url.pathname, "/")
    end
  end

  # describe "error handling" do
  #   test "provides meaningful error messages" do
  #     error = assert_raise ArgumentError, fn ->
  #       URL.new("ht!tp://invalid-scheme.com")
  #     end
  #
  #     assert String.contains?(error.message, "invalid") or 
  #            String.contains?(error.message, "parse")
  #   end
  #
  #   test "handles malformed URLs gracefully" do
  #     malformed_urls = [
  #       "http://",
  #       "://example.com",
  #       "http:///path",
  #       "http://example.com:99999"
  #     ]
  #
  #     for malformed_url <- malformed_urls do
  #       assert_raise ArgumentError, fn ->
  #         URL.new(malformed_url)
  #       end
  #     end
  #   end
  # end
end
