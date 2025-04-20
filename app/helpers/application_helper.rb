module ApplicationHelper

  include Pagy::Frontend

  def format_date_br(date)
    #l(date, format: :with_weekday)
      return unless date

      # Converte string para Date se necessário
      date_object = date.is_a?(String) ? Date.parse(date) : date
      l(date_object, format: :with_weekday)
    rescue ArgumentError
      date.to_s # Fallback para mostrar a string original se a conversão falhar
  end

  def format_price(price)
    return unless price

    number_to_currency(price, unit: "R$ ", separator: ",", delimiter: ".")
  end

end
