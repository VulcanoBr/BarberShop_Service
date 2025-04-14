class Service < ApplicationRecord

  has_many :appointments, dependent: :restrict_with_error

  validates :name, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(active: true) }

  def name_with_price
    "#{name} - R$ #{'%.2f' % price}".tr('.', ',')
  end


end
