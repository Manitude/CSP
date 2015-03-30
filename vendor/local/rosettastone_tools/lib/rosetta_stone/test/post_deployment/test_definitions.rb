# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module PostDeployment
    module TestDefinitions
      def build_no_gzip_test(uri)
        test "uri #{uri} is not served with gzip even if supported by client" do
          get uri, with_gzip
          assert_success
          assert_no_gzip
        end
      end

      def build_gzip_test(uri)
        test "uri #{uri} is not served with gzip if not supported by client" do
          get uri
          assert_success
          assert_no_gzip
        end

        test "uri #{uri} is served with gzip if supported by client" do
          get uri, with_gzip
          assert_success
          assert_gzip
        end
      end

      def build_expires_test(uri)
        test "uri #{uri} is served with expires header" do
          get uri
          assert_success
          assert_expires
        end
      end

      def build_no_expires_test(uri)
        test "uri #{uri} is served without expires header" do
          get uri
          assert_success
          assert_no_expires
        end
      end

      def build_not_found_test(uri)
        test "uri #{uri} is served with expires header" do
          get uri
          assert_status(404)
          assert_no_expires
          assert_no_cache
        end
      end

      def build_etag_test(uri)
        [false, true].each do |gzip_enabled|
          test "uri #{uri} is served with consistent etag header #{gzip_enabled ? 'with' : 'without'} gzip" do
            etags = []
            3.times do
              get uri, gzip_enabled ? with_gzip : {}
              assert_gzip if gzip_enabled && uri =~ /\.(js|css)/ # images, for example, won't get compressed
              assert_success
              assert_valid_etag(gzip_enabled)
              etags << response.get_header('ETag')
            end
            # assert all the etags were the same:
            assert_equal(1, etags.uniq.size, "Got multiple different etags: #{etags.inspect}")

            etag = etags.first
            get uri, (gzip_enabled ? with_gzip : {}).merge({'If-None-Match' => etag})
            assert_status(304)
            assert_valid_etag(gzip_enabled)
            assert_equal(etag, response.get_header('ETag'))
          end
        end

        test "uri #{uri} is served with a different etag header for gzip vs. non-gzip" do
          get uri, with_gzip
          assert_valid_etag(true)
          etag_with_gzip = response.get_header('ETag')

          get uri
          assert_valid_etag(false)
          etag_without_gzip = response.get_header('ETag')

          assert_not_equal(etag_without_gzip, etag_with_gzip)
        end
      end

      def build_no_cache_test(uri)
        test "uri #{uri} is served with Cache-Control value of no-cache" do
          get uri
          assert_success
          assert_no_cache
        end
      end

      def build_no_transform_test(uri)
        test "uri #{uri} is served with Cache-Control value including no-transform" do
          get uri
          assert_success
          assert_no_transform
        end
      end

      def build_not_no_transform_test(uri)
        test "uri #{uri} is served with Cache-Control value that does not include no-transform" do
          get uri
          assert_success
          assert_not_no_transform
        end
      end

      def build_redirect_test(uri)
        test "uri #{uri} responds with a 302 redirect" do
          get uri
          assert_status(302)
        end
      end
    end
  end
end
