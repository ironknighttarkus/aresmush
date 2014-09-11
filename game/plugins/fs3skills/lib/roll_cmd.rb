module AresMUSH

  module FS3Skills
    class RollCmd
      include Plugin
      include PluginRequiresLogin
      include PluginRequiresArgs
      
      attr_accessor :name, :roll_str, :private_roll

      def initialize
        self.required_args = ['name', 'roll_str']
        self.help_topic = 'roll'
        super
      end
            
      def want_command?(client, cmd)
        cmd.root_is?("roll") && cmd.args !~ / vs /
      end

      def crack!
        if (cmd.args =~ /\//)
          cmd.crack!(CommonCracks.arg1_slash_arg2)          
          self.name = cmd.args.arg1
          self.roll_str = titleize_input(cmd.args.arg2)
        else
          self.name = client.name        
          self.roll_str = titleize_input(cmd.args)
        end
        self.private_roll = cmd.switch_is?("private")
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client) do |model|
          roll_params = FS3Skills.parse_roll_params self.roll_str
          
          if (roll_params.nil?)
            client.emit_failure t('fs3skills.unknown_roll_params')
            return
          end
          
          die_result = FS3Skills.roll_ability(client, model, roll_params)
          success_level = FS3Skills.get_success_level(die_result)
          success_title = FS3Skills.get_success_title(success_level)
          message = t('fs3skills.simple_roll_result', 
            :name => model.name,
            :roll => self.roll_str,
            :dice => FS3Skills.print_dice(die_result),
            :success => success_title
          )
          FS3Skills.emit_results message, client, model.room, self.private_roll
        end
      end
    end
  end
end
