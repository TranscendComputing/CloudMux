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
      
      disks_list = disks.select { |disk| disk.capacity_loaded? }.map { |disk| disk.extend(VCloudDiskRepresenter); disk }

      [OK, disks_list.to_json]
    rescue => error
      handle_error(error)
    end
  end
end
