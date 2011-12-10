provides "raid_controllers"
raid_controllers  Mash.new()
ls_pci_output = %x[lspci|grep RAID]
i = 0
ls_pci_output.each_line do
   |line|
   controller = line.split(": ")
   raid_controllers[i.to_s] = Mash.new()
   raid_controllers[i.to_s][:type] = controller[1].chomp
   i = i+1
end
