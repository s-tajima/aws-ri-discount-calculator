# AWS Reserved Instance discount calculator

aws-ri-discount-calculator calcurates Reserved Instance discount 
by [monthly report csv](http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/detailed-billing-reports.html#monthly-report).

[![Build Status](https://travis-ci.org/s-tajima/aws-ri-discount-calculator.svg?branch=master)](https://travis-ci.org/s-tajima/aws-ri-discount-calculator)

```
$ bundle exec bin/calc ./PATH_TO_REPORT/AAA775901AAA-aws-billing-csv-YYYY-MM.csv
+--------------+----------------+--------------+--------------+
| account_id   | csv_total_cost | ec2_discount | rds_discount |
+--------------+----------------+--------------+--------------+
| AAA775901AAA | $100.123       | $20.111      | $10.987      |
| BBB748336BBB | $500.03        | $100.456     | $0.0         |
| CCC061764CCC | $10.149        | $0.0         | $0.0         |
| ...          | ...            | ...          | ...          |
| ZZZ654481ZZZ | $1358.917      | $479.434     | $240.934     |
| ------------ | -------------- | ------------ | ------------ |
| total        | $3470.013      | $850.62      | $450.0       |
+--------------+----------------+--------------+--------------+
```

## Index

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [How does it work](#how does it work)
* [Notes](#notes)
* [License](#license)

## Requirements

aws-ri-discount-calculator requires the following to run:

* Ruby
* [Monthly report csv](http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/detailed-billing-reports.html#monthly-report).

※ No IAM credential required.

## Installation

```
$ git clone <this repository url>
$ cd aws-ri-discount-calculator
$ bundle install
```

## Usage

* table output
```
$ bundle exec bin/calc ./PATH_TO_REPORT/AAA775901AAA-aws-billing-csv-YYYY-MM.csv
+--------------+----------------+--------------+--------------+
| account_id   | csv_total_cost | ec2_discount | rds_discount |
+--------------+----------------+--------------+--------------+
| AAA775901AAA | $100.123       | $20.111      | $10.987      |
| BBB748336BBB | $500.03        | $100.456     | $0.0         |
| CCC061764CCC | $10.149        | $0.0         | $0.0         |
| ...          | ...            | ...          | ...          |
| ZZZ654481ZZZ | $1358.917      | $479.434     | $240.934     |
| ------------ | -------------- | ------------ | ------------ |
| total        | $3470.013      | $850.62      | $450.0       |
+--------------+----------------+--------------+--------------+
```

* tsv output (for paste Excel etc...)
```
$ bundle exec bin/calc ./PATH_TO_REPORT/AAA775901AAA-aws-billing-csv-YYYY-MM.csv
account_id	csv_total_cost	ec2_discount	rds_discount
AAA775901AAA	$100.123	$20.111	$10.987
BBB748336BBB	$500.03	$100.456	$0.0
CCC061764CCC	$10.149	$0.0	$0.0
...	...	...	...
ZZZ654481ZZZ	$1358.917	$479.434	$240.934
```

## How does it work

1. Parse monthly report csv.
1. Find line for reserved instance usage. Retrieve BlendedRate, UsageQuantity.
1. Retrieve Ondemand Price by [AWS Price List API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
1. Calculate `(Ondemand Price - BlendedRate) * UsageQuantity`.

## Notes

* Implemented services are EC2 RDS only.
* XXX_discount columns DON'T include(subtract) purchase costs of RI.

## License

[MIT](./LICENSE)

## Author

[Satoshi Tajima](https://github.com/s-tajima)


