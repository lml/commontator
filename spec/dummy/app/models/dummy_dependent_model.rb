class DummyDependentModel < ActiveRecord::Base
  acts_as_commontable({}, :destroy)
end

