module ApplicationHelper
  RU_MONTHS = %w[января февраля марта апреля мая июня июля августа сентября октября ноября декабря].freeze
  RU_MONTHS_NOM = %w[Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь].freeze
  RU_MONTHS_SHORT = %w[янв фев мар апр май июн июл авг сен окт ноя дек].freeze
  RU_DAYS = %w[воскресенье понедельник вторник среда четверг пятница суббота].freeze
  RU_DAYS_SHORT = %w[Пн Вт Ср Чт Пт Сб Вс].freeze

  ICONS = {
    "dashboard" => '<rect x="3" y="3" width="7.5" height="7.5" rx="1.6"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1.6"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1.6"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1.6"/>',
    "leads" => '<path d="M4 5h16l-6 7v5.5l-4 2.3V12L4 5Z"/>',
    "clients" => '<circle cx="9" cy="8.5" r="3.2"/><path d="M3.5 19c.6-3.2 2.8-5 5.5-5s4.9 1.8 5.5 5"/><path d="M15.5 6.2a3 3 0 1 1 1.6 5.7"/><path d="M16.8 14.3c2 .5 3.4 2 3.8 4.7"/>',
    "tasks" => '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="m8.5 12.2 2.4 2.4 4.8-5"/>',
    "calendar" => '<rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M3.5 9.5h17M8 3v3.5M16 3v3.5"/>',
    "reports" => '<path d="M4 20v-8M10 20V5M16 20v-11M3 20h18"/>',
    "settings" => '<path d="M4 7h7M17 7h3M4 12h3M11 12h9M4 17h9"/><circle cx="14" cy="7" r="2"/><circle cx="8" cy="12" r="2"/><circle cx="16" cy="17" r="2"/>'
  }.freeze

  def nav_link(title, path, icon: nil, match: :exact)
    active = match == :prefix ? request.path.start_with?(path) : current_page?(path)
    css = "sidebar__link"
    css += " sidebar__link--active" if active
    link_to path, class: css do
      safe_join([ nav_icon(icon), tag.span(title) ].compact)
    end
  end

  def nav_icon(key)
    paths = ICONS[key.to_s]
    return nil unless paths

    %(<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">#{paths}</svg>).html_safe
  end

  # Логотип: монограмма на градиентной плашке
  def brand_mark
    <<~SVG.html_safe
      <svg class="brand-mark" viewBox="0 0 32 32" fill="none" aria-hidden="true">
        <defs>
          <linearGradient id="bm-g" x1="0" y1="0" x2="32" y2="32" gradientUnits="userSpaceOnUse">
            <stop stop-color="#3E7BFA"/>
            <stop offset="1" stop-color="#2440C7"/>
          </linearGradient>
        </defs>
        <rect width="32" height="32" rx="9" fill="url(#bm-g)"/>
        <text x="16" y="22" text-anchor="middle" font-family="Rubik, sans-serif" font-weight="800" font-size="17" fill="#ffffff">B</text>
      </svg>
    SVG
  end

  def ru_today
    date = Date.current
    "#{RU_DAYS[date.wday]}, #{date.day} #{RU_MONTHS[date.month - 1]}"
  end

  def money(amount)
    return "—" if amount.blank? || amount.to_d.zero?

    number_to_currency(amount, unit: "₽", format: "%n %u", delimiter: " ", precision: 0)
  end

  def ru_date_short(date)
    return "" if date.blank?

    "#{date.day} #{RU_MONTHS_SHORT[date.month - 1]}"
  end

  def month_title(date)
    "#{RU_MONTHS_NOM[date.month - 1]} #{date.year}"
  end

  def user_initials(user)
    source = user.name.presence || user.email
    source.split(/[\s@.]+/).reject(&:blank?).map { |word| word[0] }.first(2).join.upcase
  end
end
