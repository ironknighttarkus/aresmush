module AresMUSH
  module Rooms
    class TeleportCmd
      include AresMUSH::Plugin

      attr_accessor :destination
      
      # Validators
      must_be_logged_in
      no_switches
      argument_must_be_present "destination", "teleport"
      
      def want_command?(client, cmd)
        cmd.root_is?("teleport")
      end
      
      def crack!
        self.destination = trim_input(cmd.args)
      end
      
      # TODO - Permissions
      
      def handle
        find_result = SingleTargetFinder.find(self.destination, Character)
        if (find_result.found?)
          Rooms.move_to(client, find_result.target.room)
          return
        end

        find_result = SingleTargetFinder.find(self.destination, Room)
        if (!find_result.found?)
          client.emit_failure(find_result.error)
          return
        end
        
        Rooms.move_to(client, find_result.target)
      end
    end
  end
end