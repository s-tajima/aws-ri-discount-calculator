require 'spec_helper'

describe 'calc' do
  before do
  end

  it "calc_tsv" do
    cc = CostCalculator.new('./spec/testdata/XXXXXXXXXXXX-aws-billing-csv-2016-09.csv', 'tsv')
    cc.calc

    expect = <<-'EOS'.gsub(/^\s+/, "")
    account_id	csv_total_cost	ec2_discount	rds_discount
    AAA537138AAA	7084.31	1119.75	353.856
    BBB518789BBB	479.835	69.067	0.0
    CCC226139CCC	340.099	130.455	139.287
    DDD692482DDD	478.788	47.254	0.0
    EEE074568EEE	208.358	4.555	0.0
    FFF753868FFF	237.353	72.777	0.0
    XXX617649XXX	9192.149	293.354	0.0
    YYY449327YYY	6471.901	734.131	139.287
    ZZZ191002ZZZ	2679.639	611.243	101.647
    EOS

    expect(cc.output).to eq(expect)
  end

  it "calc_table" do
    cc = CostCalculator.new('./spec/testdata/XXXXXXXXXXXX-aws-billing-csv-2016-09.csv', 'table')
    cc.calc

    expect = <<-'EOS'.gsub(/\s+/, "")
    +--------------+----------------+--------------+--------------+
    | account_id   | csv_total_cost | ec2_discount | rds_discount |
    +--------------+----------------+--------------+--------------+
    | AAA537138AAA | $7084.31       | $1119.75     | $353.856     |
    | BBB518789BBB | $479.835       | $69.067      | $0.0         |
    | CCC226139CCC | $340.099       | $130.455     | $139.287     |
    | DDD692482DDD | $478.788       | $47.254      | $0.0         |
    | EEE074568EEE | $208.358       | $4.555       | $0.0         |
    | FFF753868FFF | $237.353       | $72.777      | $0.0         |
    | XXX617649XXX | $9192.149      | $293.354     | $0.0         |
    | YYY449327YYY | $6471.901      | $734.131     | $139.287     |
    | ZZZ191002ZZZ | $2679.639      | $611.243     | $101.647     |
    | ------------ | -------------- | ------------ | ------------ |
    | total        | $27172.431     | $3082.586    | $734.078     |
    +--------------+----------------+--------------+--------------+
    EOS

    expect(cc.output.render.gsub(/\s+/, "")).to eq(expect)
  end
end

