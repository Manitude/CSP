def handle_exception &block
  begin
    yield block
  rescue Exception => ex
    puts ex.message
    logger.error(ex)
    HoptoadNotifier.notify(ex)
  end
end

