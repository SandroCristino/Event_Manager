require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

def sort_phone(phone)
    phone_length = phone.to_s.length

    if phone_length < 10 || phone_length > 11
        return 
    elsif phone.to_s[0].to_i != 1 && phone_length == 11
        return
    elsif phone.to_s[0].to_i == 1 && phone_length == 11
        return phone.to_s[1..10].to_i
    else
        return phone
    end
end

def find_peak_registration(regdate)

  # Seperate input
  date, time = regdate.split(' ')

  # Calculate weekday
  d = Date.strptime(date, '%m/%d/%y')
  weekday = d.strftime('%A')

  # Calculate hours
  t = Time.strptime(time, '%H:%M')
  hour = t.hour

  # Return date and time
  return weekday, hour

end

def calculate_peak(weekday, hour, registration_weekday, registration_hours)

  # Store the values in the respective hashes
  registration_weekday[weekday] += 1
  registration_hours[hour] += 1
end

def print_peak(registration_hours, registration_weekday)

  # Get highest weekday
  highest_weekday = registration_weekday.max_by {|_,count| count}[0]

  # Get highest hour
  highest_hour = registration_hours.max_by { |_,count | count}[0]

  # Print
  puts "Highest weekday: #{highest_weekday}"
  puts "Highest hour:  #{highest_hour}:00 o'clock"
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

# Create Hash from date and time to get peak
registration_weekday = Hash.new(0)
registration_hours = Hash.new(0)

contents.each do |row|
    id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  phone = sort_phone(row[:homephone].to_s.gsub(/[-().\s]/, '').to_i)

  form_letter = erb_template.result(binding)

  # Create output
  save_thank_you_letter(id, form_letter)

  # Calcualte day and hour
  weekday, hour = find_peak_registration(row[:regdate])

  # Calculate peak
  calculate_peak(weekday, hour, registration_weekday, registration_hours)

end

print_peak(registration_hours,registration_weekday)

