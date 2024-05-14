local Queue = require 'scripts.queue'

global.to_update = global.to_update or Queue.new()
global.to_downgrade = global.to_downgrade or Queue.new()
