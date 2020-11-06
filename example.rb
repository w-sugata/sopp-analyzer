require 'csv'
require 'set'
require 'date'
require 'time'

# processing data from Stanford Open Policing Project data:
# https://openpolicing.stanford.edu/data/


def outcome_types(filename)
    result = Set.new
    # Note that:
    # %i[numeric date] == [:numeric, :date]
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result << row['outcome']
    end
    return result
end


def outcome_types2(filename)
    # uses inject in a clever way!
    result = CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
    return result
end

def outcome_types3(filename)
    # can just return the result of the inject() call
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
end


def any_type_set(filename, key)
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row[key]
    end
end


def day_of_week(filename)
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        date = row['date']
        result[date.cwday] += 1
    end
    return result
end


def any_type_hash(filename, key)
    # key is the name of any column header for a row
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result[row[key]] += 1
    end
    return result
end


def cwday(date)
    return date.cwday
end


def hour(time)
    return time.split(':')[0].to_i
end


def any_type_hash2(filename, key, func=nil)
    # func is a function that does more processing on a column value
    # so for example, we may want to convert a time like "19:30:56" to just 19
    # or get the day of the week for a date like "2017-03-12"
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
    end
    return result
end


def any_type_hash3(filename, key, func=nil)
    # Using inject() is tricky with a Hash
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Hash.new(0)) do |result, row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
        # THIS LINE IS NECESSARY! inject() needs a return value after processing
        # each row to assign to the next version of result
        result
    end
end


def parse_all(filename)
    outcomes = Hash.new(0)
    days = Hash.new(0)
    hours = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        outcomes[row['outcome']] += 1
        days[row['date'].cwday] += 1
        hours[hour(row['time'])] += 1
    end
    puts outcomes
    puts days
    puts hours
end


if __FILE__ == $0
    az = 'az_mesa_2020_04_01.csv'
    azshort = 'az_mesa_short.csv'
    vt = 'vt_burlington_2020_04_01.csv'
    vt = 'vt_burlington_short.csv'
    wy = 'wy_statewide_2020_04_01.csv'

    p outcome_types(vt)
    #p outcome_types2(vt)
    #p outcome_types3(vt)
    #p any_type_set(vt, 'outcome')
    #p any_type_set(vt, 'raw_race')
    #p any_type_set(vt, 'subject_race')
    
    #p day_of_week(vt) 
    #p day_of_week(vt).sort_by(&:first).map(&:last)

    #p any_type_hash(vt, 'outcome')

    #p any_type_hash2(vt, 'date', method(:cwday)).sort_by(&:first).map(&:last)
    #p any_type_hash2(vt, 'outcome')
    #p any_type_hash2(vt, 'violation')
    #p any_type_hash2(vt, 'time', method(:hour)).sort_by(&:first).map(&:last)

    #parse_all(vt)

end