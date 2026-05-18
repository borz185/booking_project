namespace :photos do
  desc "Загрузить фото для отелей и номеров"
  task load: :environment do
    # Загрузка фото
    hotels = {
      'Гранд Отель' => 'hotel_grand_moscow_main.jpg',
      'Уютный Уголок' => 'hotel_cozy_spb_main.jpg',
      'Sea View Resort' => 'hotel_seaview_sochi_main.jpg',
      'Бакпэк Хостел' => 'hotel_backpack_kazan_main.jpg',
      'Роял Палас' => 'hotel_royal_dubai_main.jpg',
      'Солнечный Берег' => 'hotel_sunny_anapa_main.jpg'
    }

    hotels.each do |name, filename|
      hotel = Hotel.find_by(name: name)
      next unless hotel

      path = Rails.root.join('tmp', 'images', 'hotels', filename)
      if File.exist?(path)
        # Удаляем старое фото если есть
        hotel.main_photo.purge if hotel.main_photo.attached?
        
        hotel.main_photo.attach(
          io: File.open(path),
          filename: filename,
          content_type: 'image/jpeg'
        )
        puts "Загружено фото для отеля: #{name}"
      else
        puts "Файл не найден: #{path}"
      end
    end

    # Загрузка фото номеров
    rooms_config = {
      # Гранд Отель - 3 номера
      { hotel: 'Гранд Отель', room_number: '101' } => [
        'room_grand_101_1_bed.jpg',
        'room_grand_101_2_desk.jpg',
        'room_grand_101_3_bath.jpg'
      ],
      { hotel: 'Гранд Отель', room_number: '102' } => [
        'room_grand_102_1_view.jpg',
        'room_grand_102_2_bed.jpg',
        'room_grand_102_3_amenities.jpg'
      ],
      { hotel: 'Гранд Отель', room_number: '201' } => [
        'room_grand_201_1_living.jpg',
        'room_grand_201_2_bedroom.jpg',
        'room_grand_201_3_balcony.jpg'
      ],
      
      # Уютный Уголок - 2 номера
      { hotel: 'Уютный Уголок', room_number: '101' } => [
        'room_cozy_101_1_bed.jpg',
        'room_cozy_101_2_corner.jpg',
        'room_cozy_101_3_bath.jpg'
      ],
      { hotel: 'Уютный Уголок', room_number: '102' } => [
        'room_cozy_102_1_family.jpg',
        'room_cozy_102_2_beds.jpg',
        'room_cozy_102_3_window.jpg'
      ],
      
      # Sea View Resort - 1 номер
      { hotel: 'Sea View Resort', room_number: '301' } => [
        'room_seaview_301_1_seaview.jpg',
        'room_seaview_301_2_terrace.jpg',
        'room_seaview_301_3_jacuzzi.jpg'
      ],
      
      # Бакпэк Хостел - 1 номер
      { hotel: 'Бакпэк Хостел', room_number: 'Dorm-1' } => [
        'room_backpack_dorm1_1_beds.jpg',
        'room_backpack_dorm1_2_lockers.jpg',
        'room_backpack_dorm1_3_common.jpg'
      ],
      
      # Роял Палас - 1 номер
      { hotel: 'Роял Палас', room_number: 'VIP-101' } => [
        'room_royal_vip101_1_suite.jpg',
        'room_royal_vip101_2_luxury.jpg',
        'room_royal_vip101_3_skyline.jpg'
      ],
      
      # Солнечный Берег - 1 номер
      { hotel: 'Солнечный Берег', room_number: 'Fam-1' } => [
        'room_sunny_fam1_1_twobeds.jpg',
        'room_sunny_fam1_2_kitchen.jpg',
        'room_sunny_fam1_3_balcony.jpg'
      ]
    }

    rooms_config.each do |key, filenames|
      hotel = Hotel.find_by(name: key[:hotel])
      next unless hotel
      
      room = Room.find_by(hotel: hotel, room_number: key[:room_number])
      next unless room

      # Удаляем старые фото если есть
      room.photos.purge_all if room.photos.attached?

      loaded_count = 0
      filenames.each do |filename|
        path = Rails.root.join('tmp', 'images', 'rooms', filename)
        if File.exist?(path)
          room.photos.attach(
            io: File.open(path),
            filename: filename,
            content_type: 'image/jpeg'
          )
          loaded_count += 1
        else
          puts "Файл не найден: #{path}"
        end
      end
      
      if loaded_count > 0
        puts "Загружено #{loaded_count} фото для номера #{room.room_number} (#{hotel.name})"
      end
    end

    # === СТАТИСТИКА ===
    puts "\nИтого загружено:"
    puts "  Отелей с фото: #{Hotel.select { |h| h.main_photo.attached? }.count}/#{Hotel.count}"
    puts "  Номеров с фото: #{Room.select { |r| r.photos.attached? }.count}/#{Room.count}"
    total_photos = Room.all.sum { |r| r.photos.count }
    puts "  Всего фото номеров: #{total_photos}"
  end
end