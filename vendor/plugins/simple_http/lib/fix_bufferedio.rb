# -*- encoding : utf-8 -*-
module Net
  class BufferedIO
  private
    def rbuf_fill
      timeout(@read_timeout) do
        @rbuf << @io.readpartial(1024)
      end
    end
  end
end
