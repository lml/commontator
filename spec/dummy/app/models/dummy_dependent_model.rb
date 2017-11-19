class DummyDependentModel < ActiveRecord::Base
  acts_as_commontable dependent: :destroy
end

