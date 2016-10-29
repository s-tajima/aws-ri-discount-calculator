require 'pp'
require 'json'
require 'yaml'
require 'csv'
require 'net/http'
require 'terminal-table'

class CostCalculator
  def initialize(csv, format)
    @csv = CSV.read(csv)
    @format = format ||= 'table'
    @price_list_api = PriceListAPI.new
  end

  def calc
    @csv_total_cost   = calc_csv_total_cost
    @csv_ec2_discount = calc_csv_ec2_ri_discount
    @csv_rds_discount = calc_csv_rds_ri_discount
  end

  def calc_csv_total_cost
    total = {}

    @csv.each do |row|
      next unless row[3] == 'AccountTotal'
      total[row[2]] = row[28]
    end
    total
  end

  def calc_csv_ec2_ri_discount
    dc_ec2 = DiscountCalculatorEC2.new(@price_list_api)

    @csv.each do |row|
      next if     row[2].empty?
      next unless row[12] == 'AmazonEC2'
      next unless row[16] == 'RunInstances'
      dc_ec2.parse(row)
    end

    dc_ec2.calc
  end

  def calc_csv_rds_ri_discount
    dc_rds = DiscountCalculatorRDS.new(@price_list_api)

    @csv.each do |row|
      next if     row[2].empty?
      next unless row[12] == 'AmazonRDS'
      next unless row[15] =~ /(InstanceUsage|Multi-AZUsage)/
      next unless row[16] =~ /^CreateDBInstance/
      dc_rds.parse(row)
    end

    dc_rds.calc
  end

  def output
    self.send("output_#{@format}")
  end

  def output_tsv
    header = ""
    header << "account_id\t"
    header << "csv_total_cost\t"
    header << "ec2_discount\t"
    header << "rds_discount\n"

    rows = ""
    @csv_total_cost.sort.each do |id, t|
      rows << id + "\t"
      rows << t.to_f.round(3).to_s  + "\t"
      rows << @csv_ec2_discount[id].to_f.round(3).to_s + "\t"
      rows << @csv_rds_discount[id].to_f.round(3).to_s + "\n"
    end

    header + rows
  end

  def output_table
    header = []
    header << [ "account_id", "csv_total_cost", "ec2_discount", "rds_discount" ]

    rows = []
    @csv_total_cost.sort.each do |id, t|
      row = []
      row << id
      row << "$" + t.to_f.round(3).to_s
      row << "$" + @csv_ec2_discount[id].to_f.round(3).to_s
      row << "$" + @csv_rds_discount[id].to_f.round(3).to_s
      rows << row
    end

    rows << [ "------------", "--------------", "------------", "------------" ]

    row = []
    row << "total"
    row << "$" + @csv_total_cost.values.inject(0.0){|s, v| s + v.to_f }.round(3).to_s
    row << "$" + @csv_ec2_discount.values.inject(0.0){|s, v| s + v.to_f }.round(3).to_s
    row << "$" + @csv_rds_discount.values.inject(0.0){|s, v| s + v.to_f }.round(3).to_s
    rows << row

    Terminal::Table.new({:headings => header, :rows => rows})
  end
end
