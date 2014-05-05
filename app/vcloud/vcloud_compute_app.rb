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
    [BAD_REQUEST, 'Missing parameters'] if params[:vapp].nil? || params[:vdc].nil?

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

    network.is_connected = params[:is_connected] unless params[:is_connected].nil?
    network.ip_address_allocation_mode = params[:ip_address_allocation_mode] unless params[:ip_address_allocation_mode].nil?
    network.mac_address = params[:mac_address] unless params[:mac_address].nil?
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

    disks = disks.map { |disk| { :name => disk.name, :capacity => disk.capacity } }

    [OK, disks.to_json]
  end

  def vms
    vdcs = @org.vdcs
    # get all vapps from each vdc and combine
    vapps  = vdcs.map { |vdc| vdc.vapps.all }.flatten

    # get all vms from each vapp and combine
    vms = vapps.map { |vapp| vapp.vms.all }.flatten
    vms.to_json
  end

  post '/vms/power_on' do
    vdc = @org.vdcs.get_by_name(params[:vdc])
    vapp = vdc.vapps.get_by_name(params[:vapp])
    vm = vapp.vms.get_by_name(params[:id])

    vm.power_on if vm.status != 'on'

    [OK, vm.to_json]
  end

  post '/vms/power_off' do
    vdc = @org.vdcs.get_by_name(params[:vdc])
    vapp = vdc.vapps.get_by_name(params[:vapp])
    vm = vapp.vms.get_by_name(params[:id])

    vm.power_off if vm.status != 'off'

    [OK, vm.to_json]
  end

  post '/vms/modify_cpu' do
    [BAD_REQUEST, 'Must provide CPU value'] if params[:cpu].nil?

    vdc = @org.vdcs.get_by_name(params[:vdc])
    vapp = vdc.vapps.get_by_name(params[:vapp])
    vm = vapp.vms.get_by_name(params[:id])

    vm.cpu = params[:cpu] if vm.cpu != params[:cpu]

    [OK, vm.to_json]
  end

  post '/vms/modify_memory' do
    [BAD_REQUEST, 'Must provide memory value'] if params[:memory].nil?

    vdc = @org.vdcs.get_by_name(params[:vdc])
    vapp = vdc.vapps.get_by_name(params[:vapp])
    vm = vapp.vms.get_by_name(params[:id])

    vm.memory = params[:memory] if vm.memory != params[:memory]
    [OK, vm.to_json]
  end

  get '/organizations' do
    orgs = @compute.organizations
    [OK, orgs.to_json]
  end
end
