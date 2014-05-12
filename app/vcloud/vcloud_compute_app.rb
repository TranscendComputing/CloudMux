require 'sinatra'
require 'fog'
require 'pry'

class VCloudComputeApp < VCloudApp
  #
  # Organizations
  #
  get '/organizations' do
    begin
      orgs = @compute.organizations
      [OK, orgs.to_json]
    rescue => error
      handle_error(error)
    end
  end

  get '/organizations/:id' do
    begin
      org = @compute.organizations.get(params[:id])
      [OK, org.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # vDCs
  #
  get '/data_centers' do
    begin
      vdcs = @org.vdcs
      [OK, vdcs.to_json]
    rescue => error
      handle_error(error)
    end
  end

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
  get '/data_centers/:vdc_id/vapps' do
    begin
      vapps = @org.vdcs.get(params[:vdc_id]).vapps.all(false)

      vapp_list = vapps.map { |vapp| vapp.extend(VCloudVappRepresenter); vapp }
      [OK, vapp_list.to_json]
    rescue => error
      handle_error(error)
    end
  end

  get '/data_centers/:vdc_id/vapps/:id' do
    begin
      vapp = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:id])
      [OK, vapp.to_json]
    rescue => error
      handle_error(error)
    end
  end

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

  post '/data_centers/:vdc_id/vapps/:id/clone' do
    json_body = body_to_json_or_die('body' => request)
    begin
      if json_body['vapp_options']
        response = @compute.post_clone_vapp(params[:vdc_id], json_body['vapp_name'], params[:id], json_body['vapp_options'])
      else
        response = @compute.post_clone_vapp(params[:vdc_id], json_body['vapp_name'], params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # vApp Snapshots
  #
  post '/data_centers/:vdc_id/apps/:id/snapshot' do
    json_body = body_to_json(request)
    begin
      if json_body['snapshot_options']
        response = @compute.post_create_snapshot(params[:id], json_body['snapshot_options'])
      else
        response = @compute.post_create_snapshot(params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  post '/data_centers/:vdc_id/apps/:id/revert_to_snapshot' do
    begin
      response = @compute.post_revert_snapshot(params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  delete '/data_centers/:vdc_id/apps/:id/snapshot' do
    begin
      response = @compute.post_remove_all_snapshots(params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # VMs
  #
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms' do
    begin
      vms = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.all(false)
      [OK, vms.to_json]
    rescue => error
      handle_error(error)
    end
  end

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
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/network' do
    begin
      network = @org.vdcs.get(params[:vdc_id]).vapps.get(:vapp_id).vms.get(params[:id]).network

      network.extend(VCloudNetworkRepresenter)
      [OK, network.to_json]
    rescue => error
      handle_error(error)
    end
  end

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

  get '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/disks' do
    begin
      disks = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:id]).disks
      [OK, disks.to_json]
    rescue => error
      handle_error(error)
    end
  end

  put '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id' do
    json_body = body_to_json_or_die('body' => request)
    begin
      disk = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.get(params[:id].to_i)
      disk.capacity = json_body['capacity'] if !json_body['capacity'].nil? && json_body['capacity'].to_s != disk.capacity.to_s
      [OK, disk.to_json]
    rescue => error
      handle_error(error)
    end
  end

  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks' do
    json_body = body_to_json_or_die('body' => request)
    begin
      response = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.create(json_body['size'])
      [OK, response.to_json]
    rescue => error
      handle_error(error)
    end
  end

  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/attach' do
    json_body = body_to_json(request)
    begin
      if json_body['disk_options']
        response = @compute.post_attach_disk(params[:vm_id], params[:id], json_body['disk_options'])
      else
        response = @compute.post_attach_disk(params[:vm_id], params[:id])
      end
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id/detach' do
    begin
      response = @compute.post_detach_disk(params[:vm_id], params[:id])
      [OK, response.body.to_json]
    rescue => error
      handle_error(error)
    end
  end

  delete '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id' do
    begin
      disk = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.get(params[:id].to_i)
      response = disk.destroy
      [OK, response.to_json]
    rescue => error
      handle_error(error)
    end
  end
end
