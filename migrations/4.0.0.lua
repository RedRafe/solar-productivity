local Queue = require 'scripts.queue'

storage.to_update = storage.to_update or Queue.new()
storage.to_downgrade = storage.to_downgrade or Queue.new()
