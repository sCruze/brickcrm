# Базовые роли CRM: роль × права по разделам. Скоуп по филиалу задаётся
# на уровне membership (branch_id: NULL = вся сеть).
read = %w[read]
rw = %w[read write]

roles = [
  {
    key: "system_admin", name: "Системный администратор", system: true,
    permissions: Role.full_permissions
  },
  {
    key: "network_admin", name: "Администратор сети",
    permissions: {
      "dashboard" => read, "leads" => rw + %w[manage], "clients" => rw + %w[manage],
      "tasks" => rw + %w[manage], "calendar" => rw + %w[manage],
      "reports" => rw, "settings" => read, "sync" => read
    }
  },
  {
    key: "branch_admin", name: "Администратор филиала",
    permissions: {
      "dashboard" => read, "leads" => rw, "clients" => rw, "tasks" => rw,
      "calendar" => rw, "reports" => read
    }
  },
  {
    key: "sales_manager", name: "Менеджер продаж",
    permissions: {
      "dashboard" => read, "leads" => rw, "clients" => rw, "tasks" => rw, "calendar" => read
    }
  },
  {
    key: "hr_manager", name: "HR-менеджер",
    permissions: { "dashboard" => read, "clients" => read, "tasks" => rw, "reports" => read }
  }
]

roles.each do |attrs|
  role = Role.find_or_initialize_by(key: attrs[:key])
  role.update!(attrs)
end
puts "Роли: #{Role.count}"

# Первый администратор. В проде поменять пароль после первого входа
# (SSO-аккаунты приходят от провайдера сами, membership им выдаётся вручную).
if User.none?
  admin = User.create!(
    name: "Администратор",
    email: "admin@example.com",
    password: "changeme123"
  )
  admin.memberships.create!(role: Role.find_by!(key: "system_admin"))
  puts "Создан администратор: admin@example.com / changeme123"
end

# Базовая воронка продаж
if Funnel.none?
  funnel = Funnel.create!(name: "Продажи", position: 1)
  [
    [ "Новая заявка", "open" ],
    [ "В работе", "open" ],
    [ "Встреча", "open" ],
    [ "Оплачено", "won" ],
    [ "Отказ", "lost" ]
  ].each_with_index do |(name, kind), index|
    funnel.stages.create!(name: name, kind: kind, position: index + 1)
  end
  puts "Воронка «Продажи»: #{funnel.stages.count} этапов"
end
