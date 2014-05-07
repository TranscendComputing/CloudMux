require 'sinatra'
require 'fog'

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
      vapps = @org.vdcs.get(params[:vdc_id]).vapps
      [OK, vapps.to_json]
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

  #
  # VMs
  #
  get '/data_centers/:vdc_id/vapps/:vapp_id/vms' do
    begin
      vms = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms
      [OK, vms.to_json]
    rescue => error
      handle_error(error)
    end
  end

  put '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id' do
    json_body = body_to_json_or_die('body' => request)
    begin
      vm = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:id])
      unless json_body['status'].nil?
        vm.power_on if json_body['status'] == 'on' && vm.status != 'on'
        vm.power_off if json_body['status'] == 'off' && vm.status != 'off'
      end
      vm.cpu = json_body['cpu'] if !json_body['cpu'].nil? && json_body['cpu'].to_s != vm.cpu.to_s
      vm.memory = json_body['memory'] if !json_body['memory'].nil? && json_body['memory'].to_s != vm.memory.to_s
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
      [OK, network.to_json]
    rescue => error
      handle_error(error)
    end
  end

  post '/data_centers/:vdc_id/vapps/:vapp_id/vms/:id/network' do
    json_body = body_to_json_or_die('body' => request)
    begin
      network = @org.vdcs.get(params[:vdc_id]).vapps.get(:vapp_id).vms.get(params[:id]).network
      network.is_connected = json_body['is_connected'] unless json_body['is_connected'].nil?
      network.is_address_allocation_mode = json_body['ip_address_allocation_mode'] unless json_body['ip_address_allocation_mode'].nil?
      network.mac_address = json_body['mac_address'] unless json_body['mac_address'].nil?
      network.save
      [OK, network.to_json]
    rescue => error
      handle_error(error)
    end
  end

  #
  # VM Disks
  #
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
    rescue => error
      handle_error(error)
    end
  end

  delete '/data_centers/:vdc_id/vapps/:vapp_id/vms/:vm_id/disks/:id' do
    begin
      disk = @org.vdcs.get(params[:vdc_id]).vapps.get(params[:vapp_id]).vms.get(params[:vm_id]).disks.get(params[:id].to_i)
      disk.destroy
    rescue => error
      handle_error(error)
    end
  end
end
