class FDataFetcher
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    data = FDataUtilsHelper::FDataFileReader.read_data_from_directory(ENV['FDATA_DIR'])

    unless data.empty?
      data.each do |sector_name, sector_data|
        sector_data.each do |product_name, fData|
          fData = FDataUtilsHelper.fill_blank_fdata(fData)
          data[sector_name][product_name] = fData

          s = Sector.find_or_initialize_by(name: sector_name)
          p = Product.find_or_initialize_by(name: product_name)
          p.data = fData.to_s
          p.sector = s

          s.save!
          p.save!

          RedisCache.connection.with do |redis|
            redis.pipelined do
              redis.sadd("all_sectors", sector_name)
              redis.sadd(sector_name+":Products", product_name)
              redis.hmset(sector_name+":"+product_name, "name", product_name, "data", fData.to_s)
            end
          end
        end
      end

    end
  end
end
