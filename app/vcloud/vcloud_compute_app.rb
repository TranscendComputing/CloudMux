require 'sinatra'
require 'fog'
require 'pry'

class VCloudComputeApp < VCloudApp

	get '/data_centers' do
		vdcs = @org.vdcs.all.to_a

		vdc_list = vdcs.map do |vdc|
			vdc.extend(VCloudVdcRepresenter)
			vdc.org = @org.name
			vdc
		end

		[OK, vdc_list.to_json]
	end

	get '/data_centers/:id' do
		vdc = @org.vdcs.get(params[:id]).extend(VCloudVdcRepresenter)
		vdc.org = @org.name
		[OK, vdc.to_json]
	end

	get '/vapps' do
		vdcs = @org.vdcs
		vdc = vdcs.get_by_name(params[:vdc])
		vapp_list = vdc.vapps.map do |vapp|
			vapp.extend(VCloudVappRepresenter)
			vapp.org = @org.name
			vapp.vdc = vdc.name
			vapp
		end
		[OK, vapp_list.to_json]
	end

	get '/vms' do
		if(params[:vapp].nil? or params[:vdc].nil?) 
			[BAD_REQUEST, "Missing parameters"]
		end

		vdcs = @org.vdcs
		vdc = vdcs.get_by_name(params[:vdc])
		vapps = vdc.vapps
		vapp = vapps.get_by_name(params[:vapp])

		vm_list = vapp.vms.map do |vm|
			vm.extend(VCloudVmRepresenter)
			vm.org = @org.name
			vm.vdc = vdc.name
			vm.vapp = vapp.name
			vm
		end
		[OK, vm_list.to_json]
	end

	get '/vms/network' do
		vdcs = @org.vdcs
		vdc = vdcs.get_by_name(params[:vdc])
		vapps = vdc.vapps
		vapp = vapps.get_by_name(params[:vapp])
		vms = vapp.vms
		vm = vms.get_by_name(params[:id])
		network = vm.network
		[OK, network.to_json]
	end

	post '/vms/network' do

		vdcs = @org.vdcs
		vdc = vdcs.get_by_name(params[:vdc])
		vapps = vdc.vapps
		vapp = vapps.get_by_name(params[:vapp])
		vms = vapp.vms
		vm = vms.get_by_name(params[:id])
		network = vm.network


		if(! params[:is_connected].nil?)
			network.is_connected = params[:is_connected]
		end
		if(! params[:ip_address_allocation_mode].nil?)
			network.ip_address_allocation_mode = params[:ip_address_allocation_mode]
		end
		if(! params[:mac_address].nil?)
			network.mac_address = params[:mac_address]
		end
		network.save

		[OK, network.to_json]
	end

	get '/vms/disks' do
		vdcs = @org.vdcs
		vdc = vdcs.get_by_name(params[:vdc])
		vapps = vdc.vapps
		vapp = vapps.get_by_name(params[:vapp])
		vms = vapp.vms
		vm = vms.get_by_name(params[:id])
		disks = vm.disks.select { |disk| disk.capacity_loaded? }

		disks = disks.map { |disk| { :name => disk.name, :capacity => disk.capacity }}

		[OK, disks.to_json]
	end

	def get_vms
		vdcs = @org.vdcs
		# get all vapps from each vdc and combine
		vapps  = vdcs.map { |vdc| vdc.vapps.all }.flatten

		# get all vms from each vapp and combine
		vms = vapps.map { |vapp| vapp.vms.all }.flatten
		return vms.to_json
	end

	post '/vms/power_on' do
		vdc = @org.vdcs.get_by_name(params[:vdc])
		vapp = vdc.vapps.get_by_name(params[:vapp])
		vm = vapp.vms.get_by_name(params[:id])
		
		if vm.status != "on"
			vm.power_on
		end

		[OK, vm.to_json]
	end

	post '/vms/power_off' do
		vdc = @org.vdcs.get_by_name(params[:vdc])
		vapp = vdc.vapps.get_by_name(params[:vapp])
		vm = vapp.vms.get_by_name(params[:id])

		if vm.status != "off"
			vm.power_off
		end

		[OK, vm.to_json]
	end

	post '/vms/modify_cpu' do
		if params[:cpu].nil?
			[BAD_REQUEST, "Must provide CPU value"]
		end

		vdc = @org.vdcs.get_by_name(params[:vdc])
		vapp = vdc.vapps.get_by_name(params[:vapp])
		vm = vapp.vms.get_by_name(params[:id])

		if vm.cpu != params[:cpu]
			vm.cpu = params[:cpu]
		end

		[OK, vm.to_json]
	end

	post '/vms/modify_memory' do
		if params[:memory].nil?
			[BAD_REQUEST, "Must provide memory value"]
		end

		vdc = @org.vdcs.get_by_name(params[:vdc])
		vapp = vdc.vapps.get_by_name(params[:vapp])
		vm = vapp.vms.get_by_name(params[:id])

		if vm.memory != params[:memory]
			vm.memory = params[:memory]
		end

		[OK, vm.to_json]
	end

	get '/organizations' do
		orgs = @compute.organizations
		[OK, orgs.to_json]
	end
end