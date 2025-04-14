module ApplicationHelper

  include Pagy::Frontend

  def format_date_br(date)
    l(date, format: :with_weekday)
  end

  def format_price(price)
    return unless price

    number_to_currency(price, unit: "R$ ", separator: ",", delimiter: ".")
  end

end
