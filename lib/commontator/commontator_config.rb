module Commontator
  class CommontatorConfig
    Commontator::COMMONTATOR_CONFIG.keys.each do |attribute|
      cattr_accessor attribute
    end
  
    def initialize(options = {})
      Commontator::COMMONTATOR_CONFIG.keys.each do |attribute|
        self.send attribute.to_s + '=', options[attribute] || Commontator.send(attribute)
      end
    end
  end
end
