require 'sinatra'
require	'json'

set :static, true
set :public_folder, "static"
set :views, Proc.new { File.join(root, "../views") } ### make views view!!!!!

get '/' do
	erb :request
end

post '/' do
	query = params[:query] || "No query"
	
	test = Parsed.new(query)
	json = test.parsing(query)
	
	erb :index, :locals => {'json' => json}
end




#Analysis: First split the string based on the characters. We may find a la




class Parsed
	attr_reader :hashMap # the final hashMap that is used to parse to json.
	attr_reader :array
	attr_reader :comparisons
	attr_reader :logics
	attr_reader :booleans
	attr_reader :query
	
	def initialize(query)
		@hashMap = Hash.new(0)
		@array = Array.new
		@comparisons = {">" => {"$gt" => Object}, "<" =>{"$lt" => Object}, "=" =>{"$eq" => Object} ,"len" =>{"$len" => Object}}
		@logics = {"OR" => {"$OR" => Array.new} , "AND" => {"$AND" => Array.new}}
		@booleans = {"true"=> {"$eq" => true},"false" => {"$eq" => false}, "!true" => {"$not" => true}, "!false" => {"$not"=> false}}
		@query = query
	end
	
	
	def parsing(query)
		@hashMap = getBlocks(query)
		puts "test::hashMap is :  #{@hashMap}"
		return JSON.pretty_generate(@hashMap)
		
	end
	
	def getBlocks(query)
		subQuery = query.split()
		puts "subqueries are : #{subQuery}"
		puts "subQuery.length  = #{subQuery.length}"
		strings = Array.new
		compares = Array.new
		bools = Array.new
		parentesisBlock = Array.new
		hashMap = Hash.new
		i = 0
		blocks = Array.new
		stack = Array.new
		while i < subQuery.length 
			puts "while loop, i= #{i}"
			if subQuery[i][0] == "("
			## get a parentesis and it's child parentesis.
				parentesis = Array.new
				parentesis.push(subQuery[i])
				i = i+1
				ret = getParentesisBlock(subQuery,i,parentesis)
				parentesisBlock = ret[0]
				puts "parentesisBlock is :  #{parentesisBlock}"
				i = ret[1]-1
			elsif @logics.has_key?(subQuery[i])
				
				if subQuery[i] == "AND" || hashMap != {}
					i +=1
					next
				else
					hashMap = @logics[subQuery[i]]
				end	
			elsif @comparisons.has_key?(subQuery[i][0])
				puts "comapres are #{compares}"				
				compares.push(subQuery[i])	
			elsif @booleans.has_key?(subQuery[i])
				puts "bools are #{bools}"
				bools.push(subQuery[i])
			else 
				puts "strings are #{strings}"
				strings.push(subQuery[i]) 				
			end	
			i +=1		
		end		
		if hashMap == {}
			hashMap = logics["AND"]
		else
		end
		puts "bools are #{bools}"
		puts "comapres are #{compares}"
		puts "strings are #{strings}"
		puts "parentesisBlock are #{parentesisBlock}"
		addStringBlocks(strings, hashMap)
		addBoolsBlocks(bools, hashMap)
		if compares.length != 0
 			addComapresBlocks(compares, hashMap) ##to do
 		else
 		end
		if parentesisBlock.length != 0
			addParentesisBlock(parentesisBlock, hashMap) 
		else 
		end	
		puts hashMap
		return hashMap			
	end

	
	
	def addParentesisBlock(parentesisBlock,hashMap)
		
			len = parentesisBlock.length
			parentesisBlock[0] = parentesisBlock[0][1, parentesisBlock[0].length-1]
			parentesisBlock[len-1] = parentesisBlock[len-1][0, parentesisBlock[0].length]
			puts parentesisBlock.join(" ") 			
 			hashMap.each_key do |key|
				hashMap[key].push(getBlocks(parentesisBlock.join(" ")))
			end
	end 
	
	
	def addComapresBlocks(compares,hashMap)
		# puts "compares.length is #{compares.length}"
# 		if compares.length == 2
# 			@comparisons[compares[0]] = 2
# 			hashMap.each_key do |key|
# 				hashMap[key].push(@comparisons[compares[0]])
# 			end
# 		else		
# 			i = 0
# 			comHash = @logics["AND"]
# 			while i < compares.length do 
# 				puts i
# 				if @comparisons.has_key?(compares[i]) && i < compares.length
# 					val = compares[i+1]
# 					@comparisons[compares[i]] = val
# 					comHash["$AND"].push(@comparisons[compares[i]])
# 					i +=2
# 				end
# 				i +=1
# 			end
# 			hashMap.each_key do |key|
# 				hashMap[key].push(comHash)
# 			end 
# 		end	
	end


	def addStringBlocks(strings, hashMap)
		hashMap.each_key do |key|
			strings.each do |str|
				hashMap[key].push(str)
			end
		end
	end
	
	def addBoolsBlocks(bools, hashMap)
		boolsHashList = getBoolsHashList(bools)
		hashMap.each_key do |key|
			boolsHashList.each do |boolsHash|
				hashMap[key].push(boolsHash)
			end
		end
	end
	
	def getBoolsHashList(bools)
		boolsHashList = Array.new
		bools.each do |bool|
			boolsHashList.push(@booleans[bool])
		end
		return boolsHashList
	end
	
	
	
	def getParentesisBlock(subQuery,i,parentesis)
		
		return if subQuery == nil || parentesis == nil
		ret = Array.new()
		return ret if subQuery == nil || parentesis == nil
		ret[0] = parentesis
		begin
			if subQuery[i][0] == "("
				subRet = Array.new
				subRet[0].push(subQuery[i])
				parentesis.push(getParentesisBlock(subQuery,i,subRet))
			elsif subQuery[i][subQuery[i].length-1] == ")"
				ret[0].push(subQuery[i])	
			else				
				begin
						i<subQuery.length
						ret[0].push(subQuery[i])
						i += 1
				end until subQuery[i][subQuery[i].length-1] == ")"				
				ret[0].push(subQuery[i])
			end			
			i +=1
		end until subQuery[i-1][subQuery[i-1].length-1] == ")"	|| i = subQuery.length
		ret[1] = i
		return ret		
	end
	
	
	def hasOR(query)
		if query.split("OR").length == 1
			return false
		else
		end
		return true		
	end
	
	
end