module Commontator
  class Engine < ::Rails::Engine
    isolate_namespace Commontator

    # Load subfolders of config/locales as well
    config.i18n.load_path += Dir[root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
