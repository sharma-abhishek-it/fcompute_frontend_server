module FDataUtilsHelper

  def self.fill_blank_fdata(f_data)
    data = f_data.dup
    previous_date, previous_value = nil, nil

    data.each_with_index do |d, i|
      date, todays_stock_value = d
      date = Date.new(*date.split('-').map{ |a| a.to_i })

      diff_days = (date - previous_date).to_i unless previous_date.nil?

      if previous_date.nil? or diff_days == 1
        data[i] = todays_stock_value
      elsif diff_days > 1
        data[i] = [previous_value]*(diff_days-1) # repeat the value of previous date for blank days
        data[i].push todays_stock_value
      end

      previous_date, previous_value = date, todays_stock_value
    end

    data = data.flatten
  end
end
