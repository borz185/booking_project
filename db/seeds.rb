Payment.delete_all
Booking.delete_all
Room.delete_all
Hotel.delete_all
User.delete_all

puts "Данные очищены..."

# Пользователи
admin = User.create!(
  username: 'admin',
  email: 'admin@hotel.com',
  password_hash: 'hash_admin_123',
  phone: '+79991111111',
  role: 'admin',
  has_visa: false
)

masha = User.create!(
  username: 'mashylkaaaa',
  email: 'masha@example.com',
  password_hash: 'hash_user_123',
  phone: '+79990000000',
  role: 'user',
  has_visa: false
)

petr = User.create!(
  username: 'petrovich',
  email: 'petr@example.com',
  password_hash: 'hash_petr_123',
  phone: '+79991112233',
  role: 'user',
  has_visa: true
)

anna = User.create!(
  username: 'anna_smith',
  email: 'anna@example.com',
  password_hash: 'hash_anna_123',
  phone: '+79994445566',
  role: 'user',
  has_visa: false
)

puts "Пользователи созданы: #{User.count}"

# Отели
grand_hotel = Hotel.create!(
  name: 'Гранд Отель',
  city: 'Москва',
  country: 'Россия',
  address: 'ул. Ленина 1',
  stars: 5,
  description: 'Роскошный отель в центре города',
  phone: '+74951111111',
  visa_required: false
)

cozy_hotel = Hotel.create!(
  name: 'Уютный Уголок',
  city: 'Санкт-Петербург',
  country: 'Россия',
  address: 'ул. Мира 25',
  stars: 3,
  description: 'Комфортный отель для семейного отдыха',
  phone: '+78122222222',
  visa_required: false
)

sea_hotel = Hotel.create!(
  name: 'Sea View Resort',
  city: 'Сочи',
  country: 'Россия',
  address: 'ул. Морская 15',
  stars: 4,
  description: 'Отель с видом на море',
  phone: '+78623333333',
  visa_required: false
)

puts "Отели созданы: #{Hotel.count}"

# Номера
room1 = Room.create!(
  hotel: grand_hotel,
  room_number: '101',
  room_type: 'Эконом',
  capacity: 2,
  price_per_night: 3500.00,
  description: 'Уютный номер с одной кроватью',
  amenities: ['wifi', 'tv'],
  is_available: true
)

room2 = Room.create!(
  hotel: grand_hotel,
  room_number: '102',
  room_type: 'Стандарт',
  capacity: 2,
  price_per_night: 5500.00,
  description: 'Номер с видом на город',
  amenities: ['wifi', 'tv', 'ac'],
  is_available: true
)

room3 = Room.create!(
  hotel: grand_hotel,
  room_number: '201',
  room_type: 'Люкс',
  capacity: 3,
  price_per_night: 12000.00,
  description: 'Просторный номер с гостиной',
  amenities: ['wifi', 'tv', 'ac', 'minibar', 'safe'],
  is_available: true
)

room4 = Room.create!(
  hotel: cozy_hotel,
  room_number: '101',
  room_type: 'Эконом',
  capacity: 2,
  price_per_night: 2500.00,
  description: 'Бюджетный номер',
  amenities: ['wifi', 'tv'],
  is_available: true
)

room5 = Room.create!(
  hotel: cozy_hotel,
  room_number: '102',
  room_type: 'Стандарт',
  capacity: 3,
  price_per_night: 4000.00,
  description: 'Комфортный номер для семьи',
  amenities: ['wifi', 'tv', 'ac'],
  is_available: true
)

room6 = Room.create!(
  hotel: sea_hotel,
  room_number: '301',
  room_type: 'Люкс',
  capacity: 2,
  price_per_night: 8000.00,
  description: 'Номер с видом на море',
  amenities: ['wifi', 'tv', 'ac', 'minibar', 'balcony'],
  is_available: true
)

puts "Номера созданы: #{Room.count}"

# Бронирования
booking1 = Booking.create!(
  user: masha,
  room: room3,
  check_in_date: '2024-06-01',
  check_out_date: '2024-06-05',
  total_price: 48000.00,
  guests_count: 2,
  status: 'confirmed'
)

booking2 = Booking.create!(
  user: petr,
  room: room1,
  check_in_date: '2024-07-10',
  check_out_date: '2024-07-15',
  total_price: 17500.00,
  guests_count: 2,
  status: 'confirmed'
)

booking3 = Booking.create!(
  user: anna,
  room: room6,
  check_in_date: '2024-08-01',
  check_out_date: '2024-08-10',
  total_price: 80000.00,
  guests_count: 2,
  status: 'pending'
)

puts "Бронирования созданы: #{Booking.count}"

# Платежи
Payment.create!(
  booking: booking1,
  amount: 48000.00,
  payment_method: 'card',
  payment_status: 'paid',
  paid_at: Time.current,
  transaction_id: 'txn_123456789'
)

Payment.create!(
  booking: booking2,
  amount: 17500.00,
  payment_method: 'card',
  payment_status: 'paid',
  paid_at: Time.current,
  transaction_id: 'txn_987654321'
)

Payment.create!(
  booking: booking3,
  amount: 80000.00,
  payment_method: 'cash',
  payment_status: 'pending',
  paid_at: nil,
  transaction_id: nil
)

puts "Платежи созданы: #{Payment.count}"