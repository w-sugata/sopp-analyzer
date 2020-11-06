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


def outcome(filename)
    result = Hash.new(0)
    all_outcomes = Set.new
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        outcome = row['outcome']
        all_outcomes.add outcome 
        result[outcome] += 1
    end
        all_outcomes.to_a.sort.each do |outcome|
            puts "#{outcome} #{result[outcome]}"
        end
end 

class Numeric
    def percent_of(n)
      self.to_f / n.to_f * 100.0
    end
end

def outcome_by_race(filename)
    result = Hash.new(0)
    all_outcomes = Set.new
    arrest = 0 
    citation = 0
    citation = 0
    warning = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        race = row['subject_race']
        outcome = row['outcome']
        all_outcomes.add outcome 
        if !result.key?(race)
            result[race] = Hash.new(0)
            result[race][outcome] += 1
        elsif !result[race].key?(outcome)
            result[race][outcome] += 1
        else
            result[race][outcome] += 1
        end 

        if outcome == "arrest"
            arrest += 1
        elsif outcome == "citation"
            citation += 1
        else
            warning += 1
        end

    end 
    result.delete_if {|x| x == "NA"}
    result.each do |race, outcome|
        puts "#{race}"
        all_outcomes.to_a.sort.each do |outcome|
            if outcome == "arrest"
                puts "\t#{outcome} #{result[race][outcome]} - #{result[race][outcome].percent_of arrest} %"
            elsif outcome == "citation"
                puts "\t#{outcome} #{result[race][outcome]} - #{result[race][outcome].percent_of citation} %"
            else
                puts "\t#{outcome} #{result[race][outcome]} - #{result[race][outcome].percent_of warning} %"
            end
        end
    end 
end

def outcome_by_sex(filename)
    result = Hash.new(0)
    all_outcomes = Set.new 
    arrest = 0 
    citation = 0
    citation = 0
    warning = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        sex = row['subject_sex']
        outcome = row['outcome']
        all_outcomes.add outcome 
        if !result.key?(sex)
            result[sex] = Hash.new(0)
            result[sex][outcome] += 1
        elsif !result[sex].key?(outcome)
            result[sex][outcome] += 1
        else
            result[sex][outcome] += 1
        end 

        if outcome == "arrest"
            arrest += 1
        elsif outcome == "citation"
            citation += 1
        else
            warning += 1
        end
    end 
    result.each do |sex, outcome|
        puts "#{sex}"
        all_outcomes.to_a.sort.each do |outcome|
            if outcome == "arrest"
                puts "\t#{outcome} #{result[sex][outcome]} - #{result[sex][outcome].percent_of arrest} %"
            elsif outcome == "citation"
                puts "\t#{outcome} #{result[sex][outcome]} - #{result[sex][outcome].percent_of citation} %"
            else
                puts "\t#{outcome} #{result[sex][outcome]} - #{result[sex][outcome].percent_of warning} %"
            end        
        end
    end 
end

def age_statistics(filename)
    sum = 0.0
    meanint = 0.0
    result = Hash.new(0)
    total = 0 
    sum = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        age = row['subject_age']
        result[age] += 1  
        total += 1
        sum += age.to_i
        #result[row['subject_age']] += 1
    end
    result.delete_if {|x| x == "NA"}
    puts  "min: #{result.min}"
    puts  "max: #{result.max}"

    mean = sum / total
    puts "mean: #{mean}"

    sorted = result.sort
    mid = result.size/2 
    puts "median: #{sorted[mid]}"
end

def arrest_by_race(filename)
    result = Hash.new(0)
    all_arrest = Set.new
    white = 0
    asian_pacific = 0
    black = 0
    other = 0
    hispanic = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        race = row['subject_race']
        arrest = row['arrest_made']
        all_arrest.add arrest 
        if !result.key?(race)
            result[race] = Hash.new(0)
            result[race][arrest] += 1
        elsif !result[race].key?(arrest)
            result[race][arrest] += 1
        else
            result[race][arrest] += 1
        end 

        if race == "white"
            white += 1
        elsif race == "asian/pacific islander"
            asian_pacific += 1
        elsif race == "black"
            black += 1
        elsif race == "other"
            other += 1
        else race == "hispanic"
            hispanic += 1 
        end
    end 
    result.delete_if {|x| x == "NA"}
    result.each do |race, arrest|
        puts "#{race}"
        all_arrest.to_a.sort.each do |arrest|
            if race == "white"
                puts "\t#{arrest} #{result[race][arrest].percent_of white}%"
            elsif race == "asian/pacific islander"
                puts "\t#{arrest} #{result[race][arrest].percent_of asian_pacific}%"
            elsif race == "black"
                puts "\t#{arrest} #{result[race][arrest].percent_of black}%"
            elsif race == "other"
                puts "\t#{arrest} #{result[race][arrest].percent_of other}%"
            else  
                puts "\t#{arrest} #{result[race][arrest].percent_of hispanic}%"
            end
        end
    end 
end

def search_by_race(filename)
    result = Hash.new(0)
    all_searchs = Set.new
    white = 0
    asian_pacific = 0
    black = 0
    other = 0
    hispanic = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        race = row['subject_race']
        search = row['search_conducted']
        all_searchs.add search 
        if !result.key?(race)
            result[race] = Hash.new(0)
            result[race][search] += 1
        elsif !result[race].key?(search)
            result[race][search] += 1
        else
            result[race][search] += 1
        end 

        if race == "white"
            white += 1
        elsif race == "asian/pacific islander"
            asian_pacific += 1
        elsif race == "black"
            black += 1
        elsif race == "other"
            other += 1
        else race == "hispanic"
            hispanic += 1 
        end
    end 
    result.delete_if {|x| x == "NA"}
    result.each do |race, search|
        puts "#{race}"
        all_searchs.to_a.sort.each do |search|
            if race == "white"
                puts "\t#{search} #{result[race][search].percent_of white}%"
            elsif race == "asian/pacific islander"
                puts "\t#{search} #{result[race][search].percent_of asian_pacific}%"
            elsif race == "black"
                puts "\t#{search} #{result[race][search].percent_of black}%"
            elsif race == "other"
                puts "\t#{search} #{result[race][search].percent_of other}%"
            else  
                puts "\t#{search} #{result[race][search].percent_of hispanic}%"
            end
        end
    end 
end

def age_groups(filename)
    young = 0 
    middle = 0
    old = 0
    total = 0 
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        age = row['subject_age']
        if age.to_i <= 35
            young += 1
        elsif age.to_i >= 36 && age.to_i <= 55
            middle += 1
        else 
            old += 1
        end

        total += 1
    end 
    puts "young: #{young} - #{young.percent_of total}%"
    puts "middle: #{middle} - #{middle.percent_of total}%"
    puts "old: #{old} - #{old.percent_of total}%"
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
    ca = 'ca_stockton_2020_04_01.csv'
    cashort = 'ca_stockton_short.csv'
    ct = 'ct_hartford_2020_04_01.csv'
    ctshort = 'ct_hartford_short.csv'
    
    #p outcome(ct)
    #p outcome_by_race(ct)
    #p outcome_by_sex(ct)
    p age_statistics(ca)
    #p arrest_by_race(ct)
    #p search_by_race(ct)
    #p age_groups(ct)
    
    
end