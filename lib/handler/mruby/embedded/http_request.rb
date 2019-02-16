# Copyright (c) 2015-2016 DeNA Co., Ltd., Kazuho Oku
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

module H2O

  class HttpRequest
    def join
      if !@resp
        @resp = _h2o__http_join_response(self)
      end
      @resp
    end

    def _set_response(resp)
      @resp = resp
    end

    def self.body_fiber_proc
      proc {|body, req|
        fiber = Fiber.new do
          sleep 0
          begin
            chunk = ''
            while body.read(4096, chunk)
              req._write_chunk(chunk)
            end
            _h2o__http_request_write_eos(req)
          rescue => e
            _h2o__http_request_write_cancel(req)
          end
        end
        fiber.resume
      }
    end
  end


  class HttpInputStream
    def each
      first = true
      while c = _h2o__http_fetch_chunk(self, first)
        yield c
        first = false
      end
    end
    def join
      s = ""
      each do |c|
        s << c
      end
      s
    end

    class Empty < HttpInputStream
      def each; end
    end
  end

end
