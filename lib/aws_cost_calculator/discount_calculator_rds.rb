require 'pp'
require 'net/http'
require 'csv'


class DiscountCalculatorRDS
  def initialize(price_list_api = nil)
    @rows = []
    @price_list_api = price_list_api
  end

  def parse(row)
    parsed = {}

    parsed['linked_account_id'] = row[2]
    parsed['usage_type']        = row[15]
    parsed['instance_type']     = detect_instance_type(row)
    parsed['database_engine']   = detect_database_engine(row)
    parsed['database_edition']  = detect_database_edition(row)
    parsed['deployment_option'] = detect_deployment_option(row)
    parsed['license_model']     = detect_license_model(row, parsed['database_engine'])
    parsed['usage_quantity']    = row[21]
    parsed['blended_rate']      = row[22]
    parsed['tax_amount']        = row[26]
    parsed['total_cost']        = row[28]
    parsed['raw_row']           = row

    @rows << parsed
  end

  def calc
    result = {}

    @rows.each do |row|
      result[row['linked_account_id']] = 0 if result[row['linked_account_id']].nil?

      ondemand_price = @price_list_api.find_rds_ondemand_price_by_csv_data(row)
      discount = ( ondemand_price - row['blended_rate'].to_f ) * row['usage_quantity'].to_f

      result[row['linked_account_id']] += discount
    end

    result
  end

  def detect_instance_type(row)
    row[15] =~ /:([\w\.]+)$/
    return $1 unless $1.nil?

    raise RuntimeError, "Unexpected row error. 'UsageType: #{row[15]}'"
  end

  def detect_database_engine(row)
    row[18] =~ /running\s+(Amazon Aurora|MySQL|PostgreSQL|SQL Server|Oracle)/
    return $1 unless $1.nil?

    row[18] =~ /(MySQL), db\./
    return $1 unless $1.nil?

    raise RuntimeError, "Unexpected row error. 'ItemDescription: #{row[18]}'"
  end

  def detect_database_edition(row)
    row[18] =~ /running\s+Oracle\s+(EE|SE1|SE2)/
    unless $1.nil?
      case $1
      when "EE"
        return "Enterprise"
      when "SE1"
        return "Standard One"
      when "SE2"
        return "Standard Two"
      end
    end

    ""
  end

  def detect_deployment_option(row)
    row[18] =~ /(Multi-AZ)/
    return $1 unless $1.nil?

    row[15] =~ /(Multi-AZ)/
    return $1 unless $1.nil?

    "Single-AZ"
  end

  def detect_license_model(row, db_engine)
    return "No license required" if db_engine =~ /(MySQL|PostgreSQL|Amazon Aurora)/

    row[18] =~ /running\s+Oracle\s+[\w]+\s+(\(LI\))/
    unless $1.nil?
      case $1
      when "(LI)"
        return "License included"
      when "(BYOL)"
        return "Bring your own license"
      end
    end

    raise RuntimeError, "Unexpected row error. 'ItemDescription: #{row[18]}'"
  end
end
