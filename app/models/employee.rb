class Employee < ApplicationRecord

  scope :active, -> { where(active: true) }

end
