require_plugin "raid_controllers"

LSI_RAID_UTIL = "/opt/MegaRAID/MegaCli/MegaCli64"

if not File.exists?(LSI_RAID_UTIL)
   return 0
end

lsi_num = 0
raid_controllers.keys.each do
   |controller_number| 

   if raid_controllers[controller_number][:type] =~ /^LSI/
      raid_vl_output = %x[#{LSI_RAID_UTIL} -LdPdInfo -a#{lsi_num}] 
      raid_pd_output = %x[#{LSI_RAID_UTIL} -PDList -a#{lsi_num}]
      raid_controller = Hash.new()

      enc_id = String.new()
      slot_id = String.new()
      raid_controllers[controller_number][:physical_disks] = Mash.new

      raid_pd_output.each_line do
        |line|
        if line =~ /^\n$/
          next
        end
        if line =~ /^Enclosure Device ID: [0-9]/
          enc_id = line.split(": ")[1].split[0]
          Ohai::Log.debug("Working with Enclosure: #{enc_id}")
          raid_controllers[controller_number][:physical_disks][enc_id] = Hash.new unless defined raid_controllers[controller_number][:physical_disks][enc_id]
        elsif line =~ /^Slot Number: [0-9]/
          slot_id = line.split(": ")[1].split[0]
          Ohai::Log.debug("Working with Slot: #{slot_id}")
          raid_controllers[controller_number][:physical_disks][enc_id][slot_id] = Hash.new
        else
          value_array = line.split(": ")
          raid_controllers[controller_number][:physical_disks][enc_id][slot_id][value_array[0].to_s.squeeze(" ").strip] = value_array[1].to_s.chomp unless value_array.length != 2
        end
      end

      pflag = false 
      vflag = false 
      vdisk_id = String.new()
      pdisk_id = String.new()

      raid_vl_output.each_line do
         |line| 

         if line =~ /^Number of Virtual Disks: [1-9]/
            number_of_vdisks = line.split(": ")[1].to_i
            raid_controllers[controller_number][:volumes] =  Mash.new  
         end

         if line =~ /^\n$/
            vflag = false
            pflag = false
         end

         if vflag == true 
            value_array = line.split(": ")
            raid_controllers[controller_number][:volumes][vdisk_id][value_array[0].to_s.squeeze(" ").strip] = value_array[1].to_s.chomp  
         end
      
         if pflag == true
            value_array = line.split(": ")
            raid_controllers[controller_number][:volumes][vdisk_id][:physical_disks][pdisk_id][value_array[0].to_s.squeeze(" ").strip] = value_array[1].to_s.chomp
            
         end
      
         if line =~ /^PD:/
            pdisk_id = line.split(": ")[1].split[0]
            raid_controllers[controller_number][:volumes][vdisk_id][:physical_disks][pdisk_id] = Hash.new()
            pflag = true
         end
      
         if line =~ /^Virtual Drive:/
            vdisk_id = line.split(": ")[1].split[0]
            raid_controllers[controller_number][:volumes][vdisk_id] = Hash.new()
            raid_controllers[controller_number][:volumes][vdisk_id][:physical_disks] = Hash.new()
            vflag = true
         end

      end

   end

   lsi_num = lsi_num + 1

end
