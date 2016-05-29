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
	
	parse = Parse.new()
	parse.parsing(query)
	json = parse.getJson()
	
	erb :index, :locals => {'json' => json}
end




#Analysis: First split the string based on the characters. We may find a la




class Parse
	attr_reader :hashMap # the final hashMap that is used to parse to json.
	attr_reader :array
	attr_reader :comparisons
	attr_reader :logics
	attr_reader :booleans
	
	def initialize()
		@hashMap = Hash.new(0)
		@array = Array.new
		@comparisons = {">" => {"$gt" => Object}, "<" =>{"$lt" => Object}, "=" =>{"$eq" => Object} ,"len" =>{"$len" => Object}}
		@logics = {"OR" => {"$OR" => Array.new} , "AND" => {"$AND" => Array.new}}
		@booleans = {"true"=> {"$eq" => true},"false" => {"$eq" => false}, "!true" => {"$not" => true}, "!false" => {"$not"=> false}}
	end
	
	
	def parsing(query)
	
		getBlocks(query)
		
	end
	
	def getBlocks(query)
		subQuery = query.split()
		strings = Array.new
		compares = Array.new
		booleans = Array.new
		parentesisBlock = Array.new
		i = 0
		blocks = Array.new
		stack = Array.new
		while i < subQuery.length 
			if subQuery[i][0] == "("
			## get a parentesis and it's child parentesis.
				parentesis = Array.new
				parentesis.push(subQuery[i])
				parentesisBlock = getParentesisBlock(subQuery,i,parentesis)

			elsif logics.has_key?(subQuery[i])
			
				if subQuery[i] == "AND" || hashMap != {}
					next
				else
					hashMap = logics[subQuery[i]]
				end	
			else							
			end			
		end
	end
	
	def getParentesisBlock(subQuery,i,parentesis)
		i +=1
		if i = query.length
			return parentesis
		elsif subQuery[i][0] == "("
			subParentesis = Array.new
			subParentesis.push(subQuery[i])
			parentesis.push(getParentesisBlock(subQuery,i,subParentesis))
		elsif subQuery[i][subQuery[i].length-1] == ")"
			parentesis.push(subQuery[i])			
		else
		end
		
		while i<query.length && subQuery[i][subQuery[i].length-1] != ")" 
			parentesis.push(subQuery[i])
			i +=1
		end
		
		if subQuery[i-1][subQuery[i-1].length-1] != ")" 
			parentesis.push(subQuery[i-1])
		else
		end
		
		return parentesis
		
	end
	
	def hasOR(query)
		if query.split("OR").length == 1
			return false
		else
		end
		return true		
	end
	
	
	def getJson()
		return hashMap.to_json
	end
	
	
end

