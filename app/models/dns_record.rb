class DnsRecord < ApplicationRecord
  has_and_belongs_to_many :hostnames
  accepts_nested_attributes_for :hostnames

  validates :ip, presence: true, uniqueness: true

  
  class << self
    def search(limit, offset, included, excluded)
      dns_records = search_query(limit, offset, included, excluded)

      records = dns_records.map { |dns_record| { id: dns_record.id, ip_address: dns_record.ip } }
      related_hostnames = related_hostnames(dns_records, included, excluded)

      { records: records, related_hostnames: related_hostnames }
    rescue StandardError
      { records: [], related_hostnames: [] }
    end

    private

    def search_query(limit, offset, included, excluded)
      hostname_included = []
      result = self.joins(:hostnames)
  
      if included.present?
        hostname_included = included.split(',')
        result = result.where(hostnames: { hostname: hostname_included })
      end
  
      result = result.group('dns_records.id')
      result = result.having("COUNT(hostnames.id) = #{hostname_included.size}") if included.present?
      result = result.where.not('EXISTS (
                                  SELECT 1
                                  FROM dns_records_hostnames AS hn
                                  INNER JOIN hostnames ON hostnames.id = hn.hostname_id
                                  WHERE hn.dns_record_id = dns_records.id
                                  AND hostnames.hostname IN (?))', excluded.split(',')) if excluded.present?

      result.limit(limit).offset(offset)
    end

    def related_hostnames(dns_records, included, excluded)
      hostnames = []
      hostnames << included&.split(',')
      hostnames << excluded&.split(',')
      hostnames = hostnames.flatten.uniq.compact

      relateds = dns_records.map do |dns_record|
        dns_record.hostnames.reject do |hostname|
          hostnames.include?(hostname.hostname)
        end.map(&:hostname)
      end

      relateds.flatten.tally.map do |related_hostname|
        {
          hostname: related_hostname.first,
          count: related_hostname.last
        }
      end
    end
  end
end
