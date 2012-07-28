module Commontator
  class Engine < ::Rails::Engine
    isolate_namespace Commontator
    
    config.active_record.observers = :comment_observer
  end
end
