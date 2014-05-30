require 'sinatra'
require 'fog'
require 'pry'

class VCloudComputeApp < VCloudApp
  ##~ sapi = source2swagger.namespace("vcloud_compute")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"

  #
  # Organizations
  #
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/organizations"
  ##~ a.description = "VMware Organizations"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_organizations"
  ##~ op.summary = "List organizations by credential"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/organizations' do
    begin
      orgs = @compute.organizations
      [OK, orgs.to_json]
    rescue => error
      handle_error(error)
    end
  end
  
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/organizations/:id"
  ##~ a.description = "Organization operations"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_organization"
  ##~ op.summary = "Get organization by id"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/organizations/:id' do
    begin
      org = @compute.organizations.get(params[:id])
      [OK, org.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers"
  ##~ a.description = "VMware Organizations"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vdcs"
  ##~ op.summary = "List data centers"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers' do
    begin
      vdcs = @org.vdcs
      [OK, vdcs.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:id"
  ##~ a.description = "Data Center operations"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vdc"
  ##~ op.summary = "Get data center by id"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:id' do
    begin
      vdc = @org.vdcs.get(params[:id])
      [OK, vdc.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # vApps
  #
  # NOTES:
  # Creating a vApp is done in vcloud_catalog_app

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:id/vapps"
  ##~ a.description = "Data center vApps"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vapps"
  ##~ op.summary = "List vApps for current data center"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:vdc_id/vapps' do
    begin
      vapps = @org.vdcs.get(params[:vdc_id]).vapps.all(false)

      vapp_list = vapps.map { |vapp| vapp.extend(VCloudVappRepresenter); vapp }
      [OK, vapp_list.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id"
  ##~ a.description = "vApp operations"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vapp"
  ##~ op.summary = "Get vApp by id"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:vdc_id/vapps/:id' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      [OK, vapp.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.nickname = "destroy_vapp"
  ##~ op.summary = "Destroy vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  delete '/data_centers/:vdc_id/vapps/:id' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.destroy
      if response
        [OK, response.to_json]
      else
        response = @compute.delete_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/power_off"
  ##~ a.description = "Power off vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "power_off_vapp"
  ##~ op.summary = "Power off a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/power_off' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.power_off
      if response
        [OK, response.to_json]
      else
        response = @compute.post_power_off_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/power_on"
  ##~ a.description = "Power on vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "power_on_vapp"
  ##~ op.summary = "Power on a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/power_on' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.power_on
      if response
        [OK, response.to_json]
      else
        response = @compute.post_power_on_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/reboot"
  ##~ a.description = "Reboot vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "reboot_vapp"
  ##~ op.summary = "Reboot a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/reboot' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.reboot
      if response
        [OK, response.to_json]
      else
        response = @compute.post_reboot_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/reset"
  ##~ a.description = "Reset vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "reset_vapp"
  ##~ op.summary = "Reset a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/reset' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.reset
      if response
        [OK, response.to_json]
      else
        response = @compute.post_reset_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/shutdown"
  ##~ a.description = "Shut down vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "shutdown_vapp"
  ##~ op.summary = "Shut down a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/shutdown' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.shutdown
      if response
        [OK, response.to_json]
      else
        response = @compute.post_shutdown_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/suspend"
  ##~ a.description = "Suspend vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "suspend_vapp"
  ##~ op.summary = "Suspend a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/suspend' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      response = vapp.suspend
      if response
        [OK, response.to_json]
      else
        response = @compute.post_suspend_vapp(params[:id])
        [OK, response.body.to_json]
      end
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/clone"
  ##~ a.description = "Clone vApp"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "clone_vapp"
  ##~ op.summary = "Clone a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/clone' do
    begin
      if params['vapp_options']
        response = @compute.post_clone_vapp(params[:vdc_id], params['vapp_name'], params[:id], params['vapp_options'])
      else
        response = @compute.post_clone_vapp(params[:vdc_id], params['vapp_name'], params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # vApp Snapshots
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/snapshot"
  ##~ a.description = "Create vApp snapshot"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "create_vapp_snapshot"
  ##~ op.summary = "Create snapshot for a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/snapshot' do
    begin
      if params['snapshot_options']
        response = @compute.post_create_snapshot(params[:id], params['snapshot_options'])
      else
        response = @compute.post_create_snapshot(params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.nickname = "delete_vapp_snapshots"
  ##~ op.summary = "Delete all snapshots for a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  delete '/data_centers/:vdc_id/vapps/:id/snapshot' do
    begin
      response = @compute.post_remove_all_snapshots(params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/revert_to_snapshot"
  ##~ a.description = "Revert vApp to current snapshot if one exists"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "revert_vapp_to_snapshot"
  ##~ op.summary = "Revert vApp to current snapshot if one exists"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:id/revert_to_snapshot' do
    begin
      response = @compute.post_revert_snapshot(params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end


  #
  # VMs
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:id/vms"
  ##~ a.description = "Get vApp VMs"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vapp_vms"
  ##~ op.summary = "List VMs for a vApp"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms' do
    begin
      vms = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.all(false)
      [OK, vms.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:id"
  ##~ a.description = "Update VM"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "update_vapp_vm"
  ##~ op.summary = "Updates a VMs memory and/or CPUs"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id' do
    begin
      vm = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:id])
      unless params['status'].nil?
        vm.power_on if params['status'] == 'on' && vm.status != 'on'
        vm.power_off if params['status'] == 'off' && vm.status != 'off'
      end
      vm.cpu = params['cpu'] if !params['cpu'].nil? && params['cpu'].to_s != vm.cpu.to_s
      vm.memory = params['memory'] if !params['memory'].nil? && params['memory'].to_s != vm.memory.to_s
      updated_vm = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:id])
      [OK, updated_vm.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # VM Network
  #

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/network"
  ##~ a.description = "Get VM network"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vm_network"
  ##~ op.summary = "Get network associated with a VM"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/network' do
    begin
      network = @org.vdcs.get(params[:vdc_id]).vapps.get(:vapp_id).vms.get(params[:id]).network
      
      [OK, {:network => network.network, :is_connected => network.is_connected, :mac_address => network.mac_address, :ip_address_allocation_mode => network.ip_address_allocation_mode }]
    rescue => error
      handle_error(error)
    end
  end

  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "update_vm_network"
  ##~ op.summary = "Update a VMs network properties"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/network' do
    begin
      network = @org.vdcs.get(params[:vdc_id]).vapps.get(:vapp_id).vms.get(params[:id]).network
      network.is_connected = params['is_connected'] unless params['is_connected'].nil?
      network.is_address_allocation_mode = params['ip_address_allocation_mode'] unless params['ip_address_allocation_mode'].nil?
      network.mac_address = params['mac_address'] unless params['mac_address'].nil?
      network.save
      [OK, network.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/disks"
  ##~ a.description = "Get VM disks"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "GET"
  ##~ op.nickname = "get_vm_disks"
  ##~ op.summary = "Get all disks for a VM"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/disks' do
    begin
      disks = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:id]).disks.all(false)
      disk_list = disks.find_all { |disk| disk.capacity_loaded? }.map {|disk| {:name => disk.name, :capacity => disk.capacity}}
      [OK, disk_list.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "create_vm_disk"
  ##~ op.summary = "Add a new disk to a VM"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks' do
    begin
      response = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.create(params['size'])
      [OK, response.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id"
  ##~ a.description = "Update capacity for disk"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "PUT"
  ##~ op.nickname = "update_vm_disk"
  ##~ op.summary = "Edit VM disk capacity"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  put '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id' do
    begin
      disk = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.get(params[:id].to_i)
      disk.capacity = params['capacity'] if !params['capacity'].nil? && params['capacity'].to_s != disk.capacity.to_s
      [OK, disk.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.nickname = "destory_vm_disk"
  ##~ op.summary = "Destroy disk"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  delete '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id' do
    begin
      disk = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.get(params[:id].to_i)
      response = disk.destroy
      [OK, response.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/attach"
  ##~ a.description = "Attach disk to VM"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "attach_vm_disk"
  ##~ op.summary = "Attach disk to VM"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/attach' do
    begin
      if params['disk_options']
        response = @compute.post_attach_disk(params[:vm_id], params[:id], params['disk_options'])
      else
        response = @compute.post_attach_disk(params[:vm_id], params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/vcloud/compute/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/detach"
  ##~ a.description = "Detach disk from VM"
  ##~ op = a.operations.add
  ##~ op.set :httpMethod => "POST"
  ##~ op.nickname = "attach_vm_disk"
  ##~ op.summary = "Attach disk to VM"
  ##~ op.errorResponses.add :reason => "API down", :code => 500
  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/detach' do
    begin
      response = @compute.post_detach_disk(params[:vm_id], params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

end
