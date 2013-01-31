require 'sinatra'

class ProvisioningApiApp < ApiBase

  # retrieve the provisioned instances for a version and environment
  get '/:id.json' do
    provisioned_version = ProvisionedVersion.find(params[:id])
    if provisioned_version.nil?
      return [404]
    end
    provisioned_version.extend(ProvisionedVersionRepresenter)
    [OK, provisioned_version.to_json]
  end

  # create a new provisioned stack. Instances should be captured separately using the appropriate API
  post '/:project_id' do
    provisioned_version = ProvisionedVersion.new.extend(UpdateProvisionedVersionRepresenter)
    provisioned_version.from_json(request.body.read)
    provisioned_version.project_id = params[:project_id]
    if provisioned_version.valid?
      provisioned_version.save!
      # refresh without the Update representer, so that we don't serialize private data back
      provisioned_version = ProvisionedVersion.find(provisioned_version.id).extend(ProvisionedVersionRepresenter)
      [CREATED, provisioned_version.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{provisioned_version.errors.full_messages.join(";")}"
      message.validation_errors = provisioned_version.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # store one or more instances previously provisioned, associating them to a specific provisioned version
  post '/:id/instances' do
    provisioned_version = ProvisionedVersion.find(params[:id])
    list = Struct.new(:instances).new
    list.extend(ProvisionedInstancesRepresenter)
    list.from_json(request.body.read)
    list.instances.each do |i|
      i.provisioned_version = provisioned_version
      i.save!
    end
    provisioned_version.reload
    provisioned_version.extend(ProvisionedVersionRepresenter)
    return [OK, provisioned_version.to_json]
  end
  
  # update the details of a provisioned instance
  put '/:id/instances/:instance_id' do
    provisioned_version = ProvisionedVersion.find(params[:id])
    if provisioned_version.nil?
        puts "** pv not found"
        return [404]
    end
    update_instance = provisioned_version.find_instance(params[:instance_id])
    if update_instance.nil?
      puts "** instance not found"
      return [404]
    end
    update_instance.extend(UpdateProvisionedInstanceRepresenter)
    update_instance.from_json(request.body.read)
    if update_instance.valid?
        update_instance.save!
        provisioned_version.extend(ProvisionedVersionRepresenter)
        [OK, provisioned_version.to_json]
    else
        message = Error.new.extend(ErrorRepresenter)
        message.message = "#{update_instance.errors.full_messages.join(";")}"
        message.validation_errors = update_instance.errors.to_hash
        [BAD_REQUEST, message.to_json]
    end
  end

  # delete an instance previously captured as provisioned
  delete '/:id/instances/:instance_id' do
    provisioned_version = ProvisionedVersion.find(params[:id])
    if provisioned_version.nil?
      puts "** pv not found"
      return [404]
    end
    instance = provisioned_version.find_instance(params[:instance_id])
    if instance.nil?
      puts "** instance not found"
      return [404]
    end
    instance.delete
    provisioned_version.extend(ProvisionedVersionRepresenter)
    [OK, provisioned_version.to_json]
  end

  # delete a previously provisioned stack, including all associated instances
  delete '/:id' do
    provisioned_version = ProvisionedVersion.find(params[:id])
    if provisioned_version.nil?
      return [404]
    end
    provisioned_version.delete
    [OK]
  end

end
