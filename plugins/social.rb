require "cinch"
require "json"
require "cleverbot-api"

class Social
	include Cinch::Plugin

	def initialize(*)
		super

		@bot = CleverBot.new 

		file = File.read(File.dirname(__FILE__)+"/../settings.json")
		@rubee_data = JSON.parse(file)
		@nick = @rubee_data["nick"]

		file = File.read(File.dirname(__FILE__)+"/social.json")
		@responses = JSON.parse(file)
	end

	match(/^([^.!?+].*)$/i, method: :handle_match, use_prefix: false)
	def handle_match(m, message)
		for matches in @responses
			for match in matches["matches"]
				
				# prepare m 
				if match.include? "{{@nick}}"
					match = match.gsub! "{{@nick}}", @nick
				end
	
				# if regexp matches incomming message
				if match.downcase == message.downcase

					# check odds of replying
					if matches["odds"] != nil
						rand = Random.rand(matches["odds"])

						# dont reply if the dice doesn't roll 0
						if rand != 0
							return false
						end
					end

					# cointoss: random reply or cleverbot reply
					if Random.rand(2) == 0
						rand = Random.rand(matches["responses"].length)
						reply = matches["responses"][rand]		
					else
						reply = @bot.think message.gsub! /#{@nick}/i, ""
					end

					#prepare reply
					if reply.include? "{{sender}}"
						reply = reply.gsub! "{{sender}}", m.user.nick
					end

					# reply 
					m.reply reply 

					# stop looping after reply has been found
					return false

				end
			end
		end

		# no reply found 
		# if it contains our nickname, cleverbot reply anyway
		if message.downcase.include? @nick.downcase
			reply = @bot.think message.gsub! /#{@nick}/i, ""

			m.reply reply
		end

	end

end
