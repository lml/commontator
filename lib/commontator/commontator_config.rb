require_relative 'config'

class Commontator::CommontatorConfig
  Commontator::Config::COMMONTATOR_ATTRIBUTES.each do |attribute|
    attr_accessor attribute
  end

  def initialize(options = {})
    Commontator::Config::COMMONTATOR_ATTRIBUTES.each do |attribute|
      self.send attribute.to_s + '=', options[attribute] || Commontator.send(attribute)
    end
  end
end
