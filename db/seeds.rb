# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Criar serviços
services = [
  { name: 'Corte Masculino', price: 85.00, duration: 60, description: 'Precisão e estilo para um visual renovado e confiante, com tesoura e máquina' },
  { name: 'Barba', price: 65.00, duration: 60, description: 'Revitalize sua barba com modelagem precisa, tratamento com toalha quente e óleos essenciais.' },
  { name: 'Corte + Barba', price: 155.00, duration: 60, description: 'Combine o corte de cabelo ideal com o cuidado completo da barba, incluindo modelagem e acabamento.' },
  { name: 'Corte Infantil', price: 40.00, duration: 60, description: 'Cortes infantis modernos e clássicos feitos com o cuidado que eles merecem.' },
  { name: 'Sobrancelha', price: 65.00, duration: 60, description: 'Realce seu olhar com nosso design de sobrancelhas masculino.' },
  { name: 'Alisamento Capilar', price: 1235.00, duration: 60, description: 'Controle o volume e o frizz com nosso alisamento capilar profissional. ' },
  { name: 'Coloração Capilar', price: 835.00, duration: 60, description: 'Serviço de coloração masculina para cobertura de grisalhos ou mudança de visual.'},
  { name: 'Corte + Coloração Capilar', price: 635.00, duration: 60, description: 'Renove seu visual com um corte impecável e a coloração ideal.' },
  { name: 'Corte + Barba + Coloração Capilar', price: 1235.00, duration: 60, description: 'Corte moderno, barba perfeitamente alinhada e a coloração capilar ideal para você.' },
  { name: 'Hidratação Capilar', price: 935.00, duration: 60, description: 'Hidratação capilar profunda para restaurar a umidade, maciez e brilho dos seus fios. ' },
  { name: 'Manicure e Pedicure', price: 95.00, duration: 60, description: ' Experimente nossos serviços de manicure e pedicure para um cuidado completo e revigorante.' },
  { name: 'Trança Afro', price: 635.00, duration: 60, description: 'Expresse sua identidade com Tranças Afro autênticas e estilosas. ' }
]
services.each do |service_data|
  Service.create!(service_data)
end

# Criar employee
employees = [
  { name: 'Jaime Rodrigues Cavalheiro', surname: 'Rodrigues', active: true },
  { name: 'Simone Alcantara Neves', surname: 'Simone(manicure/pedicure)', active: true },
  { name: 'Ana Maria Cristina dos Santos', surname: 'Anna(manicure/pedicure)', active: true },
  { name: 'Santos Almeida da Silva', surname: 'Almeida', active: true },
  { name: 'Cristiano Rafael Spincer', surname: 'Spincer', active: true },
  { name: 'Samanta Araujo Palacios', surname: 'Samanta', active: true }
]
employees.each do |employee_data|
  Employee.create!(employee_data)
end

# Criar admin
AdminUser.find_or_create_by!(email: "admin@email.com") do |user|
  user.password = ENV["DEFAULT_PASSWORD"]
  user.password_confirmation = ENV["DEFAULT_PASSWORD"]
end

puts "Seeds criados com sucesso!"
