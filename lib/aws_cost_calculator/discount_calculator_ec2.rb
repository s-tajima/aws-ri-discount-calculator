require 'pp'
require 'json'
require 'net/http'
require 'csv'


class DiscountCalculatorEC2
  def initialize(price_list_api = nil)
    @rows = []
    @price_list_api = price_list_api
  end

  def parse(row)
    parsed = {}

    parsed['linked_account_id'] = row[2]
    parsed['usage_type']        = row[15]
    parsed['instance_type']     = detect_instance_type(row)
    parsed['os']                = detect_os(row)
    parsed['usage_quantity']    = row[21]
    parsed['blended_rate']      = row[22]
    parsed['tax_amount']        = row[26]
    parsed['total_cost']        = row[28]

    @rows << parsed
  end

  def calc
    result = {}

    @rows.each do |row|
      result[row['linked_account_id']] = 0 if result[row['linked_account_id']].nil?

      ondemand_price = @price_list_api.find_ec2_ondemand_price_by_csv_data(row['usage_type'], row['os'])
      discount = ( ondemand_price - row['blended_rate'].to_f ) * row['usage_quantity'].to_f

      result[row['linked_account_id']] += discount
    end

    result
  end

  def detect_instance_type(row)
    row[15] =~ /:([\w\.]+)/
    return $1 unless $1.nil?

    row[18] =~ /([\w\.]+)\s+instance-hour/
    return $1 unless $1.nil?

    row[18] =~ /([\w\.]+)\s+Instance\s+Hour/
    return $1 unless $1.nil?

    raise RuntimeError, "Unexpected row error. 'UsageType: #{row[15]}' 'ItemDescription: #{row[18]}'"
  end

  def detect_os(row)
    row[18] =~ /On Demand\s+([\w\.]+)\s+/
    return $1 unless $1.nil?

    row[18] =~ /Dedicated Usage\s+([\w\.]+)\s+/
    return $1 unless $1.nil?

    row[18] =~ /Dedicated\s+([\w\.]+)\s+/
    return $1 unless $1.nil?

    row[18] =~ /per\s+([\w]+)\/UNIX\s+\(Amazon VPC\),\s+/
    return $1 unless $1.nil?

    raise RuntimeError, "Unexpected row error. 'ItemDescription: #{row[18]}'"
  end
end
