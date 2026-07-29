class Client < ApplicationRecord
  include BranchScoped

  belongs_to :branch, optional: true
  has_many :leads, dependent: :nullify
  has_many :tasks, dependent: :nullify

  validates :name, presence: true

  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where("name ILIKE :q OR phone ILIKE :q OR email ILIKE :q", q: pattern)
  end
end
