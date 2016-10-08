class JobStageDescription

	attr_accessor :stage_name, :substage_name

	def get_json
		{ stage_name: @stage_name, substage_name: @substage_name }.to_json
	end

end