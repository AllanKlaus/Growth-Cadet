class Hostname < ApplicationRecord
  has_and_belongs_to_many :dns_records

  validates :hostname, presence: true, uniqueness: true

  def self.search(limit, offset, included, excluded)
    result = self
    result = result.where(hostname: included.split(',')) if included.present?
    result = result.where.not(hostname: excluded.split(',')) if excluded.present?

    result.limit(limit).offset(offset)
  rescue StandardError
    []
  end
end
