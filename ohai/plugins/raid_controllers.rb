provides 'raid/controllers'

if File.exist?('/usr/bin/lspci')
  ls_pci_output = %x(/usr/bin/lspci -m | /bin/grep -i raid)
else
  return 0
end

if ls_pci_output.size < 1
  return 0
end

raid_controllers Mash.new

i = 0
ls_pci_output.each_line do
   |line|
  controller = line.split
  raid_controllers[i.to_s] = Mash.new
  rs = String.new()
  controller.slice(4..-1).each {
    |e|
    if rs == ''
      rs = e.sub(/"/, '').chomp
    else
      rs = rs + ' ' + e.sub(/"/, '').chomp
    end
  }
  raid_controllers[i.to_s][:type] = rs
  i = i + 1
end
