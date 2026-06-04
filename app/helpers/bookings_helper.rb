module BookingsHelper
  def booking_status_translation(status)
    case status
    when 'pending'
      'Ожидает подтверждения'
    when 'confirmed'
      'Подтверждено'
    when 'completed'
      'Завершено'
    when 'cancelled'
      'Отменено'
    else
      status
    end
  end
  
  def booking_status_badge_class(status)
    case status
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'confirmed'
      'bg-green-100 text-green-800'
    when 'completed'
      'bg-blue-100 text-blue-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end