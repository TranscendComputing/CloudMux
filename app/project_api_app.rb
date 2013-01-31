require 'sinatra'

class ProjectApiApp < ApiBase
  get '/' do
    per_page = (params[:per_page] || 20).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    conditions = { }
    conditions[:owner_id] = params[:owner_id] if params[:owner_id]
    conditions[:project_type] = params[:project_type] if params[:project_type]

    projects = Project.all.where(conditions)
    count = Project.where(conditions).count
    query = Query.new(count, page, offset, per_page)
    project_query = ProjectQuery.new(query, projects).extend(ProjectQueryRepresenter)
    [OK, project_query.to_json]
  end

  post '/:id/open/:account_id' do
    project = Project.find(params[:id])
    project.opened_by!(params[:account_id])
    project.extend(ProjectRepresenter)
    project.to_json
  end
  
  post '/:id' do
    project = Project.find(params[:id])
	project.extend(ProjectRepresenter)
	project.to_json
  end

  post '/' do
#    create = Struct.new(:name, :description, :project_type, :cloud_account_id, :owner_id, :with_environments).new
#    create.extend(CreateProjectRepresenter)
#    create.from_json(request.body.read)
#    new_project = Project.new
#    new_project.name = create.name
#    new_project.description = create.description
#    new_project.project_type = create.project_type
#    new_project.cloud_account_id = BSON::ObjectId.from_string(create.cloud_account_id)
#    new_project.owner_id = BSON::ObjectId.from_string(create.owner_id)
#    new_project.with_environments(create.with_environments)
    new_project = Project.new.extend(UpdateProjectRepresenter)
    new_project.from_json(request.body.read)
    if new_project.valid?
      new_project.save!
      # refresh without the Update representer, so that we don't serialize private data back
      project = Project.find(new_project.id).extend(ProjectRepresenter)
      [CREATED, project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_project.errors.full_messages.join(";")}"
      message.validation_errors = new_project.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_project = Project.find(params[:id])
    update_project.extend(UpdateProjectRepresenter)
    update_project.from_json(request.body.read)
    if update_project.valid?
      update_project.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      project = Project.find(update_project.id).extend(ProjectRepresenter)
      [OK, project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_project.errors.full_messages.join(";")}"
      message.validation_errors = update_project.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
    project = Project.find(params[:id])
    project.delete
    [OK]
  end

  # mark a project as archived
  post '/:id/archive' do
    project = Project.find(params[:id]).extend(ProjectRepresenter)
    project.archive!
    [OK, project.to_json]
  end

  # mark a project as active
  post '/:id/reactivate' do
    project = Project.find(params[:id]).extend(ProjectRepresenter)
    project.active!
    [OK, project.to_json]
  end

  # Register a new member to an existing project
  post '/:id/members' do
    update_project = Project.find(params[:id])
    new_member = Member.new.extend(UpdateMemberRepresenter)
    new_member.from_json(request.body.read)
    new_member.project = update_project
    if new_member.valid?
      new_member.save!
      project = Project.find(update_project.id).extend(ProjectRepresenter)
      update_project.extend(ProjectRepresenter)
      [CREATED, update_project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_member.errors.full_messages.join(";")}"
      message.validation_errors = new_member.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Remove a member from an existing project
  delete '/:id/members/:member_id' do
    update_project = Project.find(params[:id])
    update_project.remove_member!(params[:member_id])
    project = Project.find(update_project.id).extend(ProjectRepresenter)
    update_project.extend(ProjectRepresenter)
    [OK, update_project.to_json]
  end
  
  # Register a permission to an existing member
  post '/:id/members/:member_id/permissions' do
	update_project = Project.find(params[:id])
	new_permission = Permission.new.extend(UpdatePermissionRepresenter)
	new_permission.from_json(request.body.read)
	if new_permission.valid?
		update_project.add_member_permission!(params[:member_id], new_permission)
		update_project.extend(ProjectRepresenter)
		[CREATED, update_project.to_json]
	else
		message = Error.new.extend(ErrorRepresenter)
		message.message = "#{new_permission.errors.full_messages.join(";")}"
		message.validation_errors = new_permission.errors.to_hash
		[BAD_REQUEST, message.to_json]
	end
  end
  
  # Remove an existing permission to an existing member
  delete '/:id/members/:member_id/permissions/:permission_id' do
	update_project = Project.find(params[:id])
	update_project.remove_member_permission!(params[:member_id], params[:permission_id])
	update_project.extend(ProjectRepresenter)
	[OK, update_project.to_json]
  end
  
  # Bulk imports permissions into a user
  post '/:id/members/:member_id/permissions/import' do
    update_project = Project.find(params[:id])
	results = ImportResults.new.extend(ImportResultsRepresenter)
    all = Struct.new(:permissions).new.extend(PermissionsRepresenter)
    all.from_json(request.body.read)
	failures = false
    all.permissions.each do |permission|
		if permission.valid?
			update_project.add_member_permission!(params[:member_id], permission)
			results.add_result(permission.id, ImportResults::SUCCESS)
		else
			failures = true
			result.add_result(permission.id, ImportResults::FAILED)
		end
    end
	if failures
		[OK, results.to_json]
	else
		update_project.extend(ProjectRepresenter)
		[CREATED, update_project.to_json]
	end
  end
  
  # Remove all permissions for an environment from an existing member
  delete '/:id/members/:member_id/env_permissions/:environment' do
	update_project = Project.find(params[:id])
	update_project.remove_member_environment_permissions!(params[:member_id], params[:environment])
	update_project.extend(ProjectRepresenter)
	[OK, update_project.to_json]
  end

   # Register an existing group to an existing project
  post '/:id/groups/:group_id' do
    update_project = Project.find(params[:id])
    group = Group.find(params[:group_id])
	new_group_project = GroupProject.new(:group=>group)
    if new_group_project.valid?
      update_project.group_projects << new_group_project
      update_project.extend(ProjectRepresenter)
      [CREATED, update_project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_group_project.errors.full_messages.join(";")}"
      message.validation_errors = new_group_project.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Remove a group from an existing project
  delete '/:id/groups/:group_id' do
    update_project = Project.find(params[:id])
    update_project.remove_group!(params[:group_id])
    update_project.extend(ProjectRepresenter)
    [OK, update_project.to_json]
  end
  
  # Register a permission to an existing group
  post '/:id/groups/:group_id/permissions' do
	update_project = Project.find(params[:id])
	new_permission = Permission.new.extend(UpdatePermissionRepresenter)
	new_permission.from_json(request.body.read)
	if new_permission.valid?
		update_project.add_group_permission!(params[:group_id], new_permission)
		update_project.extend(ProjectRepresenter)
		[CREATED, update_project.to_json]
	else
		message = Error.new.extend(ErrorRepresenter)
		message.message = "#{new_permission.errors.full_messages.join(";")}"
		message.validation_errors = new_permission.errors.to_hash
		[BAD_REQUEST, message.to_json]
	end
  end
  
  # Remove an existing permission to an existing group
  delete '/:id/groups/:group_id/permissions/:permission_id' do
	update_project = Project.find(params[:id])
	update_project.remove_group_permission!(params[:group_id], params[:permission_id])
	update_project.extend(ProjectRepresenter)
	[OK, update_project.to_json]
  end
  
  # Bulk imports permissions into a group
  post '/:id/groups/:group_id/permissions/import' do
    update_project = Project.find(params[:id])
	results = ImportResults.new.extend(ImportResultsRepresenter)
    all = Struct.new(:permissions).new.extend(PermissionsRepresenter)
    all.from_json(request.body.read)
	failures = false
    all.permissions.each do |permission|
		if permission.valid?
			update_project.add_group_permission!(params[:group_id], permission)
			results.add_result(permission.id, ImportResults::SUCCESS)
		else
			failures = true
			result.add_result(permission.id, ImportResults::FAILED)
		end
    end
	if failures
		[OK, results.to_json]
	else
		update_project.extend(ProjectRepresenter)
		[CREATED, update_project.to_json]
	end
  end
  
  # Remove all permissions for an environment from an existing group
  delete '/:id/groups/:group_id/env_permissions/:environment' do
	update_project = Project.find(params[:id])
	update_project.remove_group_environment_permissions!(params[:group_id], params[:environment])
	update_project.extend(ProjectRepresenter)
	[OK, update_project.to_json]
  end

  # freeze the project as a new version
  post '/:id/:version/freeze_version' do
    project = Project.find(params[:id])
    new_version = Version.new.extend(VersionRepresenter)
    new_version.from_json(request.body.read)
    if new_version.valid? and new_version.validate_version_number(project.versions)
      project.freeze!(new_version, params[:version])
      project.extend(ProjectRepresenter)
      [CREATED, project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_version.errors.full_messages.join(";")}"
      message.validation_errors = new_version.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end
  
  # promot the project version
  post '/:project_id/versions/:version/promote' do
    project = Project.find(params[:project_id])
    template_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    new_environment = Environment.new.extend(UpdateEnvironmentRepresenter)
    new_environment.from_json(request.body.read)
    if new_environment.valid? and new_environment.validate_unique_environment(template_version.environments)
      template_version.promote!(new_environment)
      project = Project.find(params[:project_id])
      project.extend(ProjectRepresenter)
      [CREATED, project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_environment.errors.full_messages.join(";")}"
      message.validation_errors = new_environment.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end  

  get '/:project_id/versions/:version.json' do
    template_version = ProjectVersion.find_for_project(params[:project_id], params[:version] || ProjectVersion::CURRENT)
    if template_version.nil?
      return [NOT_FOUND]
    end
    template_version.extend(ProjectVersionRepresenter)
    [OK, template_version.to_json]
  end
  
  # mark a project version as archived
  post '/:project_id/versions/:version/archive' do
    template_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    template_version.archive!
    template_version.extend(ProjectVersionRepresenter)
    [OK, template_version.to_json]
  end

  # mark a project version as active
  post '/:project_id/versions/:version/reactivate' do
    template_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    template_version.active!
    template_version.extend(ProjectVersionRepresenter)
    [OK, template_version.to_json]
  end

  #
  # -- ProjectVersion Element and Node API support
  #

  # create element
  post '/:project_id/:version/elements' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    new_element = Element.new.extend(UpdateElementRepresenter)
    new_element.from_json(request.body.read)
    new_element.project_version = project_version
    if new_element.valid?
      new_element.save!
      updated_element = project_version.find_element(new_element.id)
      updated_element.extend(ElementRepresenter)
      [CREATED, updated_element.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_element.errors.full_messages.join(";")}"
      message.validation_errors = new_element.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # bulk imports elements into a project
  post '/:project_id/:version/elements/import' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    results = ImportResults.new.extend(ImportResultsRepresenter)
    all = Struct.new(:elements).new.extend(ElementsRepresenter)
    all.from_json(request.body.read)
    all.elements.each do |element|
      element.project_version = project_version
      if element.valid?
        element.save
        results.add_result(element.id, ImportResults::SUCCESS)
      else
        results.add_result(element.id, ImportResults::FAILED)
      end
    end
    [CREATED, results.to_json]
  end

  # update element
  put '/:project_id/:version/elements/:element_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_element = project_version.find_element(params[:element_id])
    if update_element.nil?
      return [NOT_FOUND]
    end
    update_element.extend(UpdateElementRepresenter)
    update_element.from_json(request.body.read)
    if update_element.valid?
      update_element.save!
      updated_element = project_version.find_element(update_element.id)
      updated_element.extend(ElementRepresenter)
      [OK, updated_element.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_element.errors.full_messages.join(";")}"
      message.validation_errors = update_element.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # delete element
  delete '/:project_id/:version/elements/:element_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_element = project_version.find_element(params[:element_id])
    if update_element.nil?
      return [NOT_FOUND]
    end
    update_element.delete
    [OK]
  end

  # create node
  post '/:project_id/:version/nodes' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    new_node = Node.new.extend(UpdateNodeRepresenter)
    new_node.from_json(request.body.read)
    new_node.project_version = project_version
    if new_node.valid?
      new_node.save!
      updated_node = project_version.find_node(new_node.id)
      updated_node.extend(NodeRepresenter)
      [CREATED, updated_node.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_node.errors.full_messages.join(";")}"
      message.validation_errors = new_node.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # bulk imports elements into a project
  post '/:project_id/:version/nodes/import' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    results = ImportResults.new.extend(ImportResultsRepresenter)
    all = Struct.new(:nodes).new.extend(NodesRepresenter)
    all.from_json(request.body.read)
    all.nodes.each do |node|
      node.project_version = project_version
      if node.valid?
        node.save
        results.add_result(node.id, ImportResults::SUCCESS)
      else
        results.add_result(node.id, ImportResults::FAILED)
      end
    end
    [CREATED, results.to_json]
  end

  # link a node to another - needs to come before the other methods to
  # ensure routing rules matchi this correctly
  # (and don't think the /link at the end is an :id)
  post '/:project_id/:version/nodes/link' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    node_link = NodeLink.new.extend(NodeLinkRepresenter)
    node_link.from_json(request.body.read)
    source_node = project_version.find_node(node_link.source_id)
    target_node = project_version.find_node(node_link.target_id)
    if source_node.nil? or target_node.nil?
      return [NOT_FOUND]
    end
    source_node.add_link!(node_link)
    source_node.extend(NodeRepresenter)
    [OK, source_node.to_json]
  end

  # update node
  put '/:project_id/:version/nodes/:node_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_node = project_version.find_node(params[:node_id])
    if update_node.nil?
      return [NOT_FOUND]
    end
    update_node.extend(UpdateNodeRepresenter)
    update_node.from_json(request.body.read)
    if update_node.valid?
      update_node.save!
      updated_node = project_version.find_node(update_node.id)
      updated_node.extend(NodeRepresenter)
      [OK, updated_node.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_node.errors.full_messages.join(";")}"
      message.validation_errors = new_node.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # delete node
  delete '/:project_id/:version/nodes/:node_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_node = project_version.find_node(params[:node_id])
    if update_node.nil?
      return [NOT_FOUND]
    end
    update_node.delete
    [OK]
  end

  #
  # -- Variant Support
  #

  # create variant
  post '/:project_id/:version/variants' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    new_variant = Variant.new.extend(UpdateVariantRepresenter)
    new_variant.from_json(request.body.read)
    new_variant.variantable = project_version
    if new_variant.valid?
      new_variant.save!
      updated_variant = project_version.find_variant(new_variant.id)
      updated_variant.extend(VariantRepresenter)
      [CREATED, updated_variant.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_variant.errors.full_messages.join(";")}"
      message.validation_errors = new_variant.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # update variant
  put '/:project_id/:version/variants/:variant_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_variant = project_version.find_variant(params[:variant_id])
    if update_variant.nil?
      return [NOT_FOUND]
    end
    update_variant.extend(UpdateVariantRepresenter)
    update_variant.from_json(request.body.read)
    if update_variant.valid?
      update_variant.save!
      updated_variant = project_version.find_variant(update_variant.id)
      updated_variant.extend(VariantRepresenter)
      [OK, updated_variant.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_variant.errors.full_messages.join(";")}"
      message.validation_errors = new_variant.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # delete variant
  delete '/:project_id/:version/variants/:variant_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_variant = project_version.find_variant(params[:variant_id])
    if update_variant.nil?
      return [NOT_FOUND]
    end
    update_variant.delete
    [OK]
  end

  #
  # -- Embedded Project Support
  #

  # create embedded_project
  post '/:project_id/:version/embedded_projects' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    new_embedded_project = EmbeddedProject.new.extend(UpdateEmbeddedProjectRepresenter)
    new_embedded_project.from_json(request.body.read)
    new_embedded_project.project_version = project_version
    if new_embedded_project.valid?
      new_embedded_project.save!
      updated_embedded_project = project_version.find_embedded_project(new_embedded_project.id)
      updated_embedded_project.extend(EmbeddedProjectRepresenter)
      [CREATED, updated_embedded_project.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_embedded_project.errors.full_messages.join(";")}"
      message.validation_errors = new_embedded_project.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # delete embedded_project
  delete '/:project_id/:version/embedded_projects/:embedded_project_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    update_embedded_project = project_version.find_embedded_project(params[:embedded_project_id])
    if update_embedded_project.nil?
      return [NOT_FOUND]
    end
    update_embedded_project.delete
    [OK]
  end

  # create embedded project variant
  post '/:project_id/:version/embedded_projects/:embedded_project_id/variants' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    embedded_project = project_version.find_embedded_project(params[:embedded_project_id])
    new_variant = Variant.new.extend(UpdateVariantRepresenter)
    new_variant.from_json(request.body.read)
    new_variant.variantable = embedded_project
    if new_variant.valid?
      new_variant.save!
      updated_variant = embedded_project.find_variant(new_variant.id)
      updated_variant.extend(VariantRepresenter)
      [CREATED, updated_variant.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_variant.errors.full_messages.join(";")}"
      message.validation_errors = new_variant.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # update embedded project variant
  put '/:project_id/:version/embedded_projects/:embedded_project_id/variants/:variant_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    embedded_project = project_version.find_embedded_project(params[:embedded_project_id])
    update_variant = embedded_project.find_variant(params[:variant_id])
    if update_variant.nil?
      return [NOT_FOUND]
    end
    update_variant.extend(UpdateVariantRepresenter)
    update_variant.from_json(request.body.read)
    if update_variant.valid?
      update_variant.save!
      updated_variant = embedded_project.find_variant(update_variant.id)
      updated_variant.extend(VariantRepresenter)
      [OK, updated_variant.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_variant.errors.full_messages.join(";")}"
      message.validation_errors = new_variant.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # delete embedded project variant
  delete '/:project_id/:version/embedded_projects/:embedded_project_id/variants/:variant_id' do
    project_version = ProjectVersion.find_for_project(params[:project_id], params[:version])
    embedded_project = project_version.find_embedded_project(params[:embedded_project_id])
    update_variant = embedded_project.find_variant(params[:variant_id])
    if update_variant.nil?
      return [NOT_FOUND]
    end
    update_variant.delete
    [OK]
  end
end
