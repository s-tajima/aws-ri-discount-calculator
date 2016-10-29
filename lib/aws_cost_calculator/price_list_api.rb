class PriceListAPI
  AWS_PRICE_LIST_API = 'https://pricing.us-east-1.amazonaws.com'

  def initialize
    @offer_index = JSON.parse(Net::HTTP.get(URI.parse(AWS_PRICE_LIST_API + "/offers/v1.0/aws/index.json")))
    @ec2_offer_file = JSON.parse(Net::HTTP.get(URI.parse(AWS_PRICE_LIST_API + @offer_index["offers"]["AmazonEC2"]["currentVersionUrl"])))
    @rds_offer_file = JSON.parse(Net::HTTP.get(URI.parse(AWS_PRICE_LIST_API + @offer_index["offers"]["AmazonRDS"]["currentVersionUrl"])))
  end

  ###
  # For EC2
  ### 
  def find_ec2_ondemand_price_by_csv_data(usage_type, os)
    skus = @ec2_offer_file["products"].select {|k, v|
      v["attributes"]["usagetype"] == usage_type &&
      v["attributes"]["operatingSystem"] == os }.keys
    check_exactly_one(skus, "skus")
    
    price_details = @ec2_offer_file["terms"]["OnDemand"][skus.first] 
    check_exactly_one(price_details, "price_details")
    
    ondemand_price = price_details.flatten[1]["priceDimensions"].flatten[1]["pricePerUnit"]["USD"].to_f
  end

  ###
  # For RDS
  ### 
  def find_rds_ondemand_price_by_csv_data(row)
    skus = @rds_offer_file["products"].select { |k, v|
      v["attributes"]["usagetype"] == row['usage_type'] &&
      v["attributes"]["deploymentOption"] == row['deployment_option'] &&
      v["attributes"]["databaseEngine"] == row['database_engine'] && 
      v["attributes"]["licenseModel"] == row['license_model'] &&
      ( v["attributes"]["databaseEngine"] =~ /(MySQL|PostgreSQL|Amazon Aurora)/ || v["attributes"]["databaseEdition"] == row['database_edition'] )
    }.keys
    check_exactly_one(skus, "skus")

    price_details = @rds_offer_file["terms"]["OnDemand"][skus.first] 
    check_exactly_one(price_details, "price_details")

    ondemand_price = price_details.flatten[1]["priceDimensions"].flatten[1]["pricePerUnit"]["USD"].to_f
  end

  def check_exactly_one(arr, target)
    if arr.size > 1
      raise RuntimeError, "Multiple #{target} are exists." 
    end

    if arr.size == 0
      raise RuntimeError, "No #{target} are exists." 
    end
  end
end
